# PowerShellスクリプトのテンプレートです。（ユーティリティ）

# 設定ファイル読み込み
$iniPath = Join-Path $psDir "${baseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
  Write-Debug "設定ファイル読み込み $iniPath"
  $ini = @{}
  Get-Content $iniPath | ForEach-Object { $ini += ConvertFrom-StringData $_ }
}

# ログ出力
$logPath = Join-Path $psDir "${baseName}.log"
Write-Debug "ログファイル $logPath"
if (Test-Path $logPath) {
  Remove-Item $logPath
}
function Log($level, $msg) {
  $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
  "${timestamp} [${level}] ${msg}" | ForEach-Object {
    Add-Content $logPath -Value $_
    if ($level -match "INFO|WARN|ERROR") {
      Write-Host $_
    }
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
function WarnLog($msg) {
  Log "WARN " $msg
}
function ErrLog($msg) {
  Log "ERROR" $msg
}
