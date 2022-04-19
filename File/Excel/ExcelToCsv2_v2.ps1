<#
.SYNOPSIS
Excel�t�@�C���̓��e��CSV�o�͂���PowerShell�X�N���v�g�ł��B

.DESCRIPTION
Excel�t�@�C���̓��e��CSV�o�͂���PowerShell�X�N���v�g�ł��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
ExcelToCsv2_v2.ps1 "D:\tmp\dummy.xlsx"
#>
<#
�J������
�E����m�F
  .\File\Excel\ExcelToCsv2_v2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose -Debug
  $DebugPreference = 'Continue'; .\File\Excel\ExcelToCsv2_v2.ps1 .\File\Excel\TestData\Excel003_Data.xlsx -Verbose
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
    # ���ɓ���CSV�t�@�C���������Ă��m�F�_�C�A���O��\�����Ȃ��i�㏑������j�B
    $excel.DisplayAlerts = $False

    # Excel�t�@�C�����J���B
    # UpdateLinks=0 �O���Q��(�����N)���X�V���Ȃ�
    # ReadOnly=$True �ǂݎ���p���[�h
    $excel.Workbooks.Open($fullInPath, 0, $True) | ForEach-Object {
      Write-Debug "File=$($_.FullName)"

      $_.Worksheets | ForEach-Object {
        # �g�p���Ă���s���E�񐔂��擾����B
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

      # Excel�t�@�C�������B
      # SaveChanges=$False �ύX��ۑ����Ȃ�
      $_.Close($False)

      Write-Verbose "$OutPath ��ۑ����܂����B"
    }
  }
  finally {
    Write-Debug "Excel��Еt��"

    # �O�̂��߁A�J����Excel�t�@�C�������B
    # $excel.Workbooks.Close()

    # Excel�v���Z�X���I������B
    $excel.Quit()
    # �O�̂��߁AExcel�v���Z�X���c��Ȃ��悤�ɁACOM�I�u�W�F�N�g���J������B
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel) | Out-Null
    # ������Excel�v���Z�X���I�������邽�߁AGC�����s����B
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
  }
}

# �w���v
if (!$InPath) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Debug "$psName Start"
ConvExcelToCsv $InPath $OutPath
Write-Debug "$psName End"
