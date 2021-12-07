<#
.SYNOPSIS
FileEncryption.ps1で暗号化されたテキストファイルを復号化します。

.DESCRIPTION
このスクリプトは、FileEncryption.ps1で暗号化されたテキストファイルを復号化します。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
FieDecryption.ps1 D:\tmp\dummy.enc.json
#>

[CmdletBinding()]
param (
  [string]$InPath,
  [string]$OutPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 入力パスチェック
if (!(Test-Path $InPath -PathType leaf)) {
  throw "入力ファイルが見つかりません。${InPath}"
}
# 出力チェック
if (!$OutPath) {
  # TODO 簡易的な実装
  $OutPath = ($InPath -replace "\.enc\.json$", "") + ".dec.txt"
}
# TODO 出力パス存在チェックするか？
# if (Test-Path $OutPath) {
#   throw "出力パスが存在します。${OutPath}"
# }

# 入力ファイルの読み込み・復号化
# TODO エラー発生時に入力ファイル形式相違を切り分けたい
$json = Get-Content $InPath | ConvertFrom-Json
# if ($json.Tool -ne 'FileEncryption.ps1') {
#   # エラー
# }
$secureString = ConvertTo-SecureString $json.Encrypted
$decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
$decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)

# ファイル保存
# -NoNewlineオプションはPowerShell 5.0以降で使用可能
Set-Content $OutPath $decryptedString -NoNewline
Write-Output "復号化しました。$OutPath"
