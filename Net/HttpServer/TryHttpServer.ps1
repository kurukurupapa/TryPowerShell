<#
.SYNOPSIS
���񂽂��HTTP�T�[�o�ł��B�i�V���v���Łj

.DESCRIPTION
���̃X�N���v�g�́APowerShell�ŁA���񂽂��HTTP�T�[�o���N�����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

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

# �w���v
if (!$hostName -and !$port) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
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