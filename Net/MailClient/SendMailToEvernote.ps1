<#
.SYNOPSIS
指定ファイルをEvernoteへメールします。

.DESCRIPTION
Evernoteには、アカウント登録時にメールアドレスが払いだされ、そのメールアドレスにメールするとメール内容がノートに登録される機能があります。
このスクリプトは、引数で指定するファイルを、Evernoteへメールし、ノートへ登録するPowerShellスクリプトです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
SendMailToEvernote.ps1 "D:\tmp\dummy.txt"
#>

[CmdletBinding()]
Param(
  [string]$path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ヘルプ
if (!$path) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"

# 設定ファイルがなければ、作成する。
$configPath = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "${psBaseName}.json"
if (!(Test-Path $configPath -PathType Leaf)) {
  $to = Read-Host "送信先Evernoteメールアドレス"
  $smtpUserName = Read-Host "送信元Gmailのユーザ名"
  $smtpPassword = Read-Host "送信元Gmailのパスワード" -AsSecureString
  $config = @{
    to = $to
    smtpUserName = $smtpUserName
    smtpPassword = ConvertFrom-SecureString -SecureString $smtpPassword
  }
  ConvertTo-Json $config | Set-Content $configPath
}

# 設定ファイルを読み込む
$config = Get-Content $configPath | ConvertFrom-Json
$password = ConvertTo-SecureString $config.smtpPassword
$credential = New-Object System.Management.Automation.PSCredential($config.smtpUserName, $password)

# メール送信
$timestamp = Get-Date -Format u
$subject = "$psBaseName $timestamp"
$body = "送信日時: $timestamp"
Send-MailMessage `
  -From ($config.smtpUserName + "@gmail.com") `
  -To $config.to `
  -Subject $subject `
  -Body $body `
  -Attachments $path `
  -Encoding UTF8 `
  -SmtpServer "smtp.gmail.com" `
  -Port 587 `
  -UseSsl `
  -Credential $credential
Write-Host "メール送信しました。"

Write-Verbose "$psName End"

