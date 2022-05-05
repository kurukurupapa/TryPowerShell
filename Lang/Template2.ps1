<#
.SYNOPSIS
PowerShell�X�N���v�g�̃e���v���[�g�ł��B

.DESCRIPTION
���̃X�N���v�g�́APowerShell�X�N���v�g�̃e���v���[�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
Template2.ps1 "D:\tmp\indir"
$DebugPreference='Continue'; Template2.ps1 -Verbose "D:\tmp\indir"
#>

[CmdletBinding()]
Param(
  [string]$InPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$baseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# ���[�e�B���e�B�Ăяo��
. (Join-Path $psDir "${baseName}_util.ps1")

# ���C������
function Main($InPath) {
  ErrLog "ERROR���O�ł�"
  WarnLog "WARNING���O�ł�"
  InfoLog "INFORMATION���O�ł�"
  TraceLog "TRACE���O�ł�"
  DebugLog "DEBUG���O�ł�"
  Write-Output "timestamp=$timestamp"
  Write-Output "`$ini.dummy=$($ini.dummy)"

  # if (!(Test-Path $inPath -PathType Container) -or !(Test-Path $outPath -PathType Container)) {
  #   throw "���͌�/�o�͐悪������Ȃ����A�f�B���N�g���ł͂���܂���B"
  # }
  # Get-ChildItem $inPath -Recurse -File | % {
  #   $path = $_.FullName.Replace($inPath, $outPath)
  #   $dir = Split-Path $path -Parent
  #   InfoLog "�����J�n $($_.FullName)"
  #   if (!(Test-Path $dir -PathType Container)) {
  #     New-Item $dir -ItemType Directory | Out-Null
  #   }
  #   Get-Content $_.FullName | Set-Content $path
  # }

  Get-ChildItem $inPath -Recurse -File | ForEach-Object {
    Write-Output $_.FullName
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"
Main $InPath
Write-Verbose "$psName End"
