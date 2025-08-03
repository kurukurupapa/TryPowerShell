<#
.SYNOPSIS
    複数のテキストファイルを比較し、差分のある行または一致する行を抽出します。

.DESCRIPTION
    このスクリプトは、複数の入力テキストファイルを読み込み、すべてのファイルに共通しない行（差分）を見つけ出します。
    結果は、標準出力に書き出されるか、指定された出力ファイルに保存されます。
    結果には、差分行には'>'、一致行には空白のインジケータが付与されます。-IncludeMatchスイッチを指定すると、一致行も出力されます。

.PARAMETER InputPath
    比較するファイルパスを2つ以上指定します。フォルダパスやワイルドカードも使用できます。

.PARAMETER OutputPath
    結果を保存する出力ファイルのパスを指定します。指定しない場合、結果は標準出力に表示されます。

.PARAMETER IncludeMatch
    このスイッチを指定すると、差分だけでなく、すべてのファイルに存在する一致行も出力します。

.PARAMETER LineNumber
    このスイッチを指定すると、出力に行番号を付けます。エイリアス -n も使用できます。

.PARAMETER MatchOnly
    このスイッチを指定すると、差分行を出力せず、すべてのファイルに共通する一致行のみをインジケータなしで出力します。

.PARAMETER Separator
    結果出力時の区切り文字を指定します。デフォルトはスペースです。

.PARAMETER Encoding
    入出力ファイルのエンコーディングを指定します。デフォルトは 'Default' (システムのANSIコードページ) です。

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt
    2つのファイルの差分を標準出力に表示します。

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -OutputPath diff_lines.txt
    複数のファイルの差分を 'diff_lines.txt' に出力します。

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch
    ファイルの一致行と差分行をすべて表示します。

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -MatchOnly
    複数のファイルに共通する一致行のみを、インジケータなしで表示します。

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch -n
    行番号付きで、ファイルの一致行と差分行をすべて表示します。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '比較するファイルパスを2つ以上指定します。フォルダパスやワイルドカードも使用できます。')]
    [ValidateCount(1, [int]::MaxValue)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = '結果を保存する出力ファイルのパスを指定します。')]
    [string]$OutputPath,

    [Parameter(Mandatory = $false, HelpMessage = '一致行も出力に含める場合に指定します。')]
    [switch]$IncludeMatch,

    [Parameter(Mandatory = $false, HelpMessage = '出力に行番号を付ける場合に指定します。')]
    [Alias('n')]
    [switch]$LineNumber,

    [Parameter(Mandatory = $false, HelpMessage = '一致行のみを出力する場合に指定します。')]
    [switch]$MatchOnly,

    [Parameter(Mandatory = $false, HelpMessage = '結果出力時の区切り文字を指定します。')]
    [string]$Separator = ' ',

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)

function Write-OutputContent {
    param(
        [string[]]$Content
    )
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # 標準出力へ
        $Content
    }
    else {
        # ファイルへ出力
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        [System.IO.File]::WriteAllLines($OutputPath, $Content, $encodingObject)
        Write-Verbose "出力しました。$OutputPath"
    }
}

try {
    . "$PSScriptRoot\Debug.ps1"
    . "$PSScriptRoot\DiffText2Core.ps1"

    # .NETのカレントディレクトリをPowerShellのカレントディレクトリに同期させる
    # これにより、[System.IO.Path]::GetFullPath() が期待通りに動作する
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # 入力パスを解決（ワイルドカードとフォルダ展開）
    # -ErrorAction Stop を指定して、パスが見つからない場合にcatchブロックで処理できるようにする
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique

    # 比較するファイルが2つ以上あるか確認
    if ($resolvedFilePaths.Count -lt 2) {
        throw "比較対象のファイルが2つ以上見つかりませんでした。指定されたパスを確認してください。"
    }

    # 各ファイルを比較し、詳細な比較結果データを生成します。
    $comparer = [FileComparer]::new()
    $fileComparisonResults = $comparer.CompareFilesAsResults($resolvedFilePaths, $Encoding)

    # 結果を出力
    Write-Verbose "結果出力中"
    $formatter = [ComparisonResultsFormatter]::new()
    $formatter.IncludeMatch = $IncludeMatch
    $formatter.MatchOnly = $MatchOnly
    $formatter.LineNumber = $LineNumber
    $formatter.Separator = $Separator
    $formattedDifferences = $formatter.Format($fileComparisonResults)
    Write-OutputContent -Content $formattedDifferences
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
