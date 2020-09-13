<#
.SYNOPSIS
「送る」メニューにショートカットを作成します。

.DESCRIPTION
このスクリプトは、Windowsの「送る」メニューに、Powershellスクリプト/関連バッチのショートカットを作成します。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.PARAMETER name
「送る」メニューに表示する名前。ショートカット（lnkファイル）のファイル名になる。

.PARAMETER targetpath
リンク先Powershellスクリプト/関連バッチの絶対パス。

.PARAMETER targetargs
リンク先へ渡す引数。複数指定する場合、引数全体をダブルクォーテーションで括る。

.PARAMETER windowstyle
ショートカット実行時のウインドウスタイル。
1:通常、2:最大化、7:最小化。デフォルト 1:通常。

.EXAMPLE
CreateSendto.ps1 sample "D:\tmp\ps_wrapper.bat"

.EXAMPLE
CreateSendto.ps1 sample powershell.exe '-ExecutionPolicy RemoteSigned -File "D:\tmp\sample.ps1"'

Windowsコマンドプロンプトから実行する場合
> powershell -ExecutionPolicy RemoteSigned -File CreateSendto.ps1 sample powershell.exe " -ExecutionPolicy RemoteSigned -File \"D:\tmp\sample.ps1\""
※この例の場合、「-ExecutionPolicy」の前に空白を含めるなどしないと、ダブルクォーテーションで括った引数が、最も左のpowershellコマンドの引数として解釈されてしまう。
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

# ヘルプ
if (!$name -or !$targetpath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 準備
Write-Debug "name=${name}"
Write-Debug "targetpath=${targetpath}"
Write-Debug "targetargs=${targetargs}"
Write-Debug "windowstyle=${windowstyle}"
$sendtodir = [Environment]::GetFolderPath([Environment+SpecialFolder]::SendTo)
$shortcutpath = Join-Path $sendtodir "${name}.lnk"

# ショートカット作成
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutpath)
$shortcut.TargetPath = $targetpath
$shortcut.Arguments = $targetargs
$shortcut.WindowStyle = $windowstyle
$shortcut.IconLocation = "powershell.exe"
$shortcut.Save()
Write-Output "作成しました。${shortcutpath}"
