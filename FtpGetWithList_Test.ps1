# Windows PowerShell
# �e�X�g���s

Set-StrictMode -Version Latest
$PSDefaultParameterValues = @{"ErrorAction"="Stop"}
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### �������s
######################################################################

###
### �O����
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$psBaseName = $psName -replace "\.ps1$", ""
$dataDir = Join-Path $baseDir "TestData"
$resultDir = Join-Path $baseDir "TestResult"
$sep = "#" * 70
Write-Verbose "$psName Start"

###
### �又��
###

Write-Output $sep

# �����Ȃ�
Invoke-Expression "${baseDir}\FtpGetWithList.ps1"

Write-Output $sep

# ���̓��X�g�t�@�C�������݂̂���i�ۑ���f�B���N�g�������Ȃ��j
# ���̓��X�g�t�@�C����CSV�`��
$listPath = "${dataDir}\FtpGetWithList.csv"
$destDir = "${resultDir}\FtpGetWithList_002"
New-Item $destDir -ItemType Directory -Force | Out-Null
Push-Location $destDir
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath"
Pop-Location

Write-Output $sep

# ���̓��X�g�t�@�C����������
# �ۑ���f�B���N�g����������
$listPath = "${dataDir}\FtpGetWithList.csv"
$destDir = "${resultDir}\FtpGetWithList_003"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# ���̓��X�g�t�@�C����TSV�`��
$listPath = "${dataDir}\FtpGetWithList.tsv"
$destDir = "${resultDir}\FtpGetWithList_004"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# ���̓��X�g�t�@�C����Excel�`��
$listPath = "${dataDir}\FtpGetWithList.xls"
$destDir = "${resultDir}\FtpGetWithList_005"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep

# ���̓��X�g�t�@�C���̊e��f�[�^�p�^�[��
$listPath = "${dataDir}\FtpGetWithList_006.csv"
$destDir = "${resultDir}\FtpGetWithList_006"
Invoke-Expression "${baseDir}\FtpGetWithList.ps1 $listPath $destDir"

Write-Output $sep
###
### �㏈��
###
Write-Verbose "$psName End"
