# ExcelToCsv�J������

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

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


# �������ُ�I�������ꍇ�ȂǁAExcel�̃v���Z�X���c�邱�Ƃ�����B���̃R�}���h�Ńv���Z�X���m�F�ł���B
# tasklist | findstr /I excel


# �Q�l
# [PowerShell��Excel�t�@�C����ǂݍ���ł݂� - Qiita](https://qiita.com/kurukurupapa@github/items/c17b80412341b8e463cc)
# [PowerShell��Excel�𑀍삷��](https://zenn.dev/kumarstack55/articles/20210718-powershell-excel)
# [Workbooks.Open ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open)
# [Workbook.SaveAs ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.saveas)
# [Workbook.Close ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.close)
