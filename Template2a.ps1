<#
.SYNOPSIS
PowerShellスクリプトのテンプレートです。（シンプル版）

.DESCRIPTION
このスクリプトは、PowerShellスクリプトのテンプレートです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir"
#>

[CmdletBinding()]
Param(
  [string]$inPath,
  [string]$outPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
#$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ヘルプ
if (!$inPath -and !$outPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"

if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  throw "入力元/出力先が見つからないか、ディレクトリではありません。"
}

Get-ChildItem $inPath -Recurse -File | %{
  $path = $_.FullName.Replace($inPath, $outPath)
  $dir = Split-Path $path -Parent
  Write-Host "処理開始 $($_.FullName)"
  if (!(Test-Path $dir -PathType Container)) {
    New-Item $dir -ItemType Directory | Out-Null
  }
  Get-Content $_.FullName | Set-Content $path
}

Write-Verbose "$psName End"
