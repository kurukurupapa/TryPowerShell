<#
.SYNOPSIS
FileEncryption.ps1�ňÍ������ꂽ�e�L�X�g�t�@�C���𕜍������܂��B

.DESCRIPTION
���̃X�N���v�g�́AFileEncryption.ps1�ňÍ������ꂽ�e�L�X�g�t�@�C���𕜍������܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
FieDecryption.ps1 D:\tmp\dummy.enc.json
#>

[CmdletBinding()]
param (
  [string]$InPath,
  [string]$OutPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# ���̓p�X�`�F�b�N
if (!(Test-Path $InPath -PathType leaf)) {
  throw "���̓t�@�C����������܂���B${InPath}"
}
# �o�̓`�F�b�N
if (!$OutPath) {
  # TODO �ȈՓI�Ȏ���
  $OutPath = ($InPath -replace "\.enc\.json$", "") + ".dec.txt"
}
# TODO �o�̓p�X���݃`�F�b�N���邩�H
# if (Test-Path $OutPath) {
#   throw "�o�̓p�X�����݂��܂��B${OutPath}"
# }

# ���̓t�@�C���̓ǂݍ��݁E������
# TODO �G���[�������ɓ��̓t�@�C���`�������؂蕪������
$json = Get-Content $InPath | ConvertFrom-Json
# if ($json.Tool -ne 'FileEncryption.ps1') {
#   # �G���[
# }
$secureString = ConvertTo-SecureString $json.Encrypted
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)

# �t�@�C���ۑ�
# -NoNewline�I�v�V������PowerShell 5.0�ȍ~�Ŏg�p�\
Set-Content $OutPath $decryptedString -NoNewline
Write-Output "���������܂����B$OutPath"
