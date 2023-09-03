<#
.SYNOPSIS
���񂽂��HTTP�T�[�o�ł��B

.DESCRIPTION
���̃X�N���v�g�́APowerShell�ŁA���񂽂��HTTP�T�[�o���N�����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

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
  # �t�@�C����SJIS�̑O��
  $content = Get-Content -Path $filePath
  return $content
}

function Main() {
  $url = "http://${hostName}:${port}/"
  $listener = New-Object Net.HttpListener
  $listener.Prefixes.Add($url)
  $listener.Start()
  Write-Output "�N�� ${url}"
  while ($true) {
    # �ҋ@
    $context = $listener.GetContext()
    Write-Verbose "��M Method=$($context.Request.HttpMethod), Url=$($context.Request.RawUrl)"
  
    # ��M�E���M
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
    Write-Verbose "���M StatusCode=$($response.StatusCode), �t�@�C���p�X=${fullPath}"
  
    # �I������
    # �Ƃ肠�����ȒP�Ȏ����ɂ���
    if ($context.Request.RawUrl -match "exit") {
      break
    }
  }
  $listener.Dispose()
}

# �w���v
if (!$hostName -and !$port) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"
Main
Write-Verbose "$psName End"
