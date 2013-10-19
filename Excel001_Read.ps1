# Windows PowerShell
# Excelファイルを読み込む練習

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Excelを起動して画面表示する
$excel = New-Object -ComObject Excel.Application
#$excel.Visible = $true

# ブックを開く
$excel.Workbooks.Open("${baseDir}\TestData\Excel001_Data.xls") | %{
    #$_ | Out-Default
    Write-Verbose "File=$($_.FullName)"
    
    # シートを読み込み
    $_.Worksheets | %{
        #$_ | Out-Default
        Write-Verbose "Sheet=$($_.Name)"
        
        # 行を読み込む
        $_.UsedRange.Rows | %{
            #$_ | Out-Default
            Write-Verbose "Row=$($_.Row)"
            
            # 列を読み込む
            $_.Columns | %{
                #$_ | Out-Default
                Write-Verbose "Column=$($_.Column)"
                Write-Output $_.Text
            }
        }
    }
}

# Excelを終了する
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel)
