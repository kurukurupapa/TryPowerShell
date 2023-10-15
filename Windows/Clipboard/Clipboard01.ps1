<#
.SYNOPSIS
PowerShellで、クリップボードを扱ってみます。

.DESCRIPTION
このスクリプトでは、クリップボードを監視し、変化があれば、内容を出力します。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
Clipboard01.ps1
$DebugPreference='Continue'; Clipboard01.ps1 -Verbose
#>

[CmdletBinding()]
Param(
  [switch]$Help = $false
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Windows.Forms
# $PsDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$PsName = Split-Path $MyInvocation.InvocationName -Leaf
# $BaseName = $PsName -replace ("\.ps1$", "")
# $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# メイン処理
function Main() {
  $OldFileList = $null
  $OldImage = $null
  $OldText = $null
  While ($true) {
    $FileList = [System.Windows.Forms.Clipboard]::GetFileDropList()
    $Image = [System.Windows.Forms.Clipboard]::GetImage()
    $Text = [System.Windows.Forms.Clipboard]::GetText()
    if ($FileList -ne $OldFileList) {
      Write-Output $FileList
    }
    if ($Image -ne $OldImage) {
      Write-Output $Image
    }
    if ($Text -ne $OldText) {
      Write-Output $Text
    }
    $OldFileList = $FileList
    $OldImage = $Image
    $OldText = $Text
    Start-Sleep 1
  }
}

# ヘルプ
if ($Help) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$PsName Start"
Main
Write-Verbose "$PsName End"
