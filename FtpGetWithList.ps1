# Windows PowerShell
# FTP�ŁA�t�@�C�����擾����T���v���ł��B

param($listPath, $destBaseDir)

Set-StrictMode -Version Latest
$PSDefaultParameterValues = @{"ErrorAction"="Stop"}
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
    Write-Output @"
�g�����F$psName ���X�g�t�@�C�� [�ۑ���f�B���N�g��]
���X�g�t�@�C�� - ���̃f�[�^���L�q����CSV�t�@�C��
  1�s�ځF�w�b�_�[
  2�s�ڈȍ~�F�f�[�^
    1��ځF�z�X�g�B��̍s�Ɠ����ꍇ�͖��ݒ�B
    2��ځF���[�U�[�B��̍s�Ɠ����ꍇ�͖��ݒ�B
    3��ځF�p�X���[�h�B��̍s�Ɠ����ꍇ�͖��ݒ�B
    4��ځF�t�@�C���p�X
    5��ځF�o�̓f�B���N�g���B���ݒ莞�́A�t�@�C���p�X�̃f�B���N�g���\�����Č�����B
  ���s�����u#�v�̏ꍇ�A�R�����g�s�ƌ��Ȃ��܂��B
�@��F
    # �T���v���f�[�^
    Host,User,Password,Path,DestDir
    ftp.jaist.ac.jp,anonymous,password,/pub/sourceforge.jp/ffftp/58201/ffftp-1.98g.exe,
    ,,,/pub/sourceforge.jp/ffftp/58201/ffftp-1.98g.zip,zip
"@
}

# �又�������s����B
# return - �Ȃ�
function U-Run-Main() {
    # FTP�R�}���h���ꎞ�t�@�C���ɏ�������
    $tmpPath = "${destBaseDir}\FtpGetWithList.tmp"
    Get-Content $listPath | ConvertFrom-Csv | U-Out-Command | U-Out-SjisFile $tmpPath
    
    # FTP���s
    Write-Verbose "FTP Start"
    Invoke-Expression "ftp -s:${tmpPath}"
    Write-Verbose "FTP End"
}

function U-Out-Command() {
    process {
        $hostName = $_.Host
        $user = $_.User
        $password = $_.Password
        $path = $_.Path
        $destDir = $_.DestDir
        
        # FTP�ڑ��R�}���h���o�͂���
        if ($hostName -ne $null -and $hostName -ne "") {
            Write-Output "open $hostName"
            Write-Output "$user"
            Write-Output "$password"
            Write-Output "bin"
        }
        
        # ���[�J�����̃f�B���N�g�����쐬����
        if ($destDir -eq $null -or $destDir -eq "") {
            $outPath = "${destBaseDir}\${path}"
            New-Item -Force -ItemType File $outPath | Out-Null
            $outDir = Convert-Path (Split-Path $outPath -Parent)
        } else {
            $outDir = "${destBaseDir}\${destDir}"
            New-Item -Force -ItemType Directory $outDir | Out-Null
        }
        
        # GET�R�}���h���o�͂���
        Write-Output "lcd ${outDir}"
        Write-Output "get $path"
    }
    end {
        # FTP�ؒf�R�}���h���o�͂���
        Write-Output "quit"
    }
}

function U-Out-SjisFile($tmpPath) {
    begin {
        New-Item -Force -ItemType File $tmpPath | Out-Null
    }
    process {
        Write-Output $_ | Add-Content -Encoding String $tmpPath
    }
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

Write-Verbose "$psName Start"

###
### �又��
###

if ($listPath -eq $null) {
    U-Write-Usage
} else {
    # �o�̓f�B���N�g�����w�肳��Ȃ������ꍇ�A
    # �J�����g�f�B���N�g�����o�͐�ɂ���B
    if ($destBaseDir -eq $null) {
        $destBaseDir = Get-Location
    }
    U-Run-Main
}

###
### �㏈��
###
Write-Verbose "$psName End"
