<#
.SYNOPSIS
�u����v���j���[�ɃV���[�g�J�b�g���쐬���܂��B

.DESCRIPTION
���̃X�N���v�g�́AWindows�́u����v���j���[�ɁAPowershell�X�N���v�g/�֘A�o�b�`�̃V���[�g�J�b�g���쐬���܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.PARAMETER name
�u����v���j���[�ɕ\�����閼�O�B�V���[�g�J�b�g�ilnk�t�@�C���j�̃t�@�C�����ɂȂ�B

.PARAMETER targetpath
�����N��Powershell�X�N���v�g/�֘A�o�b�`�̐�΃p�X�B

.PARAMETER targetargs
�����N��֓n�������B�����w�肷��ꍇ�A�����S�̂��_�u���N�H�[�e�[�V�����Ŋ���B

.PARAMETER windowstyle
�V���[�g�J�b�g���s���̃E�C���h�E�X�^�C���B
1:�ʏ�A2:�ő剻�A7:�ŏ����B�f�t�H���g 1:�ʏ�B

.EXAMPLE
CreateSendto.ps1 sample "D:\tmp\ps_wrapper.bat"

.EXAMPLE
CreateSendto.ps1 sample powershell.exe '-ExecutionPolicy RemoteSigned -File "D:\tmp\sample.ps1"'

Windows�R�}���h�v�����v�g������s����ꍇ
> powershell -ExecutionPolicy RemoteSigned -File CreateSendto.ps1 sample powershell.exe " -ExecutionPolicy RemoteSigned -File \"D:\tmp\sample.ps1\""
�����̗�̏ꍇ�A�u-ExecutionPolicy�v�̑O�ɋ󔒂��܂߂�Ȃǂ��Ȃ��ƁA�_�u���N�H�[�e�[�V�����Ŋ������������A�ł�����powershell�R�}���h�̈����Ƃ��ĉ��߂���Ă��܂��B
#>

[CmdletBinding()]
param(
  [string]$name,
  [string]$targetpath,
  [string]$targetargs,
  [int]$windowstyle = 1
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
#$DebugPreference = "Continue"

# �w���v
if (!$name -or !$targetpath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# ����
Write-Debug "name=${name}"
Write-Debug "targetpath=${targetpath}"
Write-Debug "targetargs=${targetargs}"
Write-Debug "windowstyle=${windowstyle}"
$sendtodir = [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo)
$shortcutpath = Join-Path $sendtodir "${name}.lnk"

# �V���[�g�J�b�g�쐬
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutpath)
$shortcut.TargetPath = $targetpath
$shortcut.Arguments = $targetargs
$shortcut.WindowStyle = $windowstyle
$shortcut.IconLocation = "powershell.exe"
$shortcut.Save()
Write-Output "�쐬���܂����B${shortcutpath}"
