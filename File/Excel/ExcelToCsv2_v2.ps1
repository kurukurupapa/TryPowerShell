<#
.SYNOPSIS
Excelファイルの内容をCSV出力するPowerShellスクリプトです。

.DESCRIPTION
Excelファイルの内容をCSV出力するPowerShellスクリプトです。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
ExcelToCsv2_v2.ps1 "D:\tmp\dummy.xlsx"
#>
<#
開発メモ
・動作確認
  .\File\Excel\ExcelToCsv2_v2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
  $DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv2_v2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
・処理が異常終了した場合など、Excelのプロセスが残ることがある。次のコマンドでプロセスを確認できる。
  tasklist | findstr /I excel
・参考
  [PowerShellでExcelファイルを読み込んでみる - Qiita](https://qiita.com/kurukurupapa@github/items/c17b80412341b8e463cc)
  [PowerShellでExcelを操作する](https://zenn.dev/kumarstack55/articles/20210718-powershell-excel)
  [Workbooks.Open メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open)
  [Workbook.SaveAs メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.saveas)
  [Workbook.Close メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.close)
#>

[CmdletBinding()]
Param(
  [string]$InPath,
  [string]$OutPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psName = Split-Path $MyInvocation.InvocationName -Leaf

function ConvExcelToCsv($InPath, $OutPath) {
  $fullInPath = Resolve-Path $InPath
  if (!$OutPath) {
    $dir = [System.IO.Path]::GetDirectoryName($fullInPath)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($fullInPath)
    $OutPath = Join-Path $dir ($name + '.csv')
  }
  $excel = New-Object -ComObject Excel.Application

  try {
    $excel.Visible = $False
    # 既に同名CSVファイルがあっても確認ダイアログを表示しない（上書きする）。
    $excel.DisplayAlerts = $False

    # Excelファイルを開く。
    # UpdateLinks=0 外部参照(リンク)を更新しない
    # ReadOnly=$True 読み取り専用モード
    $excel.Workbooks.Open($fullInPath, 0, $True) | ForEach-Object {
      Write-Debug "File=$($_.FullName)"

      $_.Worksheets | ForEach-Object {
        # 使用している行数・列数を取得する。
        $rowNum = $_.UsedRange.Rows.Count
        $columnNum = $_.UsedRange.Columns.Count
        Write-Debug "Sheet=$($_.Name), Row=$rowNum, Column=$columnNum"

        $_.UsedRange.Rows | ForEach-Object {
          $row = $_
          $line = ''

          $_.Columns | ForEach-Object {
            $column = $_
            Write-Debug "Row=$($row.Row), Column=$($column.Column), Text=$($_.Text)"

            if ($column.Column -gt 1) {
              $line += ','
            }
            $line += $_.Text
          }

          $line | Out-File -Append -Encoding Default $OutPath
        }
      }

      # Excelファイルを閉じる。
      # SaveChanges=$False 変更を保存しない
      $_.Close($False)

      Write-Verbose "$OutPath を保存しました。"
    }
  }
  finally {
    Write-Debug "Excel後片付け"

    # 念のため、開いたExcelファイルを閉じる。
    # $excel.Workbooks.Close()

    # Excelプロセスを終了する。
    $excel.Quit()
    # 念のため、Excelプロセスが残らないように、COMオブジェクトを開放する。
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    # 即時にExcelプロセスを終了させるため、GCを実行する。
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
  }
}

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Debug "$psName Start"
ConvExcelToCsv $InPath $OutPath
Write-Debug "$psName End"
