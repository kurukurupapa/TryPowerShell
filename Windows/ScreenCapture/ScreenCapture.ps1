<#
.SYNOPSIS
画面キャプチャを撮るPowerShellスクリプトです。

.DESCRIPTION
画面キャプチャを撮るPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
ScreenCapture.ps1 "0,0,1024,768" "D:\tmp\capture.png"
#>

[CmdletBinding()]
Param(
  <#
    キャプチャする領域。
    矩形領域の場合、"left,top,width,height"で指定する（例："0,0,1024,768"）。
    プライマリモニターの場合、"Primary"を指定する。
    全モニターの場合、"All"を指定する。
    マウスドラッグで範囲指定する場合、"Drag"を指定する。
  #>
  [string]$Area,
  <# 保存先ファイル #>
  [string]$OutPath,
  <# クリップボードへコピーする場合に指定する。 #>
  [switch]$Clipboard,
  <# キャプチャ間隔（秒） #>
  [int]$Interval,
  <# 繰り返し回数 #>
  [int]$Repetition
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
. "$psDir\Func.ps1"

# ヘルプ
if (!$Area -or (!$OutPath -and !$Clipboard)) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"
Main $Area $OutPath $Clipboard $Interval $Repetition
Write-Verbose "$psName End"
