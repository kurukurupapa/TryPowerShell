# Windows PowerShell
# テキストファイルの文字コードを変換する練習です。
# 2013/08/25 新規作成

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

######################################################################
### 関数定義
######################################################################

# テキストファイルをUTF8からSJISに変換する。
# inpath - 入力ファイル/ディレクトリ
# outpath - 出力ファイル/ディレクトリ
function U-ConvertTo-SjisFile($inpath, $outpath) {
    #Get-Content $inpath -Encoding UTF8 | Set-Content $outpath -Encoding String
    U-Convert-TextFile $inpath $outpath UTF8 String
}

# テキストファイルをSJISからUTF8（BOM付き）に変換する。
# inpath - 入力ファイル/ディレクトリ
# outpath - 出力ファイル/ディレクトリ
function U-ConvertTo-Utf8File($inpath, $outpath) {
    #Get-Content $inpath -Encoding String | Set-Content $outpath -Encoding UTF8
    U-Convert-TextFile $inpath $outpath String UTF8
}

# テキストファイルの文字コードを変換する。
# inpath - 入力ファイル/ディレクトリ
# outpath - 出力ファイル/ディレクトリ
function U-Convert-TextFile($inpath, $outpath, $inlang, $outlang) {
    if (Test-Path -Path $inpath -PathType Container) {
        # inpathがディレクトリの場合、
        # ディレクトリ配下のファイル/ディレクトリに対して、
        # 処理を繰り返す。
        Get-ChildItem $inpath -Recurse | %{
            if ($_.GetType().Name -eq "FileInfo") {
                #$outfullname = $_.FullName.ToLower().Replace($inpath.ToLower(), $outpath)
                $outfullname = $_.FullName.Replace($inpath, $outpath)
                U-Convert-TextFile $_.FullName $outfullname $inlang $outlang
            }
        }
    } else {
        # inpathがファイルの場合
        
        # outpathがディレクトリの場合、
        # 入力ファイルと同じファイル名を付加する。
        if (Test-Path -Path $outpath -PathType Container) {
            $outname = Split-Path $inpath -Leaf
            $outpath = Join-Path $outpath $outname
        }
        
        Write-Debug $inpath
        Write-Debug $outpath
        
        New-Item $outpath -ItemType file -Force | Out-Null
        Get-Content $inpath -Encoding $inlang | Set-Content $outpath -Encoding $outlang
    }
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
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Verbose "$psName Start"

# 設定ファイル読み込み
$iniPath = "${baseDir}\${psBaseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
    Write-Debug "設定ファイル読み込み $iniPath"
    $ini = @{}
    Get-Content $iniPath | %{ $ini += ConvertFrom-StringData $_ }
}

###
### 主処理
###

#if ($dummy -eq $null) {
#    U-Write-Usage
#} else {
    U-ConvertTo-SjisFile "${baseDir}\test004\UTF8\UTF8.txt" "${baseDir}\test004\UTF8_SJIS.txt"
    U-ConvertTo-SjisFile "${baseDir}\test004\UTF8\UTF8BOM.txt" "${baseDir}\test004\UTF8BOM_SJIS.txt"
    U-ConvertTo-Utf8File "${baseDir}\test004\SJIS\SJIS.txt" "${baseDir}\test004\SJIS_UTF8.txt"
    
    # 入力にディレクトリを渡す
    # 出力に存在しないディレクトリを渡す
    if (Test-Path "${baseDir}\test004\UTF8_SJIS") {
        Remove-Item "${baseDir}\test004\UTF8_SJIS" -Force -Recurse
    }
    if (Test-Path "${baseDir}\test004\SJIS_UTF8") {
        Remove-Item "${baseDir}\test004\SJIS_UTF8" -Force -Recurse
    }
    U-ConvertTo-SjisFile "${baseDir}\test004\UTF8" "${baseDir}\test004\UTF8_SJIS"
    U-ConvertTo-Utf8File "${baseDir}\test004\SJIS" "${baseDir}\test004\SJIS_UTF8"
#}

###
### 後処理
###

Write-Verbose "$psName End"
