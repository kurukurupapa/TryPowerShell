# Windows PowerShell
# CSVファイルを書き込むスクリプト

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# サンプルデータ
$arr = @(
    @("1", "2", "3"),
    @("あ", "い", "う")
)

# 出力CSVファイル
$outCsvFile = "${baseDir}\TestResult\Csv002_Result.csv"

# CSVファイルを書き込む
# 文字コードはShift-JIS
$arr | %{
    New-Object PSObject -Property @{
        A = $_[0]
        B = $_[1]
        C = $_[2]
    }
} | Export-Csv -Encoding Default $outCsvFile
