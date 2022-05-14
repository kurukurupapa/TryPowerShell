<#
.SYNOPSIS
CSV�t�@�C����Excel�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B

.DESCRIPTION
CSV�t�@�C����Excel�t�@�C���ɕϊ�����PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
CsvToExcel2.ps1 "D:\tmp\dummy.csv"
CsvToExcel2.ps1 "D:\tmp\dummy.csv" "D:\tmp2\output.xls" -Sheet "Sheet1" -Range "B2:C3"
CsvToExcel2.ps1 "D:\tmp\*.csv"
CsvToExcel2.ps1 "D:\tmp"
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

function ConvCsvToExcel($inPath, $inSheet, $inRange, $outPath) {
  $fullInPath = Resolve-Path $inPath
  if (!$outPath) {
    $dir = [System.IO.Path]::GetDirectoryName($fullInPath)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($fullInPath)
    $outPath = Join-Path $dir ($name + '.xls')
  }
  $outPath = Resolve-Path $outPath
  $excel = New-Object -ComObject Excel.Application

  try {
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    # �����u�b�N or �V�K�u�b�N
    $book = $null
    if (Test-Path $outPath -PathType leaf) {
      Write-Debug "�����u�b�N���J�� $outPath"
      $book = $excel.Workbooks.Open($outPath)
    }
    else {
      Write-Debug "�V�K�u�b�N���쐬 $outPath"
      $book = $excel.Workbooks.Add()
      $book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
    }

    # �w��̃V�[�g or �V�K/������1�ԖڃV�[�g
    $sheet = $null
    if ($inSheet) {
      Write-Debug "�����V�[�g���w�� $inSheet"
      $sheet = $book.Worksheets.Item($inSheet)
    }
    else {
      Write-Debug "�V�[�g1���w��"
      $sheet = $book.Worksheets.Item(1)
    }

    # �Z���ʒu
    $topRow = 1
    $bottomRow = $null
    $leftColumn = 1
    $rightColumn = $null
    if ($inRange) {
      if ($inRange -match "([a-zA-Z]+)(\d+):([a-zA-Z]+)(\d+)") {
        $leftColumn = ParseColumn($Matches[1])
        $topRow = [int]$Matches[2]
        $rightColumn = ParseColumn($Matches[3])
        $bottomRow = [int]$Matches[4]
        Write-Debug "�Z���͈� $inRange $leftColumn $topRow $rightColumn $bottomRow"
      }
      else {
        throw "�Z���͈̓G���[ [$inRange]"
      }
    }

    $row = $topRow
    Get-Content $fullInPath | ForEach-Object {
      $column = $leftColumn
      $_.Split(',') | ForEach-Object {
        if ((($null -eq $bottomRow) -or ($row -le $bottomRow)) -and (($null -eq $rightColumn) -or ($column -le $rightColumn))) {
          # Write-Debug "$row $column $_"
          $sheet.Cells.Item($row, $column) = $_
        }
        $column++
      }
      $row++
    }

    # Excel�t�@�C�������B
    # SaveChanges=$true �ύX��ۑ�����
    $book.Close($true)
    Write-Verbose "�ۑ����܂����B $outPath"
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

function ConvCsvToExcel2($inPath, $inSheet, $inRange, $outPath) {
  if (Test-Path -PathType leaf $inPath) {
    Get-ChildItem -File $inPath | ForEach-Object {
      ConvCsvToExcel $_.FullName $inSheet $inRange $outPath
    }
  }
  else {
    Get-ChildItem -File $inPath -Recurse -Include '*.csv' | ForEach-Object {
      ConvCsvToExcel $_.FullName $inSheet $inRange $outPath
    }
  }
}

function ParseColumn($str) {
  $value = 0
  $str.ToUpper().ToCharArray() | ForEach-Object {
    $value *= 26
    $value += [System.Text.Encoding]::ASCII.GetBytes($_)[0] - [System.Text.Encoding]::ASCII.GetBytes('A')[0] + 1
    # Write-Host $value
  }
  return $value
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"
ConvCsvToExcel2 $InPath $Sheet $Range $OutPath
Write-Verbose "$psName End"
