<#
.SYNOPSIS
�e�L�X�g�t�@�C�����ȈՓI�ɈÍ������܂��B

.DESCRIPTION
���̃X�N���v�g�́A�e�L�X�g�t�@�C���ɑ΂��āAPowershell�ɂ��ȈՓI�ȈÍ������s���܂��B
�Í���/�������͓������[�U�Ŏ��s����K�v������܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
FieEncryption.ps1 D:\tmp\dummy.txt
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
  $OutPath = ($InPath -replace "\.[^\.\\]*$", "") + ".enc.json"
}
# TODO �o�̓p�X���݃`�F�b�N���邩�H
# if (Test-Path $OutPath) {
#   throw "�o�̓p�X�����݂��܂��B${OutPath}"
# }

# ���̓t�@�C���̓ǂݍ��݁E�Í���
$encrypted = Get-Content $InPath -Raw | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString

# �t�@�C���ۑ�
ConvertTo-Json @{
  Tool = 'FileEncryption.ps1'
  FileName = Split-Path $InPath -Leaf
  Encrypted = $encrypted
  } | Set-Content $OutPath
Write-Output "�Í������܂����B$OutPath"
