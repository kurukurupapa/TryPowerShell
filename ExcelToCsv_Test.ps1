# Windows PowerShell
# テスト実行

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

######################################################################
### 処理実行
######################################################################

###
### 前処理
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$sep = "#" * 70
Write-Verbose "$psName Start"

###
### 主処理
###

Write-Output $sep
Invoke-Expression "$baseDir\ExcelToCsv.ps1"
Write-Output $sep
Invoke-Expression "$baseDir\ExcelToCsv.ps1 $baseDir\TestData\勤務管理表.xls"
Write-Output $sep

###
### 後処理
###
Write-Verbose "$psName End"
