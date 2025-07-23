<#
.SYNOPSIS
    複数のテキストファイルを比較し、すべてのファイルに存在する行を抽出します。

.DESCRIPTION
    このスクリプトは、複数の入力テキストファイルを読み込み、すべてのファイルに共通して存在する行を見つけ出します。
    結果は、標準出力に書き出されるか、指定された出力ファイルに保存されます。

.PARAMETER InputPath
    比較するファイルパスを2つ以上指定します。フォルダパスやワイルドカードも使用できます。
    解決されたすべてのファイルについて、最初の2つを比較し、その結果と3つ目を比較...というように順次実行されます。

.PARAMETER OutputPath
    結果を保存する出力ファイルのパス。指定しない場合、結果は標準出力に表示されます。

.PARAMETER Encoding
    入出力ファイルのエンコーディングを指定します。デフォルトは 'Default' です。

.EXAMPLE
    .\MatchText2.ps1 -InputPath file1.txt, file2.txt, file3.txt
    3つのファイルの共通行を標準出力に表示します。

.EXAMPLE
    .\MatchText2.ps1 file1.txt file2.txt -OutputPath common_lines.txt
    2つのファイルの共通行を 'common_lines.txt' に出力します。

.EXAMPLE
    .\MatchText2.ps1 -InputPath C:\Logs\*.log, C:\Archive\
    C:\Logs フォルダ内の全ログファイルと C:\Archive フォルダ内の全ファイルの共通行を抽出します。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '比較するファイルパスを2つ以上指定します。フォルダパスやワイルドカードも使用できます。')]
    [ValidateCount(1, [int]::MaxValue)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = '結果を保存する出力ファイルのパスを指定します。')]
    [string]$OutputPath,

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)
try {
    # .NETのカレントディレクトリをPowerShellのカレントディレクトリに同期させる
    # これにより、[System.IO.Path]::GetFullPath() が期待通りに動作する
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # 入力パスを解決（ワイルドカードとフォルダ展開）
    Write-Verbose "入力パスを解決しています: $($InputPath -join ', ')"
    # -ErrorAction Stop を指定して、パスが見つからない場合にcatchブロックで処理できるようにする
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique
    Write-Verbose "解決されたファイル: $($resolvedFilePaths -join ', ')"

    # 比較するファイルが2つ以上あるか確認
    if ($resolvedFilePaths.Count -lt 2) {
        throw "比較対象のファイルが2つ以上見つかりませんでした。指定されたパスを確認してください。"
    }

    # 最初のファイルを読み込む
    $firstPath = $resolvedFilePaths[0]
    Write-Verbose "1つ目のファイルを読み込み中: $firstPath"
    [string[]]$matchingLines = @(Get-Content -Path $firstPath -Encoding $Encoding)

    # 2つ目以降のファイルを順次比較
    for ($i = 1; $i -lt $resolvedFilePaths.Count; $i++) {
        # 途中で一致する行がなくなれば処理を終了
        if ($matchingLines.Count -eq 0) {
            Write-Verbose "途中で一致する行がなくなりました。処理を中断します。"
            break
        }

        $currentPath = $resolvedFilePaths[$i]
        Write-Verbose "$($i + 1)つ目のファイルを読み込み、比較中: $currentPath"
        $differenceObject = @(Get-Content -Path $currentPath -Encoding $Encoding)

        # Compare-Objectを使用して共通行を抽出し、元の行データのみを取り出す
        $matchingLines = @(Compare-Object -ReferenceObject $matchingLines -DifferenceObject $differenceObject -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue)
    }

    # 結果を出力
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # 標準出力へ
        $matchingLines
    }
    else {
        # ファイルへ出力
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        # WriteAllLinesはstring[]を要求するため、結果が単一の文字列や$nullになる可能性を考慮し、確実に配列として渡すために@()で囲みます。
        [System.IO.File]::WriteAllLines($OutputPath, @($matchingLines), $encodingObject)
        Write-Verbose "一致した行を $OutputPath に出力しました。"
    }
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
