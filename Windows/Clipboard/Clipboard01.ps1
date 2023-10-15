<#
.SYNOPSIS
PowerShell�ŁA�N���b�v�{�[�h�������Ă݂܂��B

.DESCRIPTION
���̃X�N���v�g�ł́A�N���b�v�{�[�h���Ď����A�ω�������΁A���e���o�͂��܂��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

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

# ���C������
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

# �w���v
if ($Help) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$PsName Start"
Main
Write-Verbose "$PsName End"
