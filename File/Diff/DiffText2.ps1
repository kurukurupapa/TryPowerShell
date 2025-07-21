<#
.SYNOPSIS
    �����̃e�L�X�g�t�@�C�����r���A�����̂���s�܂��͈�v����s�𒊏o���܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A�����̓��̓e�L�X�g�t�@�C����ǂݍ��݁A���ׂẴt�@�C���ɋ��ʂ��Ȃ��s�i�����j�������o���܂��B
    ���ʂ́A�W���o�͂ɏ����o����邩�A�w�肳�ꂽ�o�̓t�@�C���ɕۑ�����܂��B
    ���ʂɂ́A�����s�ɂ�'>'�A��v�s�ɂ͋󔒂̃C���W�P�[�^���t�^����܂��B-IncludeMatch�X�C�b�`���w�肷��ƁA��v�s���o�͂���܂��B

.PARAMETER InputPath
    ��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B

.PARAMETER OutputPath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B�w�肵�Ȃ��ꍇ�A���ʂ͕W���o�͂ɕ\������܂��B

.PARAMETER IncludeMatch
    ���̃X�C�b�`���w�肷��ƁA���������łȂ��A���ׂẴt�@�C���ɑ��݂����v�s���o�͂��܂��B

.PARAMETER LineNumber
    ���̃X�C�b�`���w�肷��ƁA�o�͂ɍs�ԍ���t���܂��B�G�C���A�X -n ���g�p�ł��܂��B

.PARAMETER MatchOnly
    ���̃X�C�b�`���w�肷��ƁA�����s���o�͂����A���ׂẴt�@�C���ɋ��ʂ����v�s�݂̂��C���W�P�[�^�Ȃ��ŏo�͂��܂��B

.PARAMETER Separator
    ���ʏo�͎��̋�؂蕶�����w�肵�܂��B�f�t�H���g�̓X�y�[�X�ł��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'Default' (�V�X�e����ANSI�R�[�h�y�[�W) �ł��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt
    2�̃t�@�C���̍�����W���o�͂ɕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -OutputPath diff_lines.txt
    �����̃t�@�C���̍����� 'diff_lines.txt' �ɏo�͂��܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch
    �t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -MatchOnly
    �����̃t�@�C���ɋ��ʂ����v�s�݂̂��A�C���W�P�[�^�Ȃ��ŕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch -n
    �s�ԍ��t���ŁA�t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B')]
    [ValidateCount(1, [int]::MaxValue)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = '���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B')]
    [string]$OutputPath,

    [Parameter(Mandatory = $false, HelpMessage = '��v�s���o�͂Ɋ܂߂�ꍇ�Ɏw�肵�܂��B')]
    [switch]$IncludeMatch,

    [Parameter(Mandatory = $false, HelpMessage = '�o�͂ɍs�ԍ���t����ꍇ�Ɏw�肵�܂��B')]
    [Alias('n')]
    [switch]$LineNumber,

    [Parameter(Mandatory = $false, HelpMessage = '��v�s�݂̂��o�͂���ꍇ�Ɏw�肵�܂��B')]
    [switch]$MatchOnly,

    [Parameter(Mandatory = $false, HelpMessage = '���ʏo�͎��̋�؂蕶�����w�肵�܂��B')]
    [string]$Separator = ' ',

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)

function Find-MatchingLines {
    param(
        [string[]]$FilePaths,
        [string]$Encoding
    )
    # �ŏ��̃t�@�C����ǂݍ���
    $firstPath = $FilePaths[0]
    Write-Verbose "1�ڂ̃t�@�C����ǂݍ��ݒ�: $firstPath"
    [string[]]$matchingLines = @(Get-Content -Path $firstPath -Encoding $Encoding)

    # 2�ڈȍ~�̃t�@�C����������r
    for ($i = 1; $i -lt $FilePaths.Count; $i++) {
        # �r���ň�v����s���Ȃ��Ȃ�Ώ������I��
        if ($matchingLines.Count -eq 0) {
            Write-Verbose "�r���ň�v����s���Ȃ��Ȃ�܂����B�����𒆒f���܂��B"
            break
        }

        $currentPath = $FilePaths[$i]
        Write-Verbose "$($i + 1)�ڂ̃t�@�C����ǂݍ��݁A��r��: $currentPath"
        $currentFileContent = @(Get-Content -Path $currentPath -Encoding $Encoding)

        # Compare-Object���g�p���ċ��ʍs�𒊏o���A���̍s�f�[�^�݂̂����o��
        $matchingLines = @(Compare-Object -ReferenceObject $matchingLines -DifferenceObject $currentFileContent -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue)
    }
    return $matchingLines
}

function Get-ContentFromLines {
    param(
        [string[]]$MatchingLines,
        [int]$SourceFileId
    )
    $MatchingLines | ForEach-Object -Begin { $i = 1 } -Process {
        [PSCustomObject]@{
            Line       = $_
            LineNumber = $i++
            SourceFile = $SourceFileId
        }
    }
}

function Get-ContentFromFile {
    param(
        [string]$Path,
        [string]$Encoding,
        [int]$SourceFileId
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "�t�@�C����������܂���: $Path"
    }
    Write-Verbose "${SourceFileId}�ڂ̃t�@�C����ǂݍ��ݒ�: $Path"
    $content = @(Get-Content -Path $Path -Encoding $Encoding)
    Get-ContentFromLines $content $SourceFileId
}

# Compare-Object���g�p���Ĉ�v/���كf�[�^�𒊏o����
# ���ʏo�͂̂��߁A��v�f�[�^���K���K�v�ƂȂ�
function Compare-FileObject {
    param(
        [psobject[]]$ReferenceObject,
        [psobject[]]$DifferenceObject
    )
    $compareParams = @{
        ReferenceObject  = $ReferenceObject
        DifferenceObject = $DifferenceObject
        Property         = 'Line'
        PassThru         = $true
        IncludeEqual     = $true
    }
    Compare-Object @compareParams
}

function Format-DiffOutput {
    param(
        [object[]]$FileComparisonResults,
        [switch]$IncludeMatch,
        [switch]$LineNumber,
        [string]$Separator
    )

    # �p�t�H�[�}���X�Ə����ۏ؂̂��߁A��r���ʂ��s�ԍ����L�[�Ƃ���n�b�V���e�[�u���ɕϊ����܂��B
    # �e�t�@�C��(��t�@�C���܂�)�̔�r���ʂ��i�[���邽�߂́A�n�b�V���e�[�u���̔z����������܂��B
    # $FileComparisonResults�̗v�f���͔�r�Ώۂ̃t�@�C�����Ɠ������B��t�@�C��(ID=0)���K�v�Ȃ̂�+1���܂��B
    $fileMapArr = 1..($FileComparisonResults.Count + 1) | ForEach-Object { @{} }

    foreach ($comparisonResult in $FileComparisonResults) {
        foreach ($obj in $comparisonResult) {
            # $obj.SourceFile �� 0 (�) �܂��� 1, 2, ... (�e�t�@�C��) �������B
            # �Ή�����SourceFile ID�̃n�b�V���e�[�u���ɁALineNumber���L�[�Ƃ��ăI�u�W�F�N�g���i�[����B
            $fileMapArr[$obj.SourceFile][$obj.LineNumber] = $obj
        }
    }

    # �s�ԍ����ɏo�̓e�L�X�g�𐮌`����
    $fileCount = $fileMapArr.Count
    $lineCounters = @(1) * $fileCount # �e�t�@�C���̌��ݍs��ǐՂ���z�� (�����l��1)
    # ��v/���ٍs�u���b�N�̃��[�v
    while ($true) {
        # �I������
        $noneCount = 0
        for ($i = 0; $i -lt $fileCount; $i++) {
            if (-not $fileMapArr[$i][$lineCounters[$i]]) {
                $noneCount++
            }
            Write-Verbose "�I������ $i $($lineCounters[$i]) $noneCount"
        }
        if ($noneCount -eq $fileCount) {
            break
        }

        # �e���̓t�@�C���̃��[�v
        # �e���̓t�@�C���ɂ����錻�ݍs�̍��كu���b�N�𐮌`����
        for ($i = 1; $i -lt $fileCount; $i++) {
            while ($fileMapArr[$i].ContainsKey($lineCounters[$i])) {
                $file2Diff = $fileMapArr[$i][$lineCounters[$i]]
                Write-Verbose "SourceFile=$i Line=$($lineCounters[$i]) $($file2Diff.SourceFile) $($file2Diff.SideIndicator) $($file2Diff.Line)"
                if ($file2Diff.SideIndicator -eq '=>') {
                    # �e���̓t�@�C���̍��كf�[�^�ŁA�ǉ����ꂽ�s
                    $prefix1 = ">$Separator"
                    $prefix2 = if ($LineNumber.IsPresent) { "$($Separator * ($i - 1))$($lineCounters[$i])$($Separator * ($fileCount - $i - 1))$Separator" } else { "" }
                    "$prefix1$prefix2$($file2Diff.Line)"
                    Write-Verbose "���فF$prefix1$prefix2$($file2Diff.Line)"
                }
                else {
                    # �z��O�̃f�[�^�̓G���[�Ƃ��ĕ�
                    Write-Error "�\�����Ȃ��f�[�^: SourceFile=$i Line=$($lineCounters[$i]) $($file2Diff.SourceFile) $($file2Diff.SideIndicator) $($file2Diff.Line)"
                }
                $lineCounters[$i]++
            }
        }

        # ��ƂȂ��v�s�Z�b�g�̏�����i�߂�
        $file1Diff = $fileMapArr[0][$lineCounters[0]]
        Write-Verbose "SourceFile=0 Line=$($lineCounters[0]) $($file1Diff.SourceFile) $($file1Diff.SideIndicator) $($file1Diff.Line)"
        if ($file1Diff) {
            if ($file1Diff.SideIndicator -eq '==') {
                # ��v�����s
                if ($IncludeMatch.IsPresent) {
                    $prefix1 = " $Separator"
                    $prefix2 = ""
                    if ($LineNumber.IsPresent) {
                        # �e���̓t�@�C���̍s�ԍ����o�͂���
                        # ��I�u�W�F�N�g(SourceFile=0)���̂͏o�͑ΏۊO
                        for ($i = 1; $i -lt $fileCount; $i++) {
                            $prefix2 += "$($lineCounters[$i])$Separator"
                        }
                    }
                    "$prefix1$prefix2$($file1Diff.Line)"
                    Write-Verbose "��v�F$prefix1$prefix2$($file1Diff.Line)"
                }
            }
            else {
                # �z��O�̃f�[�^�̓G���[�Ƃ��ĕ�
                # ��I�u�W�F�N�g�͈�v�s�݂̂̂͂��Ȃ̂ŁA"<="��"=>"�͏o�����Ȃ��z��B
                Write-Error "�\�����Ȃ��f�[�^: SourceFile=0 Line=$($lineCounters[0]) $($file1Diff.SourceFile) $($file1Diff.SideIndicator) $($file1Diff.Line)"
            }
            for ($i = 0; $i -lt $fileCount; $i++) {
                $lineCounters[$i]++
            }
        }
    }
}

function Write-OutputContent {
    param(
        [object[]]$Content,
        [string]$OutputPath,
        [string]$Encoding
    )
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # �W���o�͂�
        $Content
    }
    else {
        # �t�@�C���֏o��
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        [System.IO.File]::WriteAllLines($OutputPath, @($Content), $encodingObject)
        Write-Verbose "�o�͂��܂����B$OutputPath"
    }
}

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
            return "[$typeName](${count}��): $content"
        }
        return $InputObject.ToString()
    }
}

try {
    # ���̓p�X�������i���C���h�J�[�h�ƃt�H���_�W�J�j
    # -ErrorAction Stop ���w�肵�āA�p�X��������Ȃ��ꍇ��catch�u���b�N�ŏ����ł���悤�ɂ���
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique

    # ��r����t�@�C����2�ȏ゠�邩�m�F
    if ($resolvedFilePaths.Count -lt 2) {
        throw "��r�Ώۂ̃t�@�C����2�ȏ㌩����܂���ł����B�w�肳�ꂽ�p�X���m�F���Ă��������B"
    }

    # ���ׂĂ̓��̓t�@�C�������v�s�𒊏o
    Write-Verbose "��v�s�𒊏o��"
    $matchingLines = @(Find-MatchingLines -FilePaths $resolvedFilePaths -Encoding $Encoding)
    Write-Verbose "matchingLines: $(Format-DebugString $matchingLines)"

    # -MatchOnly���w�肳��Ă���ꍇ�́A��v�s���o�͂��ďI��
    if ($MatchOnly.IsPresent) {
        Write-OutputContent -Content $matchingLines -OutputPath $OutputPath -Encoding $Encoding
        return
    }

    # ��L�Œ��o������v�s�ƁA�e���̓t�@�C�����r����
    Write-Verbose "�e�t�@�C�����r��"
    $referenceObject = @(Get-ContentFromLines -MatchingLines $matchingLines -SourceFileId 0)
    Write-Verbose "referenceObject: $(Format-DebugString $referenceObject)"
    $i = 1
    # �e�t�@�C���̔�r����(�I�u�W�F�N�g�z��)���i�[����z��ł��B
    $fileComparisonResults = @()
    foreach ($resolvedFilePath in $resolvedFilePaths) {
        $differenceObject = @(Get-ContentFromFile -Path $resolvedFilePath -Encoding $Encoding -SourceFileId $i)

        # Compare-FileObject�̌��ʁi�z��j���A�J���}���Z�q���g���Ĕz��̗v�f�Ƃ��Ēǉ�����
        $singleFileResult = Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject
        $fileComparisonResults += , ($singleFileResult)
        $i++
    }

    # ���ʂ��o��
    Write-Verbose "���ʏo�͒�"
    $formattedDifferences = Format-DiffOutput -FileComparisonResults $fileComparisonResults -IncludeMatch:$IncludeMatch -LineNumber:$LineNumber -Separator $Separator
    if (-not $formattedDifferences) { $formattedDifferences = @() }
    Write-OutputContent -Content $formattedDifferences -OutputPath $OutputPath -Encoding $Encoding
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
