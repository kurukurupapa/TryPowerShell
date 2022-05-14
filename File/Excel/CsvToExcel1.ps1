<#
.SYNOPSIS
CSV�t�@�C����Excel�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B

.DESCRIPTION
CSV�t�@�C����Excel�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B
Excel�t�@�C���́A����CSV�t�@�C���Ɠ����t�H���_�ɍ쐬����܂��B
�Ȃ�ׂ����G�Ȃ��Ƃ͂��Ȃ��X�N���v�g�ɂ��܂����B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
CsvToExcel1.ps1 "D:\tmp\dummy.csv"
CsvToExcel1.ps1 "D:\tmp\*.csv"
CsvToExcel1.ps1 "D:\tmp"
#>

Param([string]$InPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvCsvToExcel($InPath) {
  $fullInPath = Resolve-Path $InPath
  $outPath = $fullInPath -replace '\.csv', '.xls'
  $excel = New-Object -ComObject Excel.Application

  try {
    # ���ɓ���Excel�t�@�C���������Ă��m�F�_�C�A���O��\�����Ȃ��i�㏑������j�B
    $excel.DisplayAlerts = $false

    $excel.Workbooks.Open($fullInPath) | ForEach-Object {
      # ���̃��W�b�N�ł̓G���[���������Ă��܂��B
      # �G���[���e�F Workbook �N���X�� SaveAs �v���p�e�B���擾�ł��܂���B
      # $outPath = $fullInPath -replace '\.csv', '.xlsx'
      # $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)

      # �d�����Ȃ��̂ŁA�Â��t�@�C���`���ixls�j�ŕۑ�����B
      $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
    }
  }
  finally {
    $excel.Quit()
  }
}

function ConvCsvToExcel2($InPath) {
  if (Test-Path -PathType leaf $InPath) {
    Get-ChildItem -File $InPath | ForEach-Object {
      ConvCsvToExcel $_.FullName
    }
  }
  else {
    Get-ChildItem -File $InPath -Recurse -Include '*.csv' | ForEach-Object {
      ConvCsvToExcel $_.FullName
    }
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
ConvCsvToExcel2 $InPath
