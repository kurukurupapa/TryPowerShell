# Windows PowerShell
# Excelファイルの内容をCSV出力するPowerShellスクリプトです。

param($inpath)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### 関数定義
######################################################################

# 使用方法を出力する。
# return - なし
function U-Write-Usage() {
    Write-Output "使い方：$psName Excelファイル"
    Write-Output "Excelファイル - 入力ファイル"
}

function U-Run-Main() {
    # Excelを起動して画面表示する
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $true

    # ブックを開く
    $books = $excel.Workbooks.Open($inpath)
    echo $("#" + $inpath)

    # シートを処理する
    $books.Worksheets | %{
        $sheet = $_
        $sheet.Activate()
        echo $("#" + $sheet.Name)
        
        # 使用している行数・列数を取得する
        $rowNum = $sheet.UsedRange.Rows.Count
        $columnNum = $sheet.UsedRange.Columns.Count
        
        # セルを処理する
        # セルのインデックスは1始まり
        for ($row = 1; $row -le $rowNum; $row++) {
            $line = ""
            for ($column = 1; $column -le $columnNum; $column++) {
                if ($column -gt 1) {
                    $line += ","
                }
                $line += '"' + $sheet.Cells.Item($row, $column).Text + '"'
            }
            echo $line
        }
    }

    # ブックを閉じる
    $books.Close()

    # Excel終了
    $excel.Quit()
}

######################################################################
### 処理実行
######################################################################

###
### 前処理
###

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""

Write-Verbose "$psName Start"

###
### 主処理
###

if ($inpath -eq $null) {
    U-Write-Usage
} else {
    U-Run-Main
}

###
### 後処理
###

Write-Verbose "$psName End"
