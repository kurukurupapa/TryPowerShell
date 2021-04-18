<#
.SYNOPSIS
PowerShellスクリプトのテンプレートです。（シンプル版）

.DESCRIPTION
このスクリプトは、PowerShellスクリプトのテンプレートです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir"
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir" -Verbose
#>

[CmdletBinding()]
Param(
  # [string]$inPath,
  # [string]$outPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ヘルプ
# if (!$inPath -and !$outPath) {
#   Get-Help $MyInvocation.InvocationName -Detailed
#   return
# }

# 処理開始
Write-Verbose "$psName Start"

$outPath = Join-Path $psDir "All.md"
Get-ChildItem (Join-Path $psDir "*.md") -Exclude "All.md" | `
  %{ Get-Content $_.FullName -Encoding UTF8 } | `
  %{ [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } | `
  Set-Content -Encoding Byte $outPath

Write-Verbose "$psName End"
