<#
.SYNOPSIS
�N���b�v�{�[�h���̃e�L�X�g���ȈՓI�ɈÍ���/���������܂��B

.DESCRIPTION
���̃X�N���v�g�́A�N���b�v�{�[�h���̃e�L�X�g�ɑ΂��āAPowershell�ɂ��ȈՓI�ȈÍ���/���������s���܂��B
������̃e�L�X�g�́A�N���b�v�{�[�h�ɕۑ�����܂��B
�Í���/�������͓������[�U�Ŏ��s����K�v������܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
ClipboardEncryption.ps1 D:\tmp\dummy.txt
#>

[CmdletBinding()]
param (
  [Switch]$Help,
  [Switch]$Encryption,
  [Switch]$Decryption
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# �w���v
if ($Help) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

if (!$Decryption) {
  $Encryption = $true
}
if ($Encryption) {
  # �N���b�v�{�[�h�̓ǂݍ��݁E�Í���
  $encrypted = Get-Clipboard -Format Text -Raw | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
  # �N���b�v�{�[�h�ۑ�
  Set-Clipboard $encrypted
  Write-Output "�Í������܂����B"
} else {
  # �N���b�v�{�[�h�̓ǂݍ��݁E������
  $encrypted = Get-Clipboard -Format Text -Raw
  $secureString = ConvertTo-SecureString $encrypted
  $decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
  $decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
  # �N���b�v�{�[�h�ۑ�
  Set-Clipboard $decryptedString
  Write-Output "���������܂����B"
}
