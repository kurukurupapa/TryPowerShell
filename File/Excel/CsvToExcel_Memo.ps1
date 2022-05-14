# CsvToExcel開発メモ

# 動作確認
# Visual Studio Code なら、実行したい行を選択して、F8キーで実行できる。

.\File\Excel\CsvToExcel1.ps1
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\*.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData

.\File\Excel\CsvToExcel2.ps1
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\*.csv
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData
Copy-Item '.\File\Excel\TestData\CsvToExcel_追記テスト_template.xlsx' '.\File\Excel\TestData\CsvToExcel_追記テスト.xlsx'
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_追記テスト.xlsx -Sheet "Target" -Range "B3:C7"
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_追記テスト.xlsx -Sheet "Target" -Range "B3:xx"
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_追記テスト.xlsx -Sheet "Nothing" -Range "B3:C7"

Remove-Item ('.\File\Excel\TestData\CSV*.xls*', '.\File\Excel\TestData\Sub\CSV*.xls*') -Exclude 'CsvToExcel_追記テスト_template.xlsx'


# コードサンプル
# CSVをExcelファイルとして保存するサンプル
$excel = New-Object -ComObject Excel.Application
$inPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $inPath
$book = $excel.Workbooks.Open($fullInPath)
# xls
$outPath = $fullInPath -replace '\.csv', '.xls'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
# 拡張子自動判定
$outPath = $fullInPath -replace '\.csv', ''
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
#
$excel.Quit()

# 次のコードでは、保存されるけどエラー発生。
# エラーメッセージ：Workbook クラスの SaveAs プロパティを取得できません。
# xlsx
$outPath = $fullInPath -replace '\.csv', '.xlsx'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLStrictWorkbook)
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbook)
$book.SaveAs($outPath, 51)
# xlsb
$outPath = $fullInPath -replace '\.csv', '.xlsb'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlExcel12)
# xlsm
$outPath = $fullInPath -replace '\.csv', '.xlsm'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlOpenXMLWorkbookMacroEnabled)
# 拡張子自動判定
$outPath = $fullInPath -replace '\.csv', ''
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCsv)
$book.SaveAs($outPath)

# 他エラー例
# 次のコードでは、正常にファイル保存できたように見えても、
# 作成されたファイルを開くとファイル形式と拡張子が一致しないというエラーが出る。
$outPath = $fullInPath -replace '\.csv', '.xls'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
# SaveCopyAs
$outPath = $fullInPath -replace '\.csv', '.xlsx'
$book.SaveCopyAs($outPath) #OKと思ったら、拡張子xlsxなのに中身はCSVのままだった。


# Excelファイルからシート一覧を取得するサンプル
$excel = New-Object -ComObject Excel.Application
$inPath = ".\File\Excel\TestData\Excel003_Data.xlsx"
$fullInPath = Resolve-Path $inPath
$book = $excel.Workbooks.Open($fullInPath)
$book.Worksheets | ForEach-Object { $_.Name }
$book.Worksheets.Item("Sheet1").Name
$book.Worksheets.Item("シート2").Name
$excel.Quit()


# Excelのバージョンを確認？
$(New-Object -ComObject Excel.Application).Version
wmic product where "Name like '%%Office%%'" get name,version


# CSV
$inPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $inPath
# ConvertFrom-Csvを使う方法
# デフォルトだと、ヘッダーがついているカラムだけしか、読み込まれない模様。
# 何かしらオプション設定すると改善できるかも。
$row = 1
Get-Content $fullInPath | ConvertFrom-Csv | ForEach-Object {
  $column = 1
  $_ | ForEach-Object {
    Write-Host "$row $column $_"
    $column++
  }
  $row++
}
# 自分でカンマ分割する方法
$row = 1
Get-Content $fullInPath | ForEach-Object {
  $column = 1
  $_.Split(',') | ForEach-Object {
    Write-Host "$row $column $_"
    $column++
  }
  $row++
}


# 処理が異常終了した場合など、Excelのプロセスが残ることがある。次のコマンドでプロセスを確認できる。
tasklist | findstr /I excel
tasklist | findstr /I excel | ForEach-Object { if ($_ -match "^\S+\s+(\d+)\s+") { Stop-Process $Matches[1] }}


# 参考サイト
# [PowerShellでExcelファイルを作成してみる - Qiita](https://qiita.com/kurukurupapa@github/items/c1e51784e756bd3331a5)
# [Excel Visual Basic for Applications (VBA) リファレンス | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/overview/excel)
