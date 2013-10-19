# Windows PowerShell
# Excelファイルを書き込む練習

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# Excel2000-2003形式
$xlExcel8 = 56

# Excelを起動する
$excel = New-Object -ComObject Excel.Application
#$excel.Visible = $true

# 新規ブックを開く
$excel.Workbooks.Add() | %{
    
    # 新規ワークシート
    $_.Worksheets.Item(1) |  %{
        # セルに値を書き込む
        # セルのインデックスは1始まり
        $_.Cells.Item(1, 1) = "A1"
        $_.Cells.Item(1, 2) = "B1"
        $_.Cells.Item(2, 1) = "A2"
        $_.Cells.Item(2, 2) = "B2"
    }
    
    # ブックを保存する
    $_.SaveAs("${baseDir}\TestData\Excel002_Result.xls", $xlExcel8)
}

# Excelを終了する
$excel.Quit()
[System.Runtime.InteropServices.Marshal]::FinalReleaseComObject($excel) | Out-Null
