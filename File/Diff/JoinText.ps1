<#
.SYNOPSIS
複数のテキストファイルを1つのファイルに連結します。

.DESCRIPTION
指定された複数の入力ファイルを、指定された1つの出力ファイルに順番に連結します。

.PARAMETER InputPath
連結したい入力ファイルのパス。複数指定やワイルドカード（*.txtなど）も使用可能です。

.PARAMETER OutputPath
連結結果を保存する出力ファイルのパス。

.PARAMETER Encoding
入力ファイルと出力ファイルの文字エンコーディングを指定します。
デフォルトは "Default" (システムの既定のエンコーディング) です。指定可能な値: UTF8, Default

.EXAMPLE
# file1.txt と file2.txt を combined.txt に連結する
.\JoinText.ps1 -InputPath file1.txt, file2.txt -OutputPath combined.txt

.EXAMPLE
# カレントディレクトリのすべての .log ファイルを all_logs.txt に連結する
.\JoinText.ps1 -InputPath *.log -OutputPath all_logs.txt

.EXAMPLE
# 'Logs' フォルダ内のすべてのファイルを all_logs.txt に連結する
.\JoinText.ps1 -InputPath .\Logs\ -OutputPath all_logs.txt

.EXAMPLE
# Default(Shift_JIS)でエンコードされたファイルを読み込み、Defaultで出力する
.\JoinText.ps1 -InputPath sjis_files\*.txt -OutputPath combined.sjis.txt -Encoding Default
#>
param(
    [Parameter(Mandatory = $true)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $true)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet("UTF8", "Default")]
    [string]$Encoding = 'Default'
)

# Get-ChildItem を使って、ファイル、ワイルドカード、フォルダ指定を統一的に扱い、
# 存在するファイルオブジェクトのリストを取得します。-File スイッチでファイルのみに限定します。
$filesToProcess = Get-ChildItem -Path $InputPath -File -ErrorAction SilentlyContinue
if (-not $filesToProcess) {
    Write-Warning "連結対象のファイルが見つかりませんでした。"
    return
}

# 処理するエンコーディングを決定します。PowerShellのバージョンによって挙動が異なるため、
# .NETメソッドで使用するエンコーディングオブジェクトを準備します。
$writeEncoding = switch ($Encoding) {
    'Default' {
        # システムの既定のエンコーディング(日本語環境では通常Shift_JIS)を取得します。
        [System.Text.Encoding]::Default
    }
    'UTF8' {
        # BOMなしのUTF-8エンコーディングオブジェクトを作成します。
        New-Object System.Text.UTF8Encoding($false)
    }
}

try {
    # 出力先のディレクトリが存在しない場合は作成します
    $outputDirectory = Split-Path -Path $OutputPath -Parent
    if (-not (Test-Path -Path $outputDirectory)) {
        New-Item -Path $outputDirectory -ItemType Directory -Force | Out-Null
    }

    # 複数の入力ファイルの内容をすべてメモリに読み込みます。
    Write-Host "以下のファイルを順番に連結します..."
    $allLines = $filesToProcess | ForEach-Object {
        Write-Host "- $($_.FullName)"
        Get-Content -Path $_.FullName -Encoding $Encoding
    }

    # .NETのメソッドを使用して、収集したすべての行を一度にファイルに書き込みます。
    # このメソッドは既存のファイルを自動的に上書きします。
    [System.IO.File]::WriteAllLines($OutputPath, $allLines, $writeEncoding)

    Write-Host "`nファイルの連結が完了しました: $OutputPath"
}
catch {
    Write-Error "ファイルの書き込み中にエラーが発生しました: $_"
}
