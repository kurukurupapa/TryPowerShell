# Windows PowerShell
# テストを実行するスクリプトです。

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$sep = "#" * 70

# テスト対象functionの読み込み
. $baseDir\EchoFunc.ps1

######################################################################
### 処理実行
######################################################################

Write-Output $sep
Write-Output "引数なしのテスト"
#ポップアップ入力が起動する
#U-Echo

Write-Output $sep
Write-Output "引数ありのテスト"
U-Echo "テストです"
U-Echo "テスト1", "テスト2"

Write-Output $sep
Write-Output "パイプラインのテスト"
"テストです" | U-Echo
"テスト1","テスト2" | U-Echo

Write-Output $sep
Write-Output "引数＆パイプラインのテスト"
try {
    "パイプラインデータ" | U-Echo "引数データ"
}
catch {
    Write-Output $_
}

Write-Output $sep
Write-Output "引数NULLのテスト"
try {
    U-Echo $null
}
catch {
    Write-Output $_
}

Write-Output $sep
Write-Output "パイプラインNULLのテスト"
try {
    $null | U-Echo
}
catch {
    Write-Output $_
}

Write-Output $sep
