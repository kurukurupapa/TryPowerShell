# CsvToExcel�J������

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

.\File\Excel\CsvToExcel1.ps1
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\CSV001_Data.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData\*.csv
.\File\Excel\CsvToExcel1.ps1 .\File\Excel\TestData

.\File\Excel\CsvToExcel2.ps1
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\*.csv
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData
Copy-Item '.\File\Excel\TestData\CsvToExcel_�ǋL�e�X�g_template.xlsx' '.\File\Excel\TestData\CsvToExcel_�ǋL�e�X�g.xlsx'
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_�ǋL�e�X�g.xlsx -Sheet "Target" -Range "B3:C7"
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_�ǋL�e�X�g.xlsx -Sheet "Target" -Range "B3:xx"
$DebugPreference='Continue'; .\File\Excel\CsvToExcel2.ps1 -Verbose .\File\Excel\TestData\CSV001_Data.csv .\File\Excel\TestData\CsvToExcel_�ǋL�e�X�g.xlsx -Sheet "Nothing" -Range "B3:C7"

Remove-Item ('.\File\Excel\TestData\CSV*.xls*', '.\File\Excel\TestData\Sub\CSV*.xls*') -Exclude 'CsvToExcel_�ǋL�e�X�g_template.xlsx'


# �R�[�h�T���v��
# CSV��Excel�t�@�C���Ƃ��ĕۑ�����T���v��
$excel = New-Object -ComObject Excel.Application
$inPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $inPath
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


# Excel�t�@�C������V�[�g�ꗗ���擾����T���v��
$excel = New-Object -ComObject Excel.Application
$inPath = ".\File\Excel\TestData\Excel003_Data.xlsx"
$fullInPath = Resolve-Path $inPath
$book = $excel.Workbooks.Open($fullInPath)
$book.Worksheets | ForEach-Object { $_.Name }
$book.Worksheets.Item("Sheet1").Name
$book.Worksheets.Item("�V�[�g2").Name
$excel.Quit()


# Excel�̃o�[�W�������m�F�H
$(New-Object -ComObject Excel.Application).Version
wmic product where "Name like '%%Office%%'" get name,version


# CSV
$inPath = ".\File\Excel\TestData\CSV001_Data.csv"
$fullInPath = Resolve-Path $inPath
# ConvertFrom-Csv���g�����@
# �f�t�H���g���ƁA�w�b�_�[�����Ă���J�������������A�ǂݍ��܂�Ȃ��͗l�B
# ��������I�v�V�����ݒ肷��Ɖ��P�ł��邩���B
$row = 1
Get-Content $fullInPath | ConvertFrom-Csv | ForEach-Object {
  $column = 1
  $_ | ForEach-Object {
    Write-Host "$row $column $_"
    $column++
  }
  $row++
}
# �����ŃJ���}����������@
$row = 1
Get-Content $fullInPath | ForEach-Object {
  $column = 1
  $_.Split(',') | ForEach-Object {
    Write-Host "$row $column $_"
    $column++
  }
  $row++
}


# �������ُ�I�������ꍇ�ȂǁAExcel�̃v���Z�X���c�邱�Ƃ�����B���̃R�}���h�Ńv���Z�X���m�F�ł���B
tasklist | findstr /I excel
tasklist | findstr /I excel | ForEach-Object { if ($_ -match "^\S+\s+(\d+)\s+") { Stop-Process $Matches[1] }}


# �Q�l�T�C�g
# [PowerShell��Excel�t�@�C�����쐬���Ă݂� - Qiita](https://qiita.com/kurukurupapa@github/items/c1e51784e756bd3331a5)
# [Excel Visual Basic for Applications (VBA) ���t�@�����X | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/overview/excel)
