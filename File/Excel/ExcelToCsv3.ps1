<#
.SYNOPSIS
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B

.DESCRIPTION
Excel�t�@�C����CSV�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
ExcelToCsv3.ps1 "D:\tmp\dummy.xlsx"
ExcelToCsv3.ps1 "D:\tmp\dummy.xlsx" "D:\tmp2\output.csv"
ExcelToCsv3.ps1 "D:\tmp\dummy.xlsx" "D:\tmp2\output.csv" -Sheet "Sheet1" -Range "B2:C3"
ExcelToCsv3.ps1 "D:\tmp"
#>

[CmdletBinding()]
Param(
  [string]$InPath,
  [string]$OutPath,
  [string]$Sheet,
  [string]$Range
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psName = Split-Path $MyInvocation.InvocationName -Leaf

function ConvExcelToCsv($InPath, $InSheet, $InRange, $OutPath) {
  $fullInPath = Resolve-Path $InPath
  if (!$OutPath) {
    $dir = [System.IO.Path]::GetDirectoryName($fullInPath)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($fullInPath)
    $OutPath = Join-Path $dir ($name + '.csv')
  }
  if (Test-Path $OutPath) {
    Remove-Item $OutPath
  }
  $excel = New-Object -ComObject Excel.Application

  try {
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    # Excel�t�@�C�����J���B
    # UpdateLinks=0 �O���Q��(�����N)���X�V���Ȃ�
    # ReadOnly=$true �ǂݎ���p���[�h
    $excel.Workbooks.Open($fullInPath, 0, $true) | ForEach-Object {
      Write-Debug "File=$($_.FullName)"

      # �V�[�g����������B
      $sheets = $_.Worksheets
      if ($InSheet) {
        $sheets = $_.Worksheets($InSheet)
      }
      $sheets | ForEach-Object {
        # $sheet = $_
        #
        # # �g�p���Ă���s���E�񐔂��擾����B
        # $rowNum = $_.UsedRange.Rows.Count
        # $columnNum = $_.UsedRange.Columns.Count
        # Write-Debug "Sheet=$($sheet.Name), Row=$rowNum, Column=$columnNum"
        #
        # # �Z������������B
        # # �Z���̃C���f�b�N�X��1�n�܂�
        # for ($row = 1; $row -le $rowNum; $row++) {
        #   $line = ''
        #   for ($column = 1; $column -le $columnNum; $column++) {
        #     if ($column -gt 1) {
        #       $line += ','
        #     }
        #     $line += '"' + $sheet.Cells.Item($row, $column).Text + '"'
        #   }
        #
        #   $line | Out-File -Append -Encoding Default $OutPath
        # }

        # �Z������������B
        $range = $_.UsedRange
        if ($InRange) {
          $range = $_.Range($InRange)
        }
        $range.Rows | ForEach-Object {
          $line = ''
          $_.Columns | ForEach-Object {
            if ($_.Column -gt 1) {
              $line += ','
            }
            $line += $_.Text
          }
          $line | Out-File -Append -Encoding Default $OutPath
        }
      }

      # Excel�t�@�C�������B
      # SaveChanges=$false �ύX��ۑ����Ȃ�
      $_.Close($false)
      # ���̏��������\�B
      # $excel.Workbooks.Close()

      Write-Verbose "$OutPath ��ۑ����܂����B"
    }
  }
  finally {
    Write-Debug "Excel��Еt��"

    # Excel�v���Z�X���I������B
    $excel.Quit()
    # �O�̂��߁AExcel�v���Z�X���c��Ȃ��悤�ɁACOM�I�u�W�F�N�g���J������B
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    # ������Excel�v���Z�X���I�������邽�߁AGC�����s����B
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
  }
}

function ConvExcelToCsv2($InPath, $InSheet, $InRange, $OutPath) {
  if (Test-Path -PathType leaf $InPath) {
    Get-ChildItem -File $InPath | ForEach-Object {
      ConvExcelToCsv $_.FullName $InSheet $InRange $OutPath
    }
  } else {
    Get-ChildItem -File $InPath -Recurse -Include ('*.xls', '*.xls?') | ForEach-Object {
      ConvExcelToCsv $_.FullName $InSheet $InRange $OutPath
    }
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}
  
# �����J�n
Write-Debug "$psName Start"
ConvExcelToCsv2 $InPath $Sheet $Range $OutPath
Write-Debug "$psName End"
