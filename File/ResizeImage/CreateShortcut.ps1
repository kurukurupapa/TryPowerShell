<#
.SYNOPSIS
�V���[�g�J�b�g���쐬���܂��B

.DESCRIPTION
���̃X�N���v�g�́AWindows�́u����v���j���[�ɁAResizeImage�X�N���v�g�ւ̃V���[�g�J�b�g���쐬���܂��B
�G���[�����́A�قڍl�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
CreateShortcut.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function CreateShortcut($w, $h) {
  $sendtodir = [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo)
  $shortcutpath = Join-Path $sendtodir "ResizeImage_${w}x${h}.lnk"
  $scriptpath = Join-Path (Split-Path $MyInvocation.ScriptName -Parent) "ResizeImage.bat"

  $shell = New-Object -ComObject WScript.Shell
  $shortcut = $shell.CreateShortcut($shortcutpath)
  $shortcut.TargetPath = $scriptpath
  $shortcut.Arguments = "-Width ${w} -Height ${h} -Path"
  $shortcut.WindowStyle = 7 #�ŏ���
  $shortcut.IconLocation = "powershell.exe"
  $shortcut.Save()
  Write-Output "�쐬���܂����B${shortcutpath}"
}

CreateShortcut 160 120 #QQVGA (Quarter QVGA)
CreateShortcut 300 200
CreateShortcut 320 240 #QVGA (Quarter VGA)
CreateShortcut 640 480 #VGA
#CreateShortcut 800 600 #SVGA (Super VGA)
