<#
.SYNOPSIS
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。

.DESCRIPTION
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。
CSVファイルは、元のExcelファイルと同じフォルダに、シートごとに作成されます。
なるべく複雑なことはしないスクリプトにしました。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

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
    # 既に同名CSVファイルがあっても確認ダイアログを表示しない（上書きする）。
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

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
ConvExcelToCsv2 $InPath
