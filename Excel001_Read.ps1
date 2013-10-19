# Windows PowerShell
# Excel�t�@�C����ǂݍ��ޗ��K

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Excel���N�����ĉ�ʕ\������
$excel = New-Object -ComObject Excel.Application
#$excel.Visible = $true

# �u�b�N���J��
$excel.Workbooks.Open("${baseDir}\TestData\Excel001_Data.xls") | %{
    #$_ | Out-Default
    Write-Verbose "File=$($_.FullName)"
    
    # �V�[�g��ǂݍ���
    $_.Worksheets | %{
        #$_ | Out-Default
        Write-Verbose "Sheet=$($_.Name)"
        
        # �s��ǂݍ���
        $_.UsedRange.Rows | %{
            #$_ | Out-Default
            Write-Verbose "Row=$($_.Row)"
            
            # ���ǂݍ���
            $_.Columns | %{
                #$_ | Out-Default
                Write-Verbose "Column=$($_.Column)"
                Write-Output $_.Text
            }
        }
    }
}

# Excel���I������
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel)
