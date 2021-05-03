# Windows PowerShell
# CSV�t�@�C����ǂݍ��ރX�N���v�g

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# CSV�t�@�C���i�w�b�_����AShift-JIS�j
$csvFile = "${baseDir}\TestData\Csv001_Data.csv"

# CSV�t�@�C����ǂݍ���
# PowerShell3.0�ł́AImport-Csv�̕����R�[�h�w��ŁAShift-JIS�t�@�C����ǂݍ��݉\�B
# PowerShell2.0���ƁA�o���Ȃ��̂ŁAGet-Content�Ŏg���āAShift-JIS�t�@�C����ǂݍ��݁A
# ConvertFrom-Csv�ŁACSV���I�u�W�F�N�g�ϊ����s���Ă��܂��B
Get-Content $csvFile | ConvertFrom-Csv | %{
    $_ | Out-Default
}
