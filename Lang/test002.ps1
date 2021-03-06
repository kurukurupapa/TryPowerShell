# Windows PowerShell
# 各種情報を出力してみる。
# 2013/04/03 新規作成

$sep = "*" * 50

Write-Output $sep
Write-Output "カレントディレクトリ関連情報"
Write-Output $sep

Write-Output "`$pwd=$pwd"
#$tmp = Get-Location
#Write-Output "Get-Location=$tmp"
Write-Output "Get-Location=$(Get-Location)"

Write-Output $sep
Write-Output "コマンド実行情報"
Write-Output $sep

$MyInvocation
$basedir = Split-Path -Path $MyInvocation.InvocationName -Parent
$name = Split-Path -Path $MyInvocation.InvocationName -Leaf
Write-Output "当スクリプトの場所=$basedir"
Write-Output "当スクリプトの名前=$name"

Write-Output $sep
Write-Output "環境変数一覧"
Write-Output $sep
#cd env:
Push-Location env:
Get-ChildItem
Pop-Location

Write-Output $sep
Write-Output "システム日時"
Write-Output $sep
$date = Get-Date -Format "yyyymmdd"
$timestamp = Get-Date -Format "yyyymmdd-HHmmss"
Write-Output "システム日付=$date"
Write-Output "タイムスタンプ=$timestamp"
