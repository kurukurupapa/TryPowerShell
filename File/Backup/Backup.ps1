<#
.SYNOPSIS
ファイルやフォルダをバックアップします。

.DESCRIPTION
このスクリプトは、ファイルやフォルダを、コピーし、名前にタイムスタンプを付けます。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
Backup.ps1 D:\tmp\dummy.txt
#>

[CmdletBinding()]
param (
  [string]$path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# ヘルプ
if (!$path) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# バックアップパスを組み立て
$path = $path -replace "\\+$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
if (Test-Path $path -PathType container) {
  # フォルダ
  $outpath = $path + "_bk${timestamp}"
} elseif (Test-Path $path -PathType leaf) {
  if ($path -match "\.[^\.\\]*$") {
    # ファイル・拡張子あり
    $outpath = $path -replace "^(.*)(\.[^\.\\]*)$", "`$1_bk${timestamp}`$2"
  } else {
    # ファイル・拡張子なし
    $outpath = $path + "_bk${timestamp}"
  }
} else {
  throw "対象ファイル/フォルダが見つかりません。${path}"
}

# コピー先チェック
if (Test-Path $outpath) {
  throw "バックアップ先パスが存在します。${outpath}"
}

# コピー実施
Copy-Item $path -Destination $outpath -Recurse -Verbose
Write-Output "バックアップしました。$outpath"
