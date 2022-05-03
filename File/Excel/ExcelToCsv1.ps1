<#
.SYNOPSIS
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B

.DESCRIPTION
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B
CSV�t�@�C���́A����Excel�t�@�C���Ɠ����t�H���_�ɁA�V�[�g���Ƃɍ쐬����܂��B
�Ȃ�ׂ����G�Ȃ��Ƃ͂��Ȃ��X�N���v�g�ɂ��܂����B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
ExcelToCsv1.ps1 "D:\tmp\dummy.xlsx"
#>

Param([string]$InPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvExcelToCsv($InPath) {
  $fullInPath = Resolve-Path $InPath
  $basePath = $fullInPath -replace '\.xls(.)?', ''
  $excel = New-Object -ComObject Excel.Application

  try {
    # ���ɓ���CSV�t�@�C���������Ă��m�F�_�C�A���O��\�����Ȃ��i�㏑������j�B
    $excel.DisplayAlerts = $false

    $excel.Workbooks.Open($fullInPath) | ForEach-Object {
      $_.Worksheets | ForEach-Object {
        $outPath = "$($basePath)_$($_.Name).csv"
        $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)
      }
    }
  }
  finally {
    $excel.Quit()
  }
}

function ConvExcelToCsv2($InPath) {
  Get-ChildItem -Recurse -File $InPath | ForEach-Object {
    if ($_.Name -match '\.xls(.)?$') {
      ConvExcelToCsv $_.FullName
    }
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
ConvExcelToCsv2 $InPath
