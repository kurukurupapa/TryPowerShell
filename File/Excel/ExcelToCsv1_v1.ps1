<#
.SYNOPSIS
Excelファイルの内容をCSV出力するPowerShellスクリプトです。

.DESCRIPTION
Excelファイルの内容をCSV出力するPowerShellスクリプトです。
CSVファイルは、元のExcelファイルと同じフォルダに、シートごとに作成されます。
エラー処理は、考慮していません。
<CommonParameters> は、サポートしていません。

.EXAMPLE
ExcelToCsv1_v1.ps1 "D:\tmp\dummy.xlsx"
#>
<#
開発メモ
・動作確認
  .\File\Excel\ExcelToCsv1_v1.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
  $DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv1_v1.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
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
  [string]$InPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psName = Split-Path $MyInvocation.InvocationName -Leaf

function ConvExcelToCsv($InPath) {
  $fullInPath = Resolve-Path $InPath
  $dir = [System.IO.Path]::GetDirectoryName($fullInPath)
  $name = [System.IO.Path]::GetFileNameWithoutExtension($fullInPath)
  $excel = New-Object -ComObject Excel.Application

  try {
    $excel.Visible = $False
    # 既に同名CSVファイルがあっても確認ダイアログを表示しない（上書きする）。
    $excel.DisplayAlerts = $False

    # Excelファイルを開く。
    # UpdateLinks=0 外部参照(リンク)を更新しない
    # ReadOnly=$True 読み取り専用モード
    $excel.Workbooks.Open($fullInPath, 0, $True) | ForEach-Object {
      $_.Worksheets | ForEach-Object {
        $outPath = Join-Path $dir "$($name)_$($_.Name).csv"
        $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)
        Write-Verbose "$outPath を保存しました。"
      }

      # Excelファイルを閉じる。
      # SaveChanges=$False 変更を保存しない
      $_.Close($False)
    }
  }
  finally {
    # Excelプロセスを終了する。
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
  }
}

# ヘルプ
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# 処理開始
Write-Debug "$psName Start"
ConvExcelToCsv $InPath
Write-Debug "$psName End"
