# Windows PowerShell
# �e�X�g�����s����X�N���v�g�ł��B

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$sep = "#" * 70

# �e�X�g�Ώ�function�̓ǂݍ���
. $baseDir\EchoFunc.ps1

######################################################################
### �������s
######################################################################

Write-Output $sep
Write-Output "�����Ȃ��̃e�X�g"
#�|�b�v�A�b�v���͂��N������
#U-Echo

Write-Output $sep
Write-Output "��������̃e�X�g"
U-Echo "�e�X�g�ł�"
U-Echo "�e�X�g1", "�e�X�g2"

Write-Output $sep
Write-Output "�p�C�v���C���̃e�X�g"
"�e�X�g�ł�" | U-Echo
"�e�X�g1","�e�X�g2" | U-Echo

Write-Output $sep
Write-Output "�������p�C�v���C���̃e�X�g"
try {
    "�p�C�v���C���f�[�^" | U-Echo "�����f�[�^"
}
catch {
    Write-Output $_
}

Write-Output $sep
Write-Output "����NULL�̃e�X�g"
try {
    U-Echo $null
}
catch {
    Write-Output $_
}

Write-Output $sep
Write-Output "�p�C�v���C��NULL�̃e�X�g"
try {
    $null | U-Echo
}
catch {
    Write-Output $_
}

Write-Output $sep
