# Windows PowerShell
# テンプレート

param($dummy)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### 関数定義
######################################################################

# 使用方法を出力する。
# return - なし
function U-Write-Usage() {
    Write-Output @"
使い方：$psName
"@
}

# 主処理を実行する。
# return - なし
function U-Run-Main() {
    Write-Output $dummy
}

######################################################################
### 処理実行
######################################################################

###
### 前処理
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Verbose "$psName Start"

# 設定ファイル読み込み
$iniPath = "${baseDir}\${psBaseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
    Write-Debug "設定ファイル読み込み $iniPath"
    $ini = @{}
    Get-Content $iniPath | %{ $ini += ConvertFrom-StringData $_ }
}

###
### 主処理
###

if ($dummy -eq $null) {
    U-Write-Usage
} else {
    U-Run-Main
}

###
### 後処理
###

Write-Verbose "$psName End"
