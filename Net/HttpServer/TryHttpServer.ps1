<#
.SYNOPSIS
���񂽂��HTTP�T�[�o�ł��B�i�V���v���Łj

.DESCRIPTION
���̃X�N���v�g�́APowerShell�ŁA���񂽂��HTTP�T�[�o���N�����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
TryHttpServer.ps1
powershell -ExecutionPolicy RemoteSigned -File TryHttpServer.ps1 localhost 8000 -Verbose
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

# �w���v
if (!$hostName -and !$port) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"

$url = "http://${hostName}:${port}/"
$listener = New-Object Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()
Write-Output "�N�� ${url}"
while ($true) {
  # �ҋ@
  $context = $listener.GetContext()

  # ��M�E���M
  Write-Verbose "��M Method=$($context.Request.HttpMethod), Url=$($context.Request.RawUrl)"
  $response = $context.Response
  $response.ContentType = "text/plain"
  $content = [System.Text.Encoding]::UTF8.GetBytes("Hello World!")
  $response.OutputStream.Write($content, 0, $content.Length)
  $response.Close()

  # �I������
  # �Ƃ肠�����ȒP�Ȏ����ɂ���
  if ($context.Request.RawUrl -match "exit") {
    break
  }
}
$listener.Dispose()

Write-Verbose "$psName End"
