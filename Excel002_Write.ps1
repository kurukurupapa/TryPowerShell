# Windows PowerShell
# Excel�t�@�C�����������ޗ��K

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Excel2000-2003�`��
$xlExcel8 = 56

# Excel���N������
$excel = New-Object -ComObject Excel.Application
#$excel.Visible = $true

# �V�K�u�b�N���J��
$excel.Workbooks.Add() | %{
    
    # �V�K���[�N�V�[�g
    $_.Worksheets.Item(1) |  %{
        # �Z���ɒl����������
        # �Z���̃C���f�b�N�X��1�n�܂�
        $_.Cells.Item(1, 1) = "A1"
        $_.Cells.Item(1, 2) = "B1"
        $_.Cells.Item(2, 1) = "A2"
        $_.Cells.Item(2, 2) = "B2"
    }
    
    # �u�b�N��ۑ�����
    $_.SaveAs("${baseDir}\TestData\Excel002_Result.xls", $xlExcel8)
}

# Excel���I������
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
