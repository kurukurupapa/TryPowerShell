<#
.SYNOPSIS
テキストファイルを簡易的に暗号化します。

.DESCRIPTION
このスクリプトは、テキストファイルに対して、Powershellによる簡易的な暗号化を行います。
暗号化/復号化は同じユーザで実行する必要があります。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
FieEncryption.ps1 D:\tmp\dummy.txt
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
  $OutPath = ($InPath -replace "\.[^\.\\]*$", "") + ".enc.json"
}
# TODO 出力パス存在チェックするか？
# if (Test-Path $OutPath) {
#   throw "出力パスが存在します。${OutPath}"
# }

# 入力ファイルの読み込み・暗号化
$encrypted = Get-Content $InPath -Raw | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString

# ファイル保存
ConvertTo-Json @{
  Tool = 'FileEncryption.ps1'
  FileName = Split-Path $InPath -Leaf
  Encrypted = $encrypted
  } | Set-Content $OutPath
Write-Output "暗号化しました。$OutPath"
