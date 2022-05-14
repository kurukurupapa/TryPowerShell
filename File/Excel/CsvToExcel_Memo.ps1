# CsvToExcel�J������

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

$excel = New-Object -ComObject Excel.Application
$InPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $InPath
$book = $excel.Workbooks.Open($fullInPath)
# xls
$outPath = $fullInPath -replace '\.csv', '.xls'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
# �g���q��������
$outPath = $fullInPath -replace '\.csv', ''
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookNormal)
#
$excel.Quit()

# ���̃R�[�h�ł́A�ۑ�����邯�ǃG���[�����B
# �G���[���b�Z�[�W�FWorkbook �N���X�� SaveAs �v���p�e�B���擾�ł��܂���B
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
# �g���q��������
$outPath = $fullInPath -replace '\.csv', ''
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCsv)
$book.SaveAs($outPath)

# ���G���[��
# ���̃R�[�h�ł́A����Ƀt�@�C���ۑ��ł����悤�Ɍ����Ă��A
# �쐬���ꂽ�t�@�C�����J���ƃt�@�C���`���Ɗg���q����v���Ȃ��Ƃ����G���[���o��B
$outPath = $fullInPath -replace '\.csv', '.xls'
$book.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlWorkbookDefault)
# SaveCopyAs
$outPath = $fullInPath -replace '\.csv', '.xlsx'
$book.SaveCopyAs($outPath) #OK�Ǝv������A�g���qxlsx�Ȃ̂ɒ��g��CSV�̂܂܂������B


.\File\Excel\CsvToExcel1.ps1
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv -Verbose -Debug
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\*.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData
