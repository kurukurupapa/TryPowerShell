<#
.SYNOPSIS
PowerShellスクリプトのテンプレートです。

.DESCRIPTION
このスクリプトは、PowerShellスクリプトのテンプレートです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
Template2.ps1 "D:\tmp\indir"
$DebugPreference='Continue'; Template2.ps1 -Verbose "D:\tmp\indir"
#>

[CmdletBinding()]
Param(
  [string]$InPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$baseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ユーティリティ呼び出し
. (Join-Path $psDir "${baseName}_util.ps1")

# メイン処理
function Main($InPath) {
  ErrLog "ERRORログです"
  WarnLog "WARNINGログです"
  InfoLog "INFORMATIONログです"
  TraceLog "TRACEログです"
  DebugLog "DEBUGログです"
  Write-Output "timestamp=$timestamp"
  Write-Output "`$ini.dummy=$($ini.dummy)"

  # if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  #   throw "入力元/出力先が見つからないか、ディレクトリではありません。"
  # }
  # Get-ChildItem $inPath -Recurse -File | % {
  #   $path = $_.FullName.Replace($inPath, $outPath)
  #   $dir = Split-Path $path -Parent
  #   InfoLog "処理開始 $($_.FullName)"
  #   if (!(Test-Path $dir -PathType Container)) {
  #     New-Item $dir -ItemType Directory | Out-Null
  #   }
  #   Get-Content $_.FullName | Set-Content $path
  # }

  Get-ChildItem $inPath -Recurse -File | ForEach-Object {
    Write-Output $_.FullName
  }
}

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"
Main $InPath
Write-Verbose "$psName End"
