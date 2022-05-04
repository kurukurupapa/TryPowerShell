# ExcelToCsv開発メモ

# 動作確認
# Visual Studio Code なら、実行したい行を選択して、F8キーで実行できる。

.\File\Excel\ExcelToCsv1.ps1
.\File\Excel\ExcelToCsv1.ps1 .\File\Excel\TestData\Excel001_Data.xls
.\File\Excel\ExcelToCsv1.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
.\File\Excel\ExcelToCsv1.ps1 .\File\Excel\TestData\*.xlsx
.\File\Excel\ExcelToCsv1.ps1 .\File\Excel\TestData

.\File\Excel\ExcelToCsv2.ps1
# .\File\Excel\ExcelToCsv2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv2.ps1 .\File\Excel\TestData\*.xlsx -Verbose
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv2.ps1 .\File\Excel\TestData -Verbose

.\File\Excel\ExcelToCsv3.ps1
# .\File\Excel\ExcelToCsv3.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv3.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv3.ps1 .\File\Excel\TestData\Excel003_Data.xlsx .\File\Excel\TestData\Excel003_Data2.csv -Sheet "Sheet1" -Range "A2:C3" -Verbose
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv3.ps1 .\File\Excel\TestData\*.xlsx -Verbose
$DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv3.ps1 .\File\Excel\TestData -Verbose

Remove-Item ('.\File\Excel\TestData\Excel*.csv', '.\File\Excel\TestData\Sub\Excel*.csv')


# 処理が異常終了した場合など、Excelのプロセスが残ることがある。次のコマンドでプロセスを確認できる。
# tasklist | findstr /I excel


# 参考
# [PowerShellでExcelファイルを読み込んでみる - Qiita](https://qiita.com/kurukurupapa@github/items/c17b80412341b8e463cc)
# [PowerShellでExcelを操作する](https://zenn.dev/kumarstack55/articles/20210718-powershell-excel)
# [Workbooks.Open メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open)
# [Workbook.SaveAs メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.saveas)
# [Workbook.Close メソッド (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.close)
