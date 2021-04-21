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
Get-ChildItem (Join-Path $psDir "[0-9][0-9]_*.ps1") | `
  %{
    $switch = 'PS'
    $count = 0
    $skipflag = $false
    Get-Content $_.FullName | `
      %{
        # PowerShellの複数行コメント内を、Markdownの本文へ変換する。
        # PowerShellのスクリプト部分を、Markdownのコードブロックへ変換する。
        # "# MakeMd SKIP_START","# MakeMd SKIP_END"で囲まれた行範囲は、Markdownへ変換しない。
        if ($switch -eq 'MD') {
          if ($_ -eq '#>') {
            $switch = 'PS'
            $count = 0
          } else {
            $_
            $count++
          }
        } elseif ($switch -eq 'PS') {
          if ($_ -eq '<#') {
            if ($count -gt 0) {
              '```'
            }
            $switch = 'MD'
            $count = 0
          } elseif ($_ -eq '# MakeMd SKIP_START') {
            $skipflag = $true
          } elseif ($_ -eq '# MakeMd SKIP_END') {
            $skipflag = $false
          } else {
            if ($count -eq 0) {
              '```powershell'
            }
            if ($skipflag -eq $false) {
              $_
              $count++
            }
          }
        }
      }
    if ($switch -eq 'PS' -and $count -gt 0) {
      '```'
    }
  } | `
  %{ [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } | `
  Set-Content -Encoding Byte $outPath

Write-Verbose "$psName End"
