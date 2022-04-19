# Windows PowerShell
# Excel�t�@�C���̓��e��CSV�o�͂���PowerShell�X�N���v�g�ł��B

param($inpath)

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
    Write-Output "�g�����F$psName Excel�t�@�C��"
    Write-Output "Excel�t�@�C�� - ���̓t�@�C��"
}

function U-Run-Main() {
    # Excel���N�����ĉ�ʕ\������
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true

    # �u�b�N���J��
    $books = $excel.Workbooks.Open($inpath)
    echo $("#" + $inpath)

    # �V�[�g����������
    $books.Worksheets | %{
        $sheet = $_
        $sheet.Activate()
        echo $("#" + $sheet.Name)
        
        # �g�p���Ă���s���E�񐔂��擾����
        $rowNum = $sheet.UsedRange.Rows.Count
        $columnNum = $sheet.UsedRange.Columns.Count
        
        # �Z������������
        # �Z���̃C���f�b�N�X��1�n�܂�
        for ($row = 1; $row -le $rowNum; $row++) {
            $line = ""
            for ($column = 1; $column -le $columnNum; $column++) {
                if ($column -gt 1) {
                    $line += ","
                }
                $line += '"' + $sheet.Cells.Item($row, $column).Text + '"'
            }
            echo $line
        }
    }

    # �u�b�N�����
    $books.Close()

    # Excel�I��
    $excel.Quit()
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

if ($inpath -eq $null) {
    U-Write-Usage
} else {
    U-Run-Main
}

###
### �㏈��
###

Write-Verbose "$psName End"
