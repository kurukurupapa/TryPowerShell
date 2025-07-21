<#
.SYNOPSIS
    �e�L�X�g�t�@�C�����w�肵�������ŕ����̃t�@�C���ɕ������܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A���̓e�L�X�g�t�@�C����ǂݍ��݁A�w�肳�ꂽ�s���܂��͐��K�\���Ɉ�v����s����؂�Ƃ��āA�����̃t�@�C���ɕ������܂��B
    �������@�́A�s���w��i-LineCount�j�A�܂��͐��K�\���i-SplitBefore, -SplitAfter�j�̂����ꂩ��I�����܂��B
    ���ʂ́A�w�肳�ꂽ�o�̓f�B���N�g���i�f�t�H���g�͓��̓t�@�C���Ɠ����f�B���N�g���j�ɁA���̃t�@�C�����ɘA�Ԃ�t�^�����`�ŕۑ�����܂��B

.PARAMETER Path
    ����������̓t�@�C���̃p�X���w�肵�܂��B

.PARAMETER LineCount
    ���̃p�����[�^���w�肷��ƁA�t�@�C�����s���ŕ������܂��B
    �w�肵���s�����ƂɐV�����t�@�C�����쐬����܂��B

.PARAMETER SplitBefore
    ���̃p�����[�^���w�肷��ƁA���K�\���Ɉ�v����s�́y�O�z�Ńt�@�C���𕪊����܂��B
    ��v�����s�́A�V�����t�@�C���̐擪�s�ɂȂ�܂��B

.PARAMETER SplitAfter
    ���̃p�����[�^���w�肷��ƁA���K�\���Ɉ�v����s�́y��z�Ńt�@�C���𕪊����܂��B
    ��v�����s�́A���݂̃t�@�C���̍ŏI�s�ɂȂ�܂��B

.PARAMETER OutputDirectory
    ���������t�@�C����ۑ�����f�B���N�g���̃p�X���w�肵�܂��B�w�肵�Ȃ��ꍇ�A���̓t�@�C���Ɠ����f�B���N�g���ɏo�͂���܂��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'UTF8' �ł��B

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'C:\logs\large_log.txt' -LineCount 100
    'C:\logs\large_log.txt' ��100�s���̃t�@�C���ɕ������A'C:\logs' �f�B���N�g���� 'large_log_00001.txt', 'large_log_00002.txt'... �Ƃ��ĕۑ����܂��B

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'data.csv' -SplitBefore '^HEADER,'
    'data.csv' �̒��� 'HEADER,' �Ŏn�܂�s�������邽�тɐV�����t�@�C�����J�n���A'data.csv' �Ɠ����f�B���N�g���� 'data_00001.csv', 'data_00002.csv'... �Ƃ��ĕۑ����܂��B

.EXAMPLE
    .\File\Diff\SplitText.ps1 -Path 'C:\logs\app.log' -SplitAfter 'Session End' -OutputDirectory 'C:\logs\output'
    'C:\logs\app.log' �̒��� 'Session End' �Ƃ�����������܂ލs�������邽�тɃt�@�C���𕪊����A���ʂ� 'C:\logs\output' �f�B���N�g���ɕۑ����܂��B

.NOTES
    �傫�ȃt�@�C���������I�ɏ������邽�߂ɁA.NET��StreamReader�N���X���g�p���Ă��܂��B
    ����ɂ��A�t�@�C���S�̂��������ɓǂݍ��ނ��ƂȂ��A��s���������邱�Ƃ��ł��܂��B
    �p�����[�^�Z�b�g�@�\�ɂ��A-LineCount, -SplitBefore, -SplitAfter �͓����Ɏw��ł��܂���B
#>
[CmdletBinding(DefaultParameterSetName = 'LineCountSet')]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '����������̓t�@�C���̃p�X���w�肵�܂��B')]
    [string]$Path,

    [Parameter(Mandatory = $true, ParameterSetName = 'LineCountSet', HelpMessage = '���̃p�����[�^���w�肷��ƁA�t�@�C�����s���ŕ������܂��B')]
    [int]$LineCount,

    [Parameter(Mandatory = $true, ParameterSetName = 'SplitBeforeSet', HelpMessage = '�w�肵�����K�\���Ɉ�v����s�́y�O�z�Ńt�@�C���𕪊����܂��B��v�s�͐V�����t�@�C���̐擪�ɂȂ�܂��B')]
    [string]$SplitBefore,

    [Parameter(Mandatory = $true, ParameterSetName = 'SplitAfterSet', HelpMessage = '�w�肵�����K�\���Ɉ�v����s�́y��z�Ńt�@�C���𕪊����܂��B��v�s�͌��݂̃t�@�C���̖����ɂȂ�܂��B')]
    [string]$SplitAfter,

    [Parameter(Mandatory = $false, HelpMessage = "���������t�@�C����ۑ�����f�B���N�g���̃p�X���w�肵�܂��B�w�肵�Ȃ��ꍇ�A���̓t�@�C���Ɠ����f�B���N�g���ɏo�͂���܂��B")]
    [string]$OutputDirectory,

    [Parameter(Mandatory = $false, HelpMessage = "���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'Default' �ł��B")]
    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)

function Write-SplitFile {
    [CmdletBinding()]
    param(
        [string]$Directory,
        [string]$BaseName,
        [string]$Extension,
        [int]$Index,
        [System.Collections.Generic.List[string]]$Lines,
        [System.Text.Encoding]$EncodingObject
    )
    $fileName = "$($BaseName)_$($Index.ToString('D5'))$($Extension)"
    $outputPath = Join-Path -Path $Directory -ChildPath $fileName
    Write-Verbose "�t�@�C���ɏ������ݒ� ($($Lines.Count) �s): $outputPath"
    [System.IO.File]::WriteAllLines($outputPath, $Lines, $EncodingObject)
}

try {
    # ���̓p�X���΃p�X�ɕϊ����āA�B�������Ȃ���
    $absolutePath = Resolve-Path -Path $Path -ErrorAction Stop

    # ���̓t�@�C���̑��݊m�F
    if (-not (Test-Path -Path $absolutePath -PathType Leaf)) {
        throw "�w�肳�ꂽ���̓t�@�C����������܂���: $absolutePath"
    }

    $inputFileInfo = Get-Item -Path $absolutePath
    $baseName = $inputFileInfo.BaseName # �g���q�Ȃ��̃t�@�C����
    $extension = $inputFileInfo.Extension # �g���q
    $fileIndex = 1

    # �o�̓f�B���N�g��������
    $destinationPath = $inputFileInfo.DirectoryName
    if ($PSBoundParameters.ContainsKey('OutputDirectory')) {
        $destinationPath = $OutputDirectory
        # �w�肳�ꂽ�p�X�����݂��Ȃ��ꍇ�͍쐬
        if (-not (Test-Path -Path $destinationPath -PathType Container)) {
            Write-Verbose "�o�̓f�B���N�g�����쐬���܂�: $destinationPath"
            New-Item -Path $destinationPath -ItemType Directory -Force | Out-Null
        }
        # ��ɐ�΃p�X�ň���
        $destinationPath = (Resolve-Path -Path $destinationPath).Path
    }

    # �o�͗p�̃G���R�[�f�B���O�I�u�W�F�N�g������
    # 'UTF8' ��BOM�Ȃ��A'Default' �̓V�X�e���̊���i���{����ł͒ʏ�Shift_JIS�j
    $outputEncodingObject = switch ($Encoding) {
        'UTF8' { New-Object System.Text.UTF8Encoding($false) } # BOM�Ȃ�
        'Default' { [System.Text.Encoding]::Default }
    }

    # �ǂݍ��ݗp�̃G���R�[�f�B���O�I�u�W�F�N�g������
    # [System.Text.Encoding]::UTF8 ��BOM���������ʂ��邽�߁ABOM�̗L�����ӎ�����K�v�͂Ȃ�
    $readEncodingObject = switch ($Encoding) {
        'UTF8' { [System.Text.Encoding]::UTF8 }
        'Default' { [System.Text.Encoding]::Default }
    }

    Write-Verbose "�t�@�C���̓ǂݍ��݂��J�n���܂�: $absolutePath (�o�͐�: $destinationPath)"
    $reader = [System.IO.StreamReader]::new($absolutePath, $readEncodingObject)

    try {
        $lineBuffer = New-Object System.Collections.Generic.List[string]

        while ($null -ne ($line = $reader.ReadLine())) {
            # --- �������� (���݂̍s���o�b�t�@�ɒǉ�����O) ---
            $splitBeforeAdd = $false
            if ($PSCmdlet.ParameterSetName -eq 'LineCountSet') {
                if ($lineBuffer.Count -gt 0 -and $lineBuffer.Count % $LineCount -eq 0) {
                    $splitBeforeAdd = $true
                }
            }
            elseif ($PSCmdlet.ParameterSetName -eq 'SplitBeforeSet') {
                if ($lineBuffer.Count -gt 0 -and $line -match $SplitBefore) {
                    $splitBeforeAdd = $true
                }
            }

            if ($splitBeforeAdd) {
                Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
                $lineBuffer.Clear()
                $fileIndex++
            }

            # --- ���݂̍s���o�b�t�@�ɒǉ� ---
            $lineBuffer.Add($line)

            # --- �������� (���݂̍s���o�b�t�@�ɒǉ�������) ---
            $splitAfterAdd = $false
            if ($PSCmdlet.ParameterSetName -eq 'SplitAfterSet') {
                if ($line -match $SplitAfter) {
                    $splitAfterAdd = $true
                }
            }

            if ($splitAfterAdd) {
                Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
                $lineBuffer.Clear()
                $fileIndex++
            }
        }

        # �o�b�t�@�Ɏc�����Ō�̍s�������o��
        if ($lineBuffer.Count -gt 0) {
            Write-SplitFile -Directory $destinationPath -BaseName $baseName -Extension $extension -Index $fileIndex -Lines $lineBuffer -EncodingObject $outputEncodingObject
        }
    }
    finally {
        if ($reader) { $reader.Dispose() }
    }

    Write-Host "�t�@�C���̕������������܂����B"
}
catch {
    Write-Error "�G���[���������܂���: $_"
}
