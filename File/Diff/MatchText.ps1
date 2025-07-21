<#
.SYNOPSIS
    2�̃e�L�X�g�t�@�C�����r���A�����̃t�@�C���ɑ��݂���s�𒊏o���܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A2�̓��̓e�L�X�g�t�@�C����ǂݍ��݁A�����̃t�@�C���ɋ��ʂ��đ��݂���s�������o���܂��B
    ���ʂ́A�W���o�͂ɏ����o����邩�A�w�肳�ꂽ�o�̓t�@�C���ɕۑ�����܂��B

.PARAMETER Path1
    ��r���̃t�@�C���p�X���w�肵�܂��B

.PARAMETER Path2
    ��r�Ώۂ̃t�@�C���p�X���w�肵�܂��B

.PARAMETER OutputPath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X�B�w�肵�Ȃ��ꍇ�A���ʂ͕W���o�͂ɕ\������܂��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'Default' �ł��B

.EXAMPLE
    .\MatchText.ps1 -Path1 file1.txt -Path2 file2.txt
    2�̃t�@�C���̋��ʍs��W���o�͂ɕ\�����܂��B

.EXAMPLE
    .\MatchText.ps1 -Path1 file1.txt -Path2 file2.txt -OutputPath common_lines.txt
    2�̃t�@�C���̋��ʍs�� 'common_lines.txt' �ɏo�͂��܂��B
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '��r���̃t�@�C���p�X���w�肵�܂��B')]
    [string]$Path1,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = '��r�Ώۂ̃t�@�C���p�X���w�肵�܂��B')]
    [string]$Path2,

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = '���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B')]
    [string]$OutputPath,

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)
try {
    # ��r���̃t�@�C����ǂݍ���
    if (-not (Test-Path -Path $Path1 -PathType Leaf)) {
        throw "�t�@�C����������܂���: $Path1"
    }
    Write-Verbose "1�ڂ̃t�@�C����ǂݍ��ݒ�: $Path1"
    $referenceObject = @(Get-Content -Path $Path1 -Encoding $Encoding)

    # ��r�Ώۂ̃t�@�C����ǂݍ���
    if (-not (Test-Path -Path $Path2 -PathType Leaf)) {
        throw "�t�@�C����������܂���: $Path2"
    }
    Write-Verbose "2�ڂ̃t�@�C����ǂݍ��݁A��r��: $Path2"
    $differenceObject = @(Get-Content -Path $Path2 -Encoding $Encoding)

    # Compare-Object���g�p���ċ��ʍs�𒊏o���A���̍s�f�[�^�݂̂����o��
    $matchingLines = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue

    # ���ʂ��o��
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # �W���o�͂�
        $matchingLines
    }
    else {
        # �t�@�C���֏o��
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        # WriteAllLines��string[]��v�����邽�߁A���ʂ��P��̕������$null�̏ꍇ�ł��z��ɕϊ����܂��B
        [System.IO.File]::WriteAllLines($OutputPath, @($matchingLines), $encodingObject)
        Write-Verbose "��v�����s�� $OutputPath �ɏo�͂��܂����B"
    }
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
