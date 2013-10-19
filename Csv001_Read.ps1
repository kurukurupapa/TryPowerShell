# Windows PowerShell
# CSVファイルを読み込むスクリプト

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# CSVファイル（ヘッダあり、Shift-JIS）
$csvFile = "${baseDir}\TestData\Csv001_Data.csv"

# CSVファイルを読み込む
# PowerShell3.0では、Import-Csvの文字コード指定で、Shift-JISファイルを読み込み可能。
# PowerShell2.0だと、出来ないので、Get-Contentで使って、Shift-JISファイルを読み込み、
# ConvertFrom-Csvで、CSV→オブジェクト変換を行っています。
Get-Content $csvFile | ConvertFrom-Csv | %{
    $_ | Out-Default
}
