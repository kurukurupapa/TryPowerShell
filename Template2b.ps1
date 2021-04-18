<#
.SYNOPSIS
PowerShell�X�N���v�g�̃e���v���[�g�ł��B�i�g���Łj

.DESCRIPTION
���̃X�N���v�g�́APowerShell�X�N���v�g�̃e���v���[�g�ł��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
Template2b.ps1 "D:\tmp\indir" "D:\tmp\outdir"
#>

[CmdletBinding()]
Param(
  [string]$inPath,
  [string]$outPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
#$VerbosePreference = 'Continue'
#$VerbosePreference = 'SilentlyContinue'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ���O�o��
$logPath = Join-Path "." "${psBaseName}.log"
function Log($level, $msg) {
  $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
  $fullMsg = "${timestamp} [${level}] ${msg}"
  Write-Output $fullMsg >> $logPath
  if ($level -match "INFO|ERROR") {
    Write-Host $fullMsg
  }
}
function DebugLog($msg) {
  Log "DEBUG" $msg
}
function TraceLog($msg) {
  Log "TRACE" $msg
}
function InfoLog($msg) {
  Log "INFO " $msg
}
function ErrorLog($msg) {
  Log "ERROR" $msg
}

# �ݒ�t�@�C���ǂݍ���
$iniPath = Join-Path $psDir "${psBaseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
    Write-Debug "�ݒ�t�@�C���ǂݍ��� $iniPath"
    $ini = @{}
    Get-Content $iniPath | %{ $ini += ConvertFrom-StringData $_ }
}

# �w���v
if (!$inPath -and !$outPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
TraceLog "$psName Start"

if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  throw "���͌�/�o�͐悪������Ȃ����A�f�B���N�g���ł͂���܂���B"
}

Get-ChildItem $inPath -Recurse -File | %{
  $path = $_.FullName.Replace($inPath, $outPath)
  $dir = Split-Path $path -Parent
  InfoLog "�����J�n $($_.FullName)"
  if (!(Test-Path $dir -PathType Container)) {
    New-Item $dir -ItemType Directory | Out-Null
  }
  Get-Content $_.FullName | Set-Content $path
}

TraceLog "$psName End"
