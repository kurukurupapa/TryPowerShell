<#
.SYNOPSIS
    �e�L�X�g�t�@�C���̕����G���R�[�h�Ɖ��s�R�[�h��ϊ����܂��B

.DESCRIPTION
    �w�肳�ꂽ���̓t�@�C����ǂݍ��݁A�w�肳�ꂽ�����G���R�[�h�Ɖ��s�R�[�h�ŐV�����t�@�C���ɏo�͂��܂��B

.PARAMETER InputPath
    �ϊ����̓��̓t�@�C���p�X���w�肵�܂��B

.PARAMETER OutputPath
    �ϊ���̏o�̓t�@�C���p�X���w�肵�܂��B

.PARAMETER InputEncoding
    ���̓t�@�C���̕����G���R�[�h���w�肵�܂��B
    �w��\�Ȓl: Default, SJIS, UTF8, UTF8BOM
    Default��SJIS��Shift_JIS�AUTF8��BOM�Ȃ��AUTF8BOM��BOM�����UTF-8�Ƃ��Ĉ����܂��B(�ǂݍ��ݎ��AUTF8/UTF8BOM��BOM�̗L�����������ʂ��܂�)

.PARAMETER OutputEncoding
    �o�̓t�@�C���̕����G���R�[�h���w�肵�܂��B
    �w��\�Ȓl: Default, SJIS, UTF8, UTF8BOM
    Default��SJIS��Shift_JIS�AUTF8��BOM�Ȃ�UTF-8�AUTF8BOM��BOM�t��UTF-8�ł��B

.PARAMETER NewLine
    �o�̓t�@�C���̉��s�R�[�h���w�肵�܂��B
    �w��\�Ȓl: CRLF, LF

.EXAMPLE
    # Shift_JIS(Default)�̃t�@�C�����ABOM�Ȃ�UTF-8�A���s�R�[�hLF�ɕϊ�����
    .\Convert-TextEncoding.ps1 -InputPath 'sjis_file.txt' -OutputPath 'utf8_file.txt' -InputEncoding Default -OutputEncoding UTF8 -NewLine LF

.EXAMPLE
    # UTF-8�̃t�@�C�����AShift_JIS(Default)�A���s�R�[�hCRLF�ɕϊ�����
    .\Convert-TextEncoding.ps1 -InputPath 'utf8_file.txt' -OutputPath 'sjis_file.txt' -InputEncoding UTF8 -OutputEncoding Default -NewLine CRLF

.EXAMPLE
    # �ڍׂȃ��O��\�����Ȃ���ϊ�����
    .\Convert-TextEncoding.ps1 -InputPath 'in.txt' -OutputPath 'out.txt' -OutputEncoding UTF8 -Verbose
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputPath,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Default', 'SJIS', 'UTF8', 'UTF8BOM')]
    [string]$InputEncoding = 'Default',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Default', 'SJIS', 'UTF8', 'UTF8BOM')]
    [string]$OutputEncoding = 'Default',

    [Parameter(Mandatory = $false)]
    [ValidateSet("CRLF", "LF")]
    [string]$NewLine = "CRLF"
)

try {
    # .NET�̃J�����g�f�B���N�g����PowerShell�̃J�����g�f�B���N�g���ɓ���������
    # ����ɂ��A[System.IO.Path]::GetFullPath() �����Ғʂ�ɓ��삷��
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # �p�X���΃p�X�ɉ�������
    # ���̓p�X�͑��݂���K�v�����邽�� Resolve-Path ���g�p ���G���[���b�Z�[�W��������ɂ����Ȃ�̂�GetFullPath���g�p
    # $absoluteInputPath = (Resolve-Path -Path $InputPath -ErrorAction Stop).ProviderPath
    $absoluteInputPath = [System.IO.Path]::GetFullPath($InputPath)
    # �o�̓p�X�͑��݂��Ȃ��\�������邽�߁A.NET���\�b�h�Ő�΃p�X�𐶐�
    $absoluteOutputPath = [System.IO.Path]::GetFullPath($OutputPath)

    # �t�@�C���̑��݃`�F�b�N
    if (-not (Test-Path -Path $absoluteInputPath -PathType Leaf)) {
        throw "���̓t�@�C����������܂���: $absoluteInputPath"
    }

    # ���s�R�[�h��ݒ�
    $newLineCode = switch ($NewLine) {
        "CRLF" { "`r`n" }
        "LF" { "`n" }
    }

    # Get-Content���󂯕t����G���R�[�f�B���O���ɕϊ�����
    $readEncoding = switch ($InputEncoding) {
        'SJIS' { 'Default' }
        'UTF8BOM' { 'UTF8' }
        default { $InputEncoding } # Default, UTF8
    }

    # �t�@�C����ǂݍ��� (-Raw�Ńt�@�C���S�̂�P��̕�����Ƃ��ēǂݍ���)
    Write-Verbose "���̓t�@�C����ǂݍ���ł��܂�..."
    $content = Get-Content -Path $absoluteInputPath -Encoding $readEncoding -Raw

    # ���s�R�[�h��LF�ɐ��K�����Ă���A�w��̉��s�R�[�h�ɕϊ�
    Write-Verbose "���s�R�[�h��ϊ����Ă��܂�..."
    $normalizedContent = $content.Replace("`r`n", "`n").Replace("`r", "`n")
    $convertedContent = $normalizedContent.Replace("`n", $newLineCode)

    # �w�肳�ꂽ�G���R�[�f�B���O�Ńt�@�C���ɏ����o��
    Write-Verbose "�ϊ���̃t�@�C�����o�͂��Ă��܂�..."
    # if ($OutputEncoding -eq 'UTF8NoBOM') {
    #     $encodingObject = New-Object System.Text.UTF8Encoding($false)
    #     [System.IO.File]::WriteAllText($OutputPath, $convertedContent, $encodingObject)
    # }
    # else {
    #     Set-Content -Path $OutputPath -Value $convertedContent -Encoding $OutputEncoding -NoNewline
    # }
    $encodingObject = switch ($OutputEncoding) {
        'UTF8' { New-Object System.Text.UTF8Encoding($false) } # BOM�Ȃ�
        'UTF8BOM' { New-Object System.Text.UTF8Encoding($true) }  # BOM�t��
        'SJIS' { [System.Text.Encoding]::GetEncoding('shift_jis') } # Shift_JIS
        'Default' { [System.Text.Encoding]::Default }             # �V�X�e���̊��� (���{����ł�Shift_JIS)
    }

    # .NET���\�b�h�͖����ɉ��s�������ǉ����Ȃ����߁A-NoNewline�͕s�v
    [System.IO.File]::WriteAllText($absoluteOutputPath, $convertedContent, $encodingObject)

    Write-Host "�ϊ�����������Ɋ������܂����B -> $absoluteOutputPath"
}
catch {
    Write-Error "�G���[���������܂���: $($_.Exception.Message)"
    exit 1
}
