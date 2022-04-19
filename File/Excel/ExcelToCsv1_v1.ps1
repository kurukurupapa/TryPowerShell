<#
.SYNOPSIS
Excel�t�@�C���̓��e��CSV�o�͂���PowerShell�X�N���v�g�ł��B

.DESCRIPTION
Excel�t�@�C���̓��e��CSV�o�͂���PowerShell�X�N���v�g�ł��B
CSV�t�@�C���́A����Excel�t�@�C���Ɠ����t�H���_�ɁA�V�[�g���Ƃɍ쐬����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
ExcelToCsv1_v1.ps1 "D:\tmp\dummy.xlsx"
#>
<#
�J������
�E����m�F
  .\File\Excel\ExcelToCsv1_v1.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
  $DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv1_v1.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
�E�������ُ�I�������ꍇ�ȂǁAExcel�̃v���Z�X���c�邱�Ƃ�����B���̃R�}���h�Ńv���Z�X���m�F�ł���B
  tasklist | findstr /I excel
�E�Q�l
  [PowerShell��Excel�t�@�C����ǂݍ���ł݂� - Qiita](https://qiita.com/kurukurupapa@github/items/c17b80412341b8e463cc)
  [PowerShell��Excel�𑀍삷��](https://zenn.dev/kumarstack55/articles/20210718-powershell-excel)
  [Workbooks.Open ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbooks.open)
  [Workbook.SaveAs ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.saveas)
  [Workbook.Close ���\�b�h (Excel) | Microsoft Docs](https://docs.microsoft.com/ja-jp/office/vba/api/excel.workbook.close)
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
    # ���ɓ���CSV�t�@�C���������Ă��m�F�_�C�A���O��\�����Ȃ��i�㏑������j�B
    $excel.DisplayAlerts = $False

    # Excel�t�@�C�����J���B
    # UpdateLinks=0 �O���Q��(�����N)���X�V���Ȃ�
    # ReadOnly=$True �ǂݎ���p���[�h
    $excel.Workbooks.Open($fullInPath, 0, $True) | ForEach-Object {
      $_.Worksheets | ForEach-Object {
        $outPath = Join-Path $dir "$($name)_$($_.Name).csv"
        $_.SaveAs($outPath, [Microsoft.Office.Interop.Excel.XlFileFormat]::xlCSV)
        Write-Verbose "$outPath ��ۑ����܂����B"
      }

      # Excel�t�@�C�������B
      # SaveChanges=$False �ύX��ۑ����Ȃ�
      $_.Close($False)
    }
  }
  finally {
    # Excel�v���Z�X���I������B
    $excel.Quit()
    [System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Debug "$psName Start"
ConvExcelToCsv $InPath
Write-Debug "$psName End"
