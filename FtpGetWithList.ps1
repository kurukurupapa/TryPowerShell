# Windows PowerShell
# FTPで、ファイルを取得するサンプルです。

param($listPath, $destBaseDir)

Set-StrictMode -Version Latest
$PSDefaultParameterValues = @{"ErrorAction"="Stop"}
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
    Write-Output @"
使い方：$psName リストファイル [保存先ディレクトリ]
リストファイル - 次のデータを記述したCSVファイル
  1行目：ヘッダー
  2行目以降：データ
    1列目：ホスト。上の行と同じ場合は未設定。
    2列目：ユーザー。上の行と同じ場合は未設定。
    3列目：パスワード。上の行と同じ場合は未設定。
    4列目：ファイルパス
    5列目：出力ディレクトリ。未設定時は、ファイルパスのディレクトリ構成を再現する。
  ※行頭が「#」の場合、コメント行と見なします。
　例：
    # サンプルデータ
    Host,User,Password,Path,DestDir
    ftp.jaist.ac.jp,anonymous,password,/pub/sourceforge.jp/ffftp/58201/ffftp-1.98g.exe,
    ,,,/pub/sourceforge.jp/ffftp/58201/ffftp-1.98g.zip,zip
"@
}

# 主処理を実行する。
# return - なし
function U-Run-Main() {
    # FTPコマンドを一時ファイルに書き込む
    $tmpPath = "${destBaseDir}\FtpGetWithList.tmp"
    Get-Content $listPath | ConvertFrom-Csv | U-Out-Command | U-Out-SjisFile $tmpPath
    
    # FTP実行
    Write-Verbose "FTP Start"
    Invoke-Expression "ftp -s:${tmpPath}"
    Write-Verbose "FTP End"
}

function U-Out-Command() {
    process {
        $hostName = $_.Host
        $user = $_.User
        $password = $_.Password
        $path = $_.Path
        $destDir = $_.DestDir
        
        # FTP接続コマンドを出力する
        if ($hostName -ne $null -and $hostName -ne "") {
            Write-Output "open $hostName"
            Write-Output "$user"
            Write-Output "$password"
            Write-Output "bin"
        }
        
        # ローカル側のディレクトリを作成する
        if ($destDir -eq $null -or $destDir -eq "") {
            $outPath = "${destBaseDir}\${path}"
            New-Item -Force -ItemType File $outPath | Out-Null
            $outDir = Convert-Path (Split-Path $outPath -Parent)
        } else {
            $outDir = "${destBaseDir}\${destDir}"
            New-Item -Force -ItemType Directory $outDir | Out-Null
        }
        
        # GETコマンドを出力する
        Write-Output "lcd ${outDir}"
        Write-Output "get $path"
    }
    end {
        # FTP切断コマンドを出力する
        Write-Output "quit"
    }
}

function U-Out-SjisFile($tmpPath) {
    begin {
        New-Item -Force -ItemType File $tmpPath | Out-Null
    }
    process {
        Write-Output $_ | Add-Content -Encoding String $tmpPath
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

Write-Verbose "$psName Start"

###
### 主処理
###

if ($listPath -eq $null) {
    U-Write-Usage
} else {
    # 出力ディレクトリが指定されなかった場合、
    # カレントディレクトリを出力先にする。
    if ($destBaseDir -eq $null) {
        $destBaseDir = Get-Location
    }
    U-Run-Main
}

###
### 後処理
###
Write-Verbose "$psName End"
