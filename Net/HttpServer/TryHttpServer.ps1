<#
.SYNOPSIS
かんたんなHTTPサーバです。（シンプル版）

.DESCRIPTION
このスクリプトは、PowerShellで、かんたんなHTTPサーバを起動します。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
TryHttpServer.ps1 localhost 8000
#>

[CmdletBinding()]
Param(
  [string]$hostName,
  [int]$port
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
#$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ヘルプ
if (!$hostName -and !$port) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"

$listener = New-Object Net.HttpListener
$listener.Prefixes.Add("http://${hostName}:${port}/")
$listener.Start()
while ($true) {
  $context = $listener.GetContext()
  $response = $context.Response
  $response.ContentType = "text/plain"
  $content = [System.Text.Encoding]::UTF8.GetBytes("Hello World!")
  $response.OutputStream.Write($content, 0, $content.Length)
  $response.Close()
}
$listener.Dispose()

Write-Verbose "$psName End"
