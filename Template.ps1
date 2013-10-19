# Windows PowerShell
# �e���v���[�g

param($dummy)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### �֐���`
######################################################################

# �g�p���@���o�͂���B
# return - �Ȃ�
function U-Write-Usage() {
    Write-Output "�g�����F$psName"
}

# �又�������s����B
# return - �Ȃ�
function U-Run-Main() {
    Write-Output $dummy
}

######################################################################
### �������s
######################################################################

###
### �O����
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Verbose "$psName Start"

# �ݒ�t�@�C���ǂݍ���
$iniPath = "${baseDir}\${psBaseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
    Write-Debug "�ݒ�t�@�C���ǂݍ��� $iniPath"
    $ini = @{}
    Get-Content $iniPath | %{ $ini += ConvertFrom-StringData $_ }
}

###
### �又��
###

if ($dummy -eq $null) {
    U-Write-Usage
} else {
    U-Run-Main
}

###
### �㏈��
###

Write-Verbose "$psName End"
