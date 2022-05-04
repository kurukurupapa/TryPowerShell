<#
.SYNOPSIS
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。

.DESCRIPTION
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。
CSVファイルは、元のExcelファイルと同じフォルダに作成されます。
行・列ごとに処理する作りにしてみました。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
ExcelToCsv2.ps1 "D:\tmp\dummy.xlsx"
ExcelToCsv2.ps1 "D:\tmp"
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

function ConvExcelToCsv2($InPath) {
  if (Test-Path -PathType leaf $InPath) {
    Get-ChildItem -File $InPath | ForEach-Object {
      ConvExcelToCsv $_.FullName
    }
  } else {
    Get-ChildItem -File $InPath -Recurse -Include ('*.xls', '*.xls?') | ForEach-Object {
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
