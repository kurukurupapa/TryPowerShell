<#
.SYNOPSIS
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B

.DESCRIPTION
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B
CSV�t�@�C���́A����Excel�t�@�C���Ɠ����t�H���_�ɍ쐬����܂��B
�s�E�񂲂Ƃɏ���������ɂ��Ă݂܂����B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
ExcelToCsv2.ps1 "D:\tmp\dummy.xlsx"
#>

Param([string]$InPath)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function ConvExcelToCsv($InPath) {
  $fullInPath = Resolve-Path $InPath
  $outPath = $fullInPath -replace '\.xls(.)?', '.csv'
  $excel = New-Object -ComObject Excel.Application

  try {
    $excel.Workbooks.Open($fullInPath) | ForEach-Object {
      $_.Worksheets | ForEach-Object {
        $_.UsedRange.Rows | ForEach-Object {
          $line = ''
          $_.Columns | ForEach-Object {
            if ($_.Column -gt 1) {
              $line += ','
            }
            $line += $_.Text
          }
          $line
        }
      }
    } | Out-File -Encoding Default $outPath
  }
  finally {
    $excel.Quit()
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
ConvExcelToCsv $InPath
