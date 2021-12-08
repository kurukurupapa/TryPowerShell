<#
.SYNOPSIS
クリップボード内のテキストを簡易的に暗号化/復号化します。

.DESCRIPTION
このスクリプトは、クリップボード内のテキストに対して、Powershellによる簡易的な暗号化/復号化を行います。
処理後のテキストは、クリップボードに保存されます。
暗号化/復号化は同じユーザで実行する必要があります。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
ClipboardEncryption.ps1 D:\tmp\dummy.txt
#>

[CmdletBinding()]
param (
  [Switch]$Help,
  [Switch]$Encryption,
  [Switch]$Decryption
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$DebugPreference = "Continue"

# ヘルプ
if ($Help) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

if (!$Decryption) {
  $Encryption = $true
}
if ($Encryption) {
  # クリップボードの読み込み・暗号化
  $encrypted = Get-Clipboard -Format Text -Raw | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
  # クリップボード保存
  Set-Clipboard $encrypted
  Write-Output "暗号化しました。"
} else {
  # クリップボードの読み込み・復号化
  $encrypted = Get-Clipboard -Format Text -Raw
  $secureString = ConvertTo-SecureString $encrypted
  $decryptedBstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureString)
  $decryptedString = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($decryptedBstr)
  # クリップボード保存
  Set-Clipboard $decryptedString
  Write-Output "復号化しました。"
}
