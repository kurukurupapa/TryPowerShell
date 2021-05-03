# Windows PowerShell
# �e�X�g���s

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

######################################################################
### �������s
######################################################################

###
### �O����
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$sep = "#" * 70
Write-Verbose "$psName Start"

###
### �又��
###

Write-Output $sep
Invoke-Expression "$baseDir\ExcelToCsv.ps1"
Write-Output $sep
Invoke-Expression "$baseDir\ExcelToCsv.ps1 $baseDir\TestData\�Ζ��Ǘ��\.xls"
Write-Output $sep

###
### �㏈��
###
Write-Verbose "$psName End"
