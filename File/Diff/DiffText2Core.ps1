# PowerShell�X�N���v�g: DiffText2Core.ps1

function Format-DebugString {
    param(
        [object]$InputObject
    )
    process {
        if ($null -eq $InputObject) {
            return '$null'
        }

        # �z���R���N�V�����̏ꍇ
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $typeName = $InputObject.GetType().FullName
            $count = @($InputObject).Count
            $content = ($InputObject | ForEach-Object { "'$_'" }) -join ', '
            return "$typeName ${count}�� $content"
        }
        return $InputObject.ToString()
    }
}

<#
1�s���̔�r����ێ�����N���X
#>
class ComparisonLine {
    [string]$Line          # �s�̓��e
    [int]$LineNumber       # �s�ԍ�
    [int]$SourceFileIndex  # ���t�@�C���̃C���f�b�N�X
    [string]$SideIndicator # Compare-Object�Őݒ�
    [int]$DiffLineNumber   # ��r�t�@�C���̍s�ԍ�
}

class FileComparer {
    [string[]] GetLinesFromFile(
        [string]$Path,
        [string]$Encoding
    ) {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            throw "�t�@�C����������܂���: $Path"
        }
        return Get-Content -Path $Path -Encoding $Encoding
    }

    # �w��t�@�C���̓��e��1�s���I�u�W�F�N�g�����Ď擾
    [ComparisonLine[]] GetComparisonLines(
        [string[]]$Lines,         # ���͍s�z��
        [int]$SourceFileIndex     # ���t�@�C���̃C���f�b�N�X
    ) {
        if ($null -eq $Lines) {
            $Lines = @()
        }
        # �e�s��ComparisonLine�I�u�W�F�N�g��
        $comparisonLines = $Lines | ForEach-Object -Begin { $i = 1 } -Process {
            [ComparisonLine]@{
                Line            = $_
                LineNumber      = $i++
                SourceFileIndex = $SourceFileIndex
            }
        }
        Write-Debug "GetComparisonLines: ���ʌ���:$($comparisonLines.Count)"
        return $comparisonLines
    }

    # �w��t�@�C���̓��e��1�s���I�u�W�F�N�g�����Ď擾
    [ComparisonLine[]] GetComparisonLinesFromFile(
        [string]$Path,
        [string]$Encoding,
        [int]$SourceFileIndex
    ) {
        Write-Verbose "$($SourceFileIndex + 1)���ڂ̃t�@�C����ǂݍ��ݒ�: $Path"
        $lines = $this.GetLinesFromFile($Path, $Encoding)
        $comparisonLines = $this.GetComparisonLines($lines, $SourceFileIndex)
        Write-Debug "GetComparisonLinesFromFile: ���ʌ���:$($comparisonLines.Count)"
        return $comparisonLines
    }

    # 2�t�@�C���̍s�I�u�W�F�N�g�z����r���A�����E��v����Ԃ�
    [ComparisonLine[]] CompareComparisonLines(
        [ComparisonLine[]]$ReferenceObject,
        [ComparisonLine[]]$DifferenceObject
    ) {
        # Write-Debug "CompareComparisonLines: ReferenceObject:$(Format-DebugString $ReferenceObject)"
        # Write-Debug "CompareComparisonLines: DifferenceObject:$(Format-DebugString $DifferenceObject)"

        if ($null -eq $ReferenceObject) {
            $ReferenceObject = @()
        }
        if ($null -eq $DifferenceObject) {
            $DifferenceObject = @()
        }

        $params = @{
            ReferenceObject  = $ReferenceObject
            DifferenceObject = $DifferenceObject
            Property         = 'Line'
            PassThru         = $true
            IncludeEqual     = $true
        }
        $comparisonResult = Compare-Object @params
        #=> $ReferenceObject�� $null, @('') �̏ꍇ�A���̃G���[�������B@()�Ȃ琳�폈���B
        #   �������ɃG���[���������܂���: ������ null �ł��邽�߁A�p�����[�^�[ 'ReferenceObject' �Ƀo�C���h�ł��܂���B

        Write-Debug "CompareComparisonLines: ���ʌ���:$($comparisonResult.Count)"
        return $comparisonResult
    }

    # �����t�@�C�����r���A�������I�u�W�F�N�g�z���Ԃ�
    [ComparisonLine[][]] CompareFiles(
        [string[]]$FilePaths,
        [string]$Encoding
    ) {
        Write-Debug "CompareFiles: FilePaths.Count:$($FilePaths.Count)"
        Write-Verbose "�e�t�@�C�����r��"
        $referenceRawLines = $this.GetLinesFromFile($FilePaths[0], $Encoding)

        [ComparisonLine[][]]$comparisonResults = @()
        for ($i = 1; $i -lt $FilePaths.Count; $i++) {
            # $referenceLines�̃f�B�[�v�R�s�[����邽�ߖ����蒼��
            $referenceLines = $this.GetComparisonLines($referenceRawLines, 0)
            $differenceLines = $this.GetComparisonLinesFromFile($FilePaths[$i], $Encoding, $i)
            $comparisonResults += , ($this.CompareComparisonLines($referenceLines, $differenceLines))
        }
        Write-Debug "CompareFiles: ���ʌ���:$($comparisonResults.Count)"
        return $comparisonResults
    }

    [ComparisonResult[]] CompareFilesAsResults(
        [string[]]$FilePaths,
        [string]$Encoding
    ) {
        return $this.CompareFiles($FilePaths, $Encoding) | ForEach-Object { [ComparisonResult]::new($_) }
    }
}

<#
2�t�@�C���̔�r���ʂ��u��t�@�C���̍s�ԍ��v���ƂɊǗ�����N���X�B
DiffMapByRefLine: �L�[=��t�@�C���̍s�ԍ�, �l={ '<=':�폜�s, '=>':�ǉ��s, '==':��v�s(�z��) }
MaxReferenceLineNumber: ��t�@�C���̍ő�s�ԍ�
#>
class ComparisonResult {
    # DiffMap: �L�[=��t�@�C���̍s�ԍ�, �l={ '<=':�폜�s, '=>':�ǉ��s, '==':��v�s }
    [hashtable]$DiffMapByRefLine = @{}
    [int]$MinReferenceLineNumber = -1
    [int]$MaxReferenceLineNumber = -1

    # �R���X�g���N�^: Compare-Object �̌���(�z��)����DiffMapByRefLine���\�z
    ComparisonResult([object[]]$ComparisonLines) {
        # ��r���ʂ���t�@�C���Ɣ�r�t�@�C���ɕ����ă}�b�v��
        $refComparisonLines = @{}
        $diffComparisonLines = @{}
        if (-not $ComparisonLines) { $ComparisonLines = @() }
        # $ComparisonLines | ForEach-Object {
        foreach ($obj in $ComparisonLines) {
            # SourceFileIndex: 0=��t�@�C��, 1�ȏ�=��r�t�@�C��
            if ($obj.SourceFileIndex -eq 0) {
                $refComparisonLines[$obj.LineNumber] = $obj
            }
            else {
                $diffComparisonLines[$obj.LineNumber] = $obj
            }
        }

        $refLineNumber = 0
        $diffLineNumber = 0
        while ($true) {
            $refComparisonLine = $refComparisonLines[$refLineNumber + 1]
            $diffComparisonLine = $diffComparisonLines[$diffLineNumber + 1]
            # �폜�s(��t�@�C���ɂ̂ݑ���)
            if ($refComparisonLine -and $refComparisonLine.SideIndicator -eq '<=') {
                $refLineNumber++
                $this.InitializeLineIfNeeded($refLineNumber)
                $refComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['<='] = $refComparisonLine
            }
            # �ǉ��s(��r�t�@�C���ɂ̂ݑ���)
            elseif ($diffComparisonLine -and $diffComparisonLine.SideIndicator -eq '=>') {
                $this.InitializeLineIfNeeded($refLineNumber)
                $diffLineNumber++
                $diffComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['=>'].Add($diffComparisonLine)
            }
            # ��v�s(���t�@�C���ɓ������e)
            elseif ($refComparisonLine -and $refComparisonLine.SideIndicator -eq '==') {
                $refLineNumber++
                $this.InitializeLineIfNeeded($refLineNumber)
                $diffLineNumber++
                $refComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['=='] = $refComparisonLine
            }
            else {
                break
            }
        }

        Write-Debug "ComparisonResult�R���X�g���N�^: ���ʌ���:$($this.DiffMapByRefLine.Count)"
    }

    [void]InitializeLineIfNeeded($ReferenceLineNumber) {
        if (-not $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            $this.InitializeLine($ReferenceLineNumber)
        }
    }

    [void]InitializeLine($ReferenceLineNumber) {
        $this.DiffMapByRefLine[$ReferenceLineNumber] = @{
            '==' = $null
            '<=' = $null
            '=>' = [System.Collections.Generic.List[object]]::new()
        }
        if ($this.MinReferenceLineNumber -lt 0 -or $this.MinReferenceLineNumber -gt $ReferenceLineNumber) {
            $this.MinReferenceLineNumber = $ReferenceLineNumber
        }
        if ($this.MaxReferenceLineNumber -lt 0 -or $this.MaxReferenceLineNumber -lt $ReferenceLineNumber) {
            $this.MaxReferenceLineNumber = $ReferenceLineNumber
        }
    }

    # ��t�@�C���̍ŏ��s�ԍ���Ԃ��i0�s�ڂ����݂����0�A�Ȃ����1�j
    [int]GetMinReferenceLineNumber() { return $this.MinReferenceLineNumber }

    # ��t�@�C���̍ő�s�ԍ���Ԃ�
    [int]GetMaxReferenceLineNumber() { return $this.MaxReferenceLineNumber }

    # �w��s�̒ǉ��s�i��r�t�@�C���ɂ̂ݑ��݁j��z��ŕԂ�
    [object[]]GetAddedLines($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['=>']
        }
        else {
            return @()
        }
    }

    # �w��s�̍폜�s�i��t�@�C���ɂ̂ݑ��݁j��1�������Ԃ��i�Ȃ����$null�j
    [object]GetRemovedLine($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['<=']
        }
        else {
            return $null
        }
    }

    # �w��s�̈�v�s�i���t�@�C���ɓ������e�j��1�������Ԃ��i�Ȃ����$null�j
    [object]GetCommonLine($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['==']
        }
        else {
            return $null
        }
    }

    # �w��s�����݂��邩
    [bool]HasLine($ReferenceLineNumber) { return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) }

    # �w��s�ɒǉ��s�����邩
    [bool]HasAddedLines($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $this.DiffMapByRefLine[$ReferenceLineNumber]['=>'].Count -gt 0
    }

    # �w��s�ɍ폜�s�����邩
    [bool]HasRemovedLine($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $null -ne $this.DiffMapByRefLine[$ReferenceLineNumber]['<=']
    }

    # �w��s�Ɉ�v�s�����邩
    [bool]HasCommonLine($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $null -ne $this.DiffMapByRefLine[$ReferenceLineNumber]['==']
    }

    # �I�u�W�F�N�g���e��JSON������ŕԂ��i�f�o�b�O�p�j
    [string]ToString() {
        $result = $this.DiffMapByRefLine.GetEnumerator() | Sort-Object { $_.Key } | ForEach-Object { $_ } | ConvertTo-Json -Depth 99 #-Compress
        return $result
    }
}

<#
�����t�@�C���̍������𐮌`���ďo�͗p�e�L�X�g�z��𐶐�����N���X
#>
class ComparisonResultsFormatter {
    [bool]$IncludeMatch = $false
    [bool]$MatchOnly = $false
    [bool]$LineNumber = $false
    [string]$Separator = ' '

    # �e�s�ԍ����ƂɁA�폜�E�ǉ��E��v�s�����ɏo�͗p�e�L�X�g�֐��`
    [string[]]Format([ComparisonResult[]]$ComparisonResults) {
        $comparisonCount = $ComparisonResults.Count
        $formattedLines = @()

        # �eComparisonResult��MinReferenceLineNumber�̍ŏ��l���擾
        [int]$minLineNumber = ($ComparisonResults | ForEach-Object { $_.MinReferenceLineNumber }) | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
        [int]$maxLineNumber = ($ComparisonResults | ForEach-Object { $_.MaxReferenceLineNumber }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

        Write-Debug "ComparisonResultsFormatter.Format: comparisonCount:$comparisonCount minLineNumber:$minLineNumber maxLineNumber:$maxLineNumber"

        for ($count = $minLineNumber; $count -le $maxLineNumber; $count++) {
            # $isFinished = $true
            # for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
            #     if ($ComparisonResults[$comparisonIndex].HasLine($lineNumber)) {
            #         $isFinished = $false
            #         break
            #     }
            # }
            # if ($isFinished) { break }

            # ��v�s
            if ($this.MatchOnly -or $this.IncludeMatch) {
                $isCommonInAll = $true
                for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                    if (-not $ComparisonResults[$comparisonIndex].HasCommonLine($count)) {
                        $isCommonInAll = $false
                        break
                    }
                }
                if ($isCommonInAll) {
                    $formattedLines += $this.FormatCommonLine($ComparisonResults, $count)
                }
            }
            # �폜�s
            for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                if ($ComparisonResults[$comparisonIndex].HasRemovedLine($count)) {
                    if (-not $this.MatchOnly) {
                        $formattedLines += $this.FormatRemovedLine($ComparisonResults, $comparisonIndex, $count)
                    }
                }
            }
            # �ǉ��s
            for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                if ($ComparisonResults[$comparisonIndex].HasAddedLines($count)) {
                    if (-not $this.MatchOnly) {
                        $formattedLines += $this.FormatAddedLines($ComparisonResults, $comparisonIndex, $count)
                    }
                }
            }

            # $lineCounter++
        }

        Write-Debug "ComparisonResultsFormatter.Format: ���ʌ���:$($formattedLines.Count)"
        return $formattedLines
    }

    # �w��s�ԍ��̒ǉ��s���o�͗p�e�L�X�g�z��ɐ��`
    [string[]]FormatAddedLines([ComparisonResult[]]$ComparisonResults, [int]$ComparisonIndex, [int]$ReferenceLineNumber) {
        $LineNumbers = @('') * ($ComparisonResults.Count + 1)
        $addedLines = $ComparisonResults[$ComparisonIndex].GetAddedLines($ReferenceLineNumber) | ForEach-Object {
            $LineNumbers[$ComparisonIndex + 1] = $_.DiffLineNumber
            $this.FormatOutputLine('>', $LineNumbers, $_.Line)
        }
        return $addedLines
    }
    # �w��s�ԍ��̍폜�s���o�͗p�e�L�X�g�z��ɐ��`
    [string]FormatRemovedLine([ComparisonResult[]]$ComparisonResults, [int]$ComparisonIndex, [int]$ReferenceLineNumber) {
        $LineNumbers = @('') * ($ComparisonResults.Count + 1)
        $removedLine = $ComparisonResults[$ComparisonIndex].GetRemovedLine($ReferenceLineNumber) | ForEach-Object {
            $LineNumbers[0] = $_.LineNumber
            $this.FormatOutputLine('<', $LineNumbers, $_.Line)
        }
        return $removedLine
    }
    # �w��s�ԍ��̈�v�s���o�͗p�e�L�X�g�ɐ��`
    [string]FormatCommonLine([ComparisonResult[]]$ComparisonResults, [int]$ReferenceLineNumber) {
        if ($this.MatchOnly) {
            return $ComparisonResults[0].GetCommonLine($ReferenceLineNumber).Line
        }
        else {
            $LineNumbers = @($ReferenceLineNumber)
            $LineNumbers += $ComparisonResults | ForEach-Object { $_.GetCommonLine($ReferenceLineNumber).DiffLineNumber }
            return $this.FormatOutputLine(' ', $LineNumbers, $ComparisonResults[0].GetCommonLine($ReferenceLineNumber).Line)
        }
    }
    # 1�s���̏o�̓e�L�X�g�𐶐�
    [string]FormatOutputLine([string]$Indicator, [string[]]$LineNumberStrings, [string]$Line) {
        $lineNumberPart = ""
        if ($this.LineNumber) {
            $lineNumberPart = ($LineNumberStrings -join $this.Separator) + $this.Separator
        }
        return "$Indicator$($this.Separator)$lineNumberPart$Line"
    }
}
