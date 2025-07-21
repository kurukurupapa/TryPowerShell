<#
.SYNOPSIS
�����̃e�L�X�g�t�@�C����1�̃t�@�C���ɘA�����܂��B

.DESCRIPTION
�w�肳�ꂽ�����̓��̓t�@�C�����A�w�肳�ꂽ1�̏o�̓t�@�C���ɏ��ԂɘA�����܂��B

.PARAMETER InputPath
�A�����������̓t�@�C���̃p�X�B�����w��⃏�C���h�J�[�h�i*.txt�Ȃǁj���g�p�\�ł��B

.PARAMETER OutputPath
�A�����ʂ�ۑ�����o�̓t�@�C���̃p�X�B

.PARAMETER Encoding
���̓t�@�C���Əo�̓t�@�C���̕����G���R�[�f�B���O���w�肵�܂��B
�f�t�H���g�� "Default" (�V�X�e���̊���̃G���R�[�f�B���O) �ł��B�w��\�Ȓl: UTF8, Default

.EXAMPLE
# file1.txt �� file2.txt �� combined.txt �ɘA������
.\JoinText.ps1 -InputPath file1.txt, file2.txt -OutputPath combined.txt

.EXAMPLE
# �J�����g�f�B���N�g���̂��ׂĂ� .log �t�@�C���� all_logs.txt �ɘA������
.\JoinText.ps1 -InputPath *.log -OutputPath all_logs.txt

.EXAMPLE
# 'Logs' �t�H���_���̂��ׂẴt�@�C���� all_logs.txt �ɘA������
.\JoinText.ps1 -InputPath .\Logs\ -OutputPath all_logs.txt

.EXAMPLE
# Default(Shift_JIS)�ŃG���R�[�h���ꂽ�t�@�C����ǂݍ��݁ADefault�ŏo�͂���
.\JoinText.ps1 -InputPath sjis_files\*.txt -OutputPath combined.sjis.txt -Encoding Default
#>
param(
    [Parameter(Mandatory = $true)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet("UTF8", "Default")]
    [string]$Encoding = 'Default'
)

# Get-ChildItem ���g���āA�t�@�C���A���C���h�J�[�h�A�t�H���_�w��𓝈�I�Ɉ����A
# ���݂���t�@�C���I�u�W�F�N�g�̃��X�g���擾���܂��B-File �X�C�b�`�Ńt�@�C���݂̂Ɍ��肵�܂��B
$filesToProcess = Get-ChildItem -Path $InputPath -File -ErrorAction SilentlyContinue
if (-not $filesToProcess) {
    Write-Warning "�A���Ώۂ̃t�@�C����������܂���ł����B"
    return
}

# ��������G���R�[�f�B���O�����肵�܂��BPowerShell�̃o�[�W�����ɂ���ċ������قȂ邽�߁A
# .NET���\�b�h�Ŏg�p����G���R�[�f�B���O�I�u�W�F�N�g���������܂��B
$writeEncoding = switch ($Encoding) {
    'Default' {
        # �V�X�e���̊���̃G���R�[�f�B���O(���{����ł͒ʏ�Shift_JIS)���擾���܂��B
        [System.Text.Encoding]::Default
    }
    'UTF8' {
        # BOM�Ȃ���UTF-8�G���R�[�f�B���O�I�u�W�F�N�g���쐬���܂��B
        New-Object System.Text.UTF8Encoding($false)
    }
}

try {
    # �o�͐�̃f�B���N�g�������݂��Ȃ��ꍇ�͍쐬���܂�
    $outputDirectory = Split-Path -Path $OutputPath -Parent
    if (-not (Test-Path -Path $outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
    }

    # �����̓��̓t�@�C���̓��e�����ׂă������ɓǂݍ��݂܂��B
    Write-Host "�ȉ��̃t�@�C�������ԂɘA�����܂�..."
    $allLines = $filesToProcess | ForEach-Object {
        Write-Host "- $($_.FullName)"
        Get-Content -Path $_.FullName -Encoding $Encoding
    }

    # .NET�̃��\�b�h���g�p���āA���W�������ׂĂ̍s����x�Ƀt�@�C���ɏ������݂܂��B
    # ���̃��\�b�h�͊����̃t�@�C���������I�ɏ㏑�����܂��B
    [System.IO.File]::WriteAllLines($OutputPath, $allLines, $writeEncoding)

    Write-Host "`n�t�@�C���̘A�����������܂���: $OutputPath"
}
catch {
    Write-Error "�t�@�C���̏������ݒ��ɃG���[���������܂���: $_"
}
