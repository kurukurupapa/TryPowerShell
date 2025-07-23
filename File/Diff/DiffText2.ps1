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
        [string[]]$FilePaths
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

function Format-OutputLine {
    param(
        [psobject]$LineObject,
        [string]$Indicator,
        [int[]]$LineCounters,
        [int]$FileCount,
        [int]$CurrentFileIndex = -1 # �����s�̏ꍇ�̂ݎw��
    )

    $lineNumberPart = ""
    if ($LineNumber.IsPresent) {
        if ($CurrentFileIndex -ge 1) {
            # �����s�̍s�ԍ��t�H�[�}�b�g: �w�肳�ꂽ�t�@�C���C���f�b�N�X�̈ʒu�ɍs�ԍ���z�u
            # ��: >  2   text  (�t�@�C��2��2�s��)
            $paddingBefore = $Separator * ($CurrentFileIndex - 1)
            $currentLineNumber = $LineCounters[$CurrentFileIndex]
            $paddingAfter = $Separator * ($FileCount - $CurrentFileIndex - 1)
            $lineNumberPart = "$paddingBefore$currentLineNumber$paddingAfter$Separator"
        }
        else {
            # ��v�s�̍s�ԍ��t�H�[�}�b�g: �S�t�@�C���̍s�ԍ�����ׂ�
            # ��:  1 1 text
            $lineNumbers = for ($i = 1; $i -lt $FileCount; $i++) { $LineCounters[$i] }
            $lineNumberPart = ($lineNumbers -join $Separator) + $Separator
        }
    }
    "$Indicator$Separator$lineNumberPart$($LineObject.Line)"
}

function Format-DiffOutput {
    param(
        [object[]]$FileComparisonResults
    )

    # �e�t�@�C���̔�r���ʂ��A�t�@�C��ID�ƍs�ԍ��ō����ɎQ�Ƃł���悤�A�n�b�V���e�[�u���̔z��ɍč\�����܂��B
    $fileDataMaps = 0..$FileComparisonResults.Count | ForEach-Object { @{} }

    foreach ($comparisonResult in $FileComparisonResults) {
        foreach ($obj in $comparisonResult) {
            # $obj.SourceFile �� 0 (�) �܂��� 1, 2, ... (�e�t�@�C��) �������B
            # �Ή�����SourceFile ID�̃n�b�V���e�[�u���ɁALineNumber���L�[�Ƃ��ăI�u�W�F�N�g���i�[����B
            $fileDataMaps[$obj.SourceFile][$obj.LineNumber] = $obj
        }
    }

    # --- �s�ԍ����ɏo�̓e�L�X�g�𐮌` ---
    $fileCount = $fileDataMaps.Count
    $lineCounters = @(1) * $fileCount # �e�t�@�C���̌��ݍs��ǐՂ���z�� (�����l��1)

    # ��v�s����ɁA�S�t�@�C���̍s�𓯊������Ȃ��烋�[�v����
    while ($true) {
        # �菇 1: �I������
        # ��I�u�W�F�N�g(ID=0)�Ɗe��r�Ώۃt�@�C��(ID>0)�ɂ��āA���Ō�܂ŏ������ꂽ��A���ׂĂ̏����������B
        $noneCount = 0
        for ($fileIndex = 0; $fileIndex -lt $fileCount; $fileIndex++) {
            if (-not $fileDataMaps[$fileIndex][$lineCounters[$fileIndex]]) {
                $noneCount++
            }
            # Write-Verbose "�I������ $i $($lineCounters[$i]) $noneCount"
        }
        if ($noneCount -eq $fileCount) {
            break
        }

        # �菇 2: �����s�i�ǉ����ꂽ�s�j�̏���
        # �e��r�Ώۃt�@�C���iID > 0�j�ɂ��āA���̈�v�s�ɓ��B����܂ł̍����s�iSideIndicator�� '=>'�j�����ׂďo�͂���B
        for ($fileIndex = 1; $fileIndex -lt $fileCount; $fileIndex++) {
            # ���̃��[�v�́A���݂̃t�@�C��($fileIndex)�̘A�����鍷���s�����ׂď�������B
            # $fileDataMaps[$fileIndex] �ɂ� '=>' �̍s�����܂܂�Ȃ��͂��ł��邪�A
            # �o�O�����O���āA�\�����Ȃ��f�[�^�ɋC�t����悤�ɃG���[���O�o�͂����Ă����B
            while ($fileDataMaps[$fileIndex].ContainsKey($lineCounters[$fileIndex])) {
                $diffObject = $fileDataMaps[$fileIndex][$lineCounters[$fileIndex]]

                if ($diffObject.SideIndicator -eq '=>') {
                    # ���̃t�@�C���ɂ̂ݑ��݂���u�ǉ��s�v���o��
                    Format-OutputLine -LineObject $diffObject -Indicator '>' -LineCounters $lineCounters -FileCount $fileCount -CurrentFileIndex $fileIndex
                }
                else {
                    # �z��O�̃f�[�^�̓G���[�Ƃ��ĕ�
                    Write-Error "�\�����Ȃ��f�[�^: SourceFile=$fileIndex Line=$($lineCounters[$fileIndex]) $($diffObject | Out-String)"
                }

                # ���̃t�@�C���̃J�E���^�̂ݐi�߂�
                $lineCounters[$fileIndex]++
            }
        }

        # �菇 3: ��v�s�̏���
        # ��I�u�W�F�N�g�iID=0�j���玟�̈�v�s���擾���ď�������B
        $commonLineObject = $fileDataMaps[0][$lineCounters[0]]
        if ($commonLineObject) {
            if ($commonLineObject.SideIndicator -eq '==') {
                # ���ׂẴt�@�C���ɋ��ʂ���u��v�s�v
                if ($IncludeMatch.IsPresent) {
                    Format-OutputLine -LineObject $commonLineObject -Indicator ' ' -LineCounters $lineCounters -FileCount $fileCount
                }
            }
            else {
                # �z��O�̃f�[�^�̓G���[�Ƃ��ĕ�
                # ��I�u�W�F�N�g�͈�v�s�݂̂̂͂��Ȃ̂ŁA"<="��"=>"�͏o�����Ȃ��z��B
                Write-Error "�\�����Ȃ��f�[�^����I�u�W�F�N�g���Ɍ�����܂���: $($commonLineObject | Out-String)"
            }

            # �菇 4: �J�E���^�̓���
            # ��v�s�̏��������������̂ŁA���ׂẴt�@�C���̃J�E���^��1�i�߂�B
            # ����ɂ��A�e�t�@�C���̃|�C���^�����̈�v�s�̒���Ɉړ����A�������ۂ����B
            for ($fileIndex = 0; $fileIndex -lt $fileCount; $fileIndex++) {
                $lineCounters[$fileIndex]++
            }
        }
    }
}

function Write-OutputContent {
    param(
        [object[]]$Content
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

function Get-FileComparisonResults {
    param(
        [string[]]$FilePaths,
        [string[]]$MatchingLines
    )
    Write-Verbose "�e�t�@�C�����r��"
    $referenceObject = @(Get-ContentFromLines -MatchingLines $MatchingLines -SourceFileId 0)
    # Write-Verbose "referenceObject: $(Format-DebugString $referenceObject)"

    # �e�t�@�C�����r���A���̌���(�I�u�W�F�N�g�z��)���܂Ƃ߂� $fileComparisonResults �Ɋi�[���܂��B
    # ���[�v���� += ���g�������p�t�H�[�}���X�����サ�܂��B
    $fileComparisonResults = for ($i = 0; $i -lt $FilePaths.Count; $i++) {
        $resolvedFilePath = $FilePaths[$i]
        $sourceFileId = $i + 1
        $differenceObject = @(Get-ContentFromFile -Path $resolvedFilePath -SourceFileId $sourceFileId)

        # Compare-FileObject�̌��ʂ̓I�u�W�F�N�g�̃R���N�V������Ԃ��܂��B
        # �J���}���Z�q��擪�ɒu�����ƂŁA�e��r���ʂ�z��̐V�����v�f�Ƃ��Č����I�ɒǉ����܂��B
        , (Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject)
    }
    return $fileComparisonResults
}

try {
    # ���[�e�B���e�B�֐���ǂݍ���
    . "$PSScriptRoot\Debug.ps1"

    # .NET�̃J�����g�f�B���N�g����PowerShell�̃J�����g�f�B���N�g���ɓ���������
    # ����ɂ��A[System.IO.Path]::GetFullPath() �����Ғʂ�ɓ��삷��
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # ���̓p�X�������i���C���h�J�[�h�ƃt�H���_�W�J�j
    # -ErrorAction Stop ���w�肵�āA�p�X��������Ȃ��ꍇ��catch�u���b�N�ŏ����ł���悤�ɂ���
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique

    # ��r����t�@�C����2�ȏ゠�邩�m�F
    if ($resolvedFilePaths.Count -lt 2) {
        throw "��r�Ώۂ̃t�@�C����2�ȏ㌩����܂���ł����B�w�肳�ꂽ�p�X���m�F���Ă��������B"
    }

    # ���ׂĂ̓��̓t�@�C�������v�s�𒊏o
    Write-Verbose "��v�s�𒊏o��"
    $matchingLines = @(Find-MatchingLines -FilePaths $resolvedFilePaths)
    # Write-Verbose "matchingLines: $(Format-DebugString $matchingLines)"

    # -MatchOnly���w�肳��Ă���ꍇ�́A��v�s���o�͂��ďI��
    if ($MatchOnly.IsPresent) {
        Write-OutputContent -Content $matchingLines
        return
    }

    # ��v�s�Ɗe�t�@�C�����r���A�ڍׂȔ�r���ʃf�[�^�𐶐����܂��B
    $fileComparisonResults = Get-FileComparisonResults -FilePaths $resolvedFilePaths -MatchingLines $matchingLines

    # ���ʂ��o��
    Write-Verbose "���ʏo�͒�"
    $formattedDifferences = Format-DiffOutput -FileComparisonResults $fileComparisonResults
    if (-not $formattedDifferences) { $formattedDifferences = @() }
    Write-OutputContent -Content $formattedDifferences
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
