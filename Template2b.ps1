<#
.SYNOPSIS
PowerShellスクリプトのテンプレートです。（拡張版）

.DESCRIPTION
このスクリプトは、PowerShellスクリプトのテンプレートです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
Template2b.ps1 "D:\tmp\indir" "D:\tmp\outdir"
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

# ログ出力
$logPath = Join-Path "." "${psBaseName}.log"
function Log($level, $msg) {
  $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
  $fullMsg = "${timestamp} [${level}] ${msg}"
  Write-Output $fullMsg >> $logPath
  if ($level -match "INFO|ERROR") {
    Write-Host $fullMsg
  }
}
function DebugLog($msg) {
  Log "DEBUG" $msg
}
function TraceLog($msg) {
  Log "TRACE" $msg
}
function InfoLog($msg) {
  Log "INFO " $msg
}
function ErrorLog($msg) {
  Log "ERROR" $msg
}

# 設定ファイル読み込み
$iniPath = Join-Path $psDir "${psBaseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
    Write-Debug "設定ファイル読み込み $iniPath"
    $ini = @{}
    Get-Content $iniPath | %{ $ini += ConvertFrom-StringData $_ }
}

# ヘルプ
if (!$inPath -and !$outPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
TraceLog "$psName Start"

if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  throw "入力元/出力先が見つからないか、ディレクトリではありません。"
}

Get-ChildItem $inPath -Recurse -File | %{
  $path = $_.FullName.Replace($inPath, $outPath)
  $dir = Split-Path $path -Parent
  InfoLog "処理開始 $($_.FullName)"
  if (!(Test-Path $dir -PathType Container)) {
    New-Item $dir -ItemType Directory | Out-Null
  }
  Get-Content $_.FullName | Set-Content $path
}

TraceLog "$psName End"
