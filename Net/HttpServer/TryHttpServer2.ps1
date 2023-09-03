<#
.SYNOPSIS
かんたんなHTTPサーバです。

.DESCRIPTION
このスクリプトは、PowerShellで、かんたんなHTTPサーバを起動します。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
TryHttpServer2.ps1
powershell -ExecutionPolicy RemoteSigned -File TryHttpServer2.ps1 localhost 8000 -Verbose
#>

[CmdletBinding()]
Param(
  [string]$hostName = "localhost",
  [int]$port = 8000
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
#$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
#$psBaseName = $psName -replace ("\.ps1$", "")
#$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$documentRoot = Convert-Path .

function GetLocalFilePath($url) {
  $page = "index.html"
  if ($url.AbsolutePath -ne "/") {
    $page = $url.LocalPath
  }
  $fullPath = Join-Path $documentRoot $page
  return $fullPath
}

function GetContentType($filePath) {
  $extension = [System.IO.Path]::GetExtension($filePath)
  switch ($extension) {
    ".css" { $type = "text/css; charset=utf-8" }
    ".html" { $type = "text/html; charset=utf-8" }
    ".jpg" { $type = "image/jpeg" }
    ".js" { $type = "application/javascript; charset=utf-8" }
    ".json" { $type = "application/json; charset=utf-8" }
    ".pdf" { $type = "application/pdf" }
    ".png" { $type = "image/png" }
    ".txt" { $type = "text/plain; charset=utf-8" }
    default { $type = "application/octet-stream" }
  }
  return $type
}

function GetFileContent($filePath) {
  # ファイルはSJISの前提
  $content = Get-Content -Path $filePath
  return $content
}

function Main() {
  $url = "http://${hostName}:${port}/"
  $listener = New-Object Net.HttpListener
  $listener.Prefixes.Add($url)
  $listener.Start()
  Write-Output "起動 ${url}"
  while ($true) {
    # 待機
    $context = $listener.GetContext()
    Write-Verbose "受信 Method=$($context.Request.HttpMethod), Url=$($context.Request.RawUrl)"
  
    # 受信・送信
    $response = $context.Response
    $fullPath = GetLocalFilePath $context.Request.Url
    if (Test-Path -PathType Leaf $fullPath) {
      $contentType = GetContentType $fullPath
      $fileContent = GetFileContent $fullPath
      $response.ContentType = $contentType
      $content = [System.Text.Encoding]::UTF8.GetBytes($fileContent)
      $response.OutputStream.Write($content, 0, $content.Length)
    }
    else {
      $response.StatusCode = 404
    }
    $response.Close()
    Write-Verbose "送信 StatusCode=$($response.StatusCode), ファイルパス=${fullPath}"
  
    # 終了処理
    # とりあえず簡単な実装にする
    if ($context.Request.RawUrl -match "exit") {
      break
    }
  }
  $listener.Dispose()
}

# ヘルプ
if (!$hostName -and !$port) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"
Main
Write-Verbose "$psName End"
