<#
.SYNOPSIS
ショートカットを作成します。

.DESCRIPTION
このスクリプトは、Windowsの「送る」メニューに、ResizeImageスクリプトへのショートカットを作成します。
エラー処理は、ほぼ考慮していません。
<CommonParameters> は、サポートしていません。

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
  $shortcut.WindowStyle = 7 #最小化
  $shortcut.IconLocation = "powershell.exe"
  $shortcut.Save()
  Write-Output "作成しました。${shortcutpath}"
}

CreateShortcut 160 120 #QQVGA (Quarter QVGA)
CreateShortcut 300 200
CreateShortcut 320 240 #QVGA (Quarter VGA)
CreateShortcut 640 480 #VGA
#CreateShortcut 800 600 #SVGA (Super VGA)
