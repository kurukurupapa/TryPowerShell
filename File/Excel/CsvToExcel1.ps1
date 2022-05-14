<#
.SYNOPSIS
CSVファイルをExcelファイルに変換するPowerShellスクリプトです。

.DESCRIPTION
CSVファイルをExcelファイルに変換するPowerShellスクリプトです。
Excelファイルは、元のCSVファイルと同じフォルダに作成されます。
なるべく複雑なことはしないスクリプトにしました。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

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
    # 既に同名Excelファイルがあっても確認ダイアログを表示しない（上書きする）。
    $excel.DisplayAlerts = $false

    $excel.Workbooks.Open($fullInPath) | ForEach-Object {
      # 次のロジックではエラーが発生してしまう。
      # エラー内容： Workbook クラスの SaveAs プロパティを取得できません。
      # $outPath = $fullInPath -replace '\.csv', '.xlsx'
      # $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)

      # 仕方がないので、古いファイル形式（xls）で保存する。
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

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
ConvCsvToExcel2 $InPath
