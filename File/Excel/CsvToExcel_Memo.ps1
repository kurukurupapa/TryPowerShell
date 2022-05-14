# CsvToExcel開発メモ

# 動作確認
# Visual Studio Code なら、実行したい行を選択して、F8キーで実行できる。

$excel = New-Object -ComObject Excel.Application
$InPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $InPath
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


.\File\Excel\CsvToExcel1.ps1
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv -Verbose -Debug
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\*.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData
