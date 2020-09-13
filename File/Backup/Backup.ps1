<#
.SYNOPSIS
�t�@�C����t�H���_���o�b�N�A�b�v���܂��B

.DESCRIPTION
���̃X�N���v�g�́A�t�@�C����t�H���_���A�R�s�[���A���O�Ƀ^�C���X�^���v��t���܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
Backup.ps1 D:\tmp\dummy.txt
#>

[CmdletBinding()]
param (
  [string]$path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# �w���v
if (!$path) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �o�b�N�A�b�v�p�X��g�ݗ���
$path = $path -replace "\\+$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
if (Test-Path $path -PathType container) {
  # �t�H���_
  $outpath = $path + "_bk${timestamp}"
} elseif (Test-Path $path -PathType leaf) {
  if ($path -match "\.[^\.\\]*$") {
    # �t�@�C���E�g���q����
    $outpath = $path -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
  } else {
    # �t�@�C���E�g���q�Ȃ�
    $outpath = $path + "_bk${timestamp}"
  }
} else {
  throw "�Ώۃt�@�C��/�t�H���_��������܂���B${path}"
}

# �R�s�[��`�F�b�N
if (Test-Path $outpath) {
  throw "�o�b�N�A�b�v��p�X�����݂��܂��B${outpath}"
}

# �R�s�[���{
Copy-Item $path -Destination $outpath -Recurse -Verbose
Write-Output "�o�b�N�A�b�v���܂����B$outpath"
