<#
.SYNOPSIS
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。

.DESCRIPTION
ExcelファイルをCSVファイルに変換するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

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

    # Excelファイルを開く。
    # UpdateLinks=0 外部参照(リンク)を更新しない
    # ReadOnly=$true 読み取り専用モード
    $excel.Workbooks.Open($fullInPath, 0, $true) | ForEach-Object {
      Write-Debug "File=$($_.FullName)"

      # シートを処理する。
      $sheets = $_.Worksheets
      if ($InSheet) {
        $sheets = $_.Worksheets($InSheet)
      }
      $sheets | ForEach-Object {
        # $sheet = $_
        #
        # # 使用している行数・列数を取得する。
        # $rowNum = $_.UsedRange.Rows.Count
        # $columnNum = $_.UsedRange.Columns.Count
        # Write-Debug "Sheet=$($sheet.Name), Row=$rowNum, Column=$columnNum"
        #
        # # セルを処理する。
        # # セルのインデックスは1始まり
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

        # セルを処理する。
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

      # Excelファイルを閉じる。
      # SaveChanges=$false 変更を保存しない
      $_.Close($false)
      # 次の書き方も可能。
      # $excel.Workbooks.Close()

      Write-Verbose "$OutPath を保存しました。"
    }
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

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}
  
# 処理開始
Write-Debug "$psName Start"
ConvExcelToCsv2 $InPath $Sheet $Range $OutPath
Write-Debug "$psName End"
