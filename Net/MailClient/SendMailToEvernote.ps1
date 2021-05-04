<#
.SYNOPSIS
�w��t�@�C����Evernote�փ��[�����܂��B

.DESCRIPTION
Evernote�ɂ́A�A�J�E���g�o�^���Ƀ��[���A�h���X������������A���̃��[���A�h���X�Ƀ��[������ƃ��[�����e���m�[�g�ɓo�^�����@�\������܂��B
���̃X�N���v�g�́A�����Ŏw�肷��t�@�C�����AEvernote�փ��[�����A�m�[�g�֓o�^����PowerShell�X�N���v�g�ł��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

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

# �w���v
if (!$path) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"

# �ݒ�t�@�C�����Ȃ���΁A�쐬����B
$configPath = Join-Path ([System.Environment]::GetFolderPath("MyDocuments")) "${psBaseName}.json"
if (!(Test-Path $configPath -PathType Leaf)) {
  $to = Read-Host "���M��Evernote���[���A�h���X"
  $smtpUserName = Read-Host "���M��Gmail�̃��[�U��"
  $smtpPassword = Read-Host "���M��Gmail�̃p�X���[�h" -AsSecureString
  $config = @{
    to = $to
    smtpUserName = $smtpUserName
    smtpPassword = ConvertFrom-SecureString -SecureString $smtpPassword
  }
  ConvertTo-Json $config | Set-Content $configPath
}

# �ݒ�t�@�C����ǂݍ���
$config = Get-Content $configPath | ConvertFrom-Json
$password = ConvertTo-SecureString $config.smtpPassword
$credential = New-Object System.Management.Automation.PSCredential($config.smtpUserName, $password)

# ���[�����M
$timestamp = Get-Date -Format u
$subject = "$psBaseName $timestamp"
$body = "���M����: $timestamp"
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
Write-Host "���[�����M���܂����B"

Write-Verbose "$psName End"

