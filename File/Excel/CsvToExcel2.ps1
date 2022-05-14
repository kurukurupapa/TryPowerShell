<#
.SYNOPSIS
CSVファイルをExcelファイルに変換するPowerShellスクリプトです。

.DESCRIPTION
CSVファイルをExcelファイルに変換するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

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

    # 既存ブック or 新規ブック
    $book = $null
    if (Test-Path $outPath -PathType leaf) {
      Write-Debug "既存ブックを開く $outPath"
      $book = $excel.Workbooks.Open($outPath)
    }
    else {
      Write-Debug "新規ブックを作成 $outPath"
      $book = $excel.Workbooks.Add()
      $book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
    }

    # 指定のシート or 新規/既存の1番目シート
    $sheet = $null
    if ($inSheet) {
      Write-Debug "既存シートを指定 $inSheet"
      $sheet = $book.Worksheets.Item($inSheet)
    }
    else {
      Write-Debug "シート1を指定"
      $sheet = $book.Worksheets.Item(1)
    }

    # セル位置
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
        Write-Debug "セル範囲 $inRange $leftColumn $topRow $rightColumn $bottomRow"
      }
      else {
        throw "セル範囲エラー [$inRange]"
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

    # Excelファイルを閉じる。
    # SaveChanges=$true 変更を保存する
    $book.Close($true)
    Write-Verbose "保存しました。 $outPath"
  }
  finally {
    Write-Debug "Excel後片付け"

    # Excelプロセスを終了する。
    $excel.Quit()
    # 念のため、Excelプロセスが残らないように、COMオブジェクトを開放する。
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    # 即時にExcelプロセスを終了させるため、GCを実行する。
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

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Verbose "$psName Start"
ConvCsvToExcel2 $InPath $Sheet $Range $OutPath
Write-Verbose "$psName End"
