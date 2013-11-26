# Windows PowerShell
# テスト実行

Set-StrictMode -Version Latest
$PSDefaultParameterValues = @{"ErrorAction"="Stop"}
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### 処理実行
######################################################################

###
### 前処理
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$psBaseName = $psName -replace "\.ps1$", ""
$dataDir = Join-Path $baseDir "TestData"
$resultDir = Join-Path $baseDir "TestResult"
$sep = "#" * 70
Write-Verbose "$psName Start"

###
### 主処理
###

Write-Output $sep

# 引数なし
Invoke-Expression "${baseDir}\FtpGetWithList.ps1"

Write-Output $sep

# 入力リストファイル引数のみあり（保存先ディレクトリ引数なし）
# 入力リストファイルがCSV形式
$listPath = "${dataDir}\FtpGetWithList.csv"
$destDir = "${resultDir}\FtpGetWithList_002"
New-Item $destDir -ItemType Directory -Force | Out-Null
Push-Location $destDir
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath"
Pop-Location

Write-Output $sep

# 入力リストファイル引数あり
# 保存先ディレクトリ引数あり
$listPath = "${dataDir}\FtpGetWithList.csv"
$destDir = "${resultDir}\FtpGetWithList_003"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# 入力リストファイルがTSV形式
$listPath = "${dataDir}\FtpGetWithList.tsv"
$destDir = "${resultDir}\FtpGetWithList_004"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# 入力リストファイルがExcel形式
$listPath = "${dataDir}\FtpGetWithList.xls"
$destDir = "${resultDir}\FtpGetWithList_005"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# 入力リストファイルの各種データパターン
$listPath = "${dataDir}\FtpGetWithList_006.csv"
$destDir = "${resultDir}\FtpGetWithList_006"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep
###
### 後処理
###
Write-Verbose "$psName End"
