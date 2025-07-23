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

function Find-MatchingLines {
    param(
        [string[]]$FilePaths
    )
    # 最初のファイルを読み込む
    $firstPath = $FilePaths[0]
    Write-Verbose "1つ目のファイルを読み込み中: $firstPath"
    [string[]]$matchingLines = @(Get-Content -Path $firstPath -Encoding $Encoding)

    # 2つ目以降のファイルを順次比較
    for ($i = 1; $i -lt $FilePaths.Count; $i++) {
        # 途中で一致する行がなくなれば処理を終了
        if ($matchingLines.Count -eq 0) {
            Write-Verbose "途中で一致する行がなくなりました。処理を中断します。"
            break
        }

        $currentPath = $FilePaths[$i]
        Write-Verbose "$($i + 1)つ目のファイルを読み込み、比較中: $currentPath"
        $currentFileContent = @(Get-Content -Path $currentPath -Encoding $Encoding)

        # Compare-Objectを使用して共通行を抽出し、元の行データのみを取り出す
        $matchingLines = @(Compare-Object -ReferenceObject $matchingLines -DifferenceObject $currentFileContent -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue)
    }
    return $matchingLines
}

function Get-ContentFromLines {
    param(
        [string[]]$MatchingLines,
        [int]$SourceFileId
    )
    $MatchingLines | ForEach-Object -Begin { $i = 1 } -Process {
        [PSCustomObject]@{
            Line       = $_
            LineNumber = $i++
            SourceFile = $SourceFileId
        }
    }
}

function Get-ContentFromFile {
    param(
        [string]$Path,
        [int]$SourceFileId
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "ファイルが見つかりません: $Path"
    }
    Write-Verbose "${SourceFileId}つ目のファイルを読み込み中: $Path"
    $content = @(Get-Content -Path $Path -Encoding $Encoding)
    Get-ContentFromLines $content $SourceFileId
}

# Compare-Objectを使用して一致/差異データを抽出する
# 結果出力のため、一致データも必ず必要となる
function Compare-FileObject {
    param(
        [psobject[]]$ReferenceObject,
        [psobject[]]$DifferenceObject
    )
    $compareParams = @{
        ReferenceObject  = $ReferenceObject
        DifferenceObject = $DifferenceObject
        Property         = 'Line'
        PassThru         = $true
        IncludeEqual     = $true
    }
    Compare-Object @compareParams
}

function Format-OutputLine {
    param(
        [psobject]$LineObject,
        [string]$Indicator,
        [int[]]$LineCounters,
        [int]$FileCount,
        [int]$CurrentFileIndex = -1 # 差分行の場合のみ指定
    )

    $lineNumberPart = ""
    if ($LineNumber.IsPresent) {
        if ($CurrentFileIndex -ge 1) {
            # 差分行の行番号フォーマット: 指定されたファイルインデックスの位置に行番号を配置
            # 例: >  2   text  (ファイル2の2行目)
            $paddingBefore = $Separator * ($CurrentFileIndex - 1)
            $currentLineNumber = $LineCounters[$CurrentFileIndex]
            $paddingAfter = $Separator * ($FileCount - $CurrentFileIndex - 1)
            $lineNumberPart = "$paddingBefore$currentLineNumber$paddingAfter$Separator"
        }
        else {
            # 一致行の行番号フォーマット: 全ファイルの行番号を並べる
            # 例:  1 1 text
            $lineNumbers = for ($i = 1; $i -lt $FileCount; $i++) { $LineCounters[$i] }
            $lineNumberPart = ($lineNumbers -join $Separator) + $Separator
        }
    }
    "$Indicator$Separator$lineNumberPart$($LineObject.Line)"
}

function Format-DiffOutput {
    param(
        [object[]]$FileComparisonResults
    )

    # 各ファイルの比較結果を、ファイルIDと行番号で高速に参照できるよう、ハッシュテーブルの配列に再構成します。
    $fileDataMaps = 0..$FileComparisonResults.Count | ForEach-Object { @{} }

    foreach ($comparisonResult in $FileComparisonResults) {
        foreach ($obj in $comparisonResult) {
            # $obj.SourceFile は 0 (基準) または 1, 2, ... (各ファイル) を示す。
            # 対応するSourceFile IDのハッシュテーブルに、LineNumberをキーとしてオブジェクトを格納する。
            $fileDataMaps[$obj.SourceFile][$obj.LineNumber] = $obj
        }
    }

    # --- 行番号順に出力テキストを整形 ---
    $fileCount = $fileDataMaps.Count
    $lineCounters = @(1) * $fileCount # 各ファイルの現在行を追跡する配列 (初期値は1)

    # 一致行を基準に、全ファイルの行を同期させながらループ処理
    while ($true) {
        # 手順 1: 終了判定
        # 基準オブジェクト(ID=0)と各比較対象ファイル(ID>0)について、が最後まで処理されたら、すべての処理が完了。
        $noneCount = 0
        for ($fileIndex = 0; $fileIndex -lt $fileCount; $fileIndex++) {
            if (-not $fileDataMaps[$fileIndex][$lineCounters[$fileIndex]]) {
                $noneCount++
            }
            # Write-Verbose "終了判定 $i $($lineCounters[$i]) $noneCount"
        }
        if ($noneCount -eq $fileCount) {
            break
        }

        # 手順 2: 差分行（追加された行）の処理
        # 各比較対象ファイル（ID > 0）について、次の一致行に到達するまでの差分行（SideIndicatorが '=>'）をすべて出力する。
        for ($fileIndex = 1; $fileIndex -lt $fileCount; $fileIndex++) {
            # このループは、現在のファイル($fileIndex)の連続する差分行をすべて処理する。
            # $fileDataMaps[$fileIndex] には '=>' の行しか含まれないはずであるが、
            # バグを懸念して、予期しないデータに気付けるようにエラーログ出力を入れておく。
            while ($fileDataMaps[$fileIndex].ContainsKey($lineCounters[$fileIndex])) {
                $diffObject = $fileDataMaps[$fileIndex][$lineCounters[$fileIndex]]

                if ($diffObject.SideIndicator -eq '=>') {
                    # このファイルにのみ存在する「追加行」を出力
                    Format-OutputLine -LineObject $diffObject -Indicator '>' -LineCounters $lineCounters -FileCount $fileCount -CurrentFileIndex $fileIndex
                }
                else {
                    # 想定外のデータはエラーとして報告
                    Write-Error "予期しないデータ: SourceFile=$fileIndex Line=$($lineCounters[$fileIndex]) $($diffObject | Out-String)"
                }

                # このファイルのカウンタのみ進める
                $lineCounters[$fileIndex]++
            }
        }

        # 手順 3: 一致行の処理
        # 基準オブジェクト（ID=0）から次の一致行を取得して処理する。
        $commonLineObject = $fileDataMaps[0][$lineCounters[0]]
        if ($commonLineObject) {
            if ($commonLineObject.SideIndicator -eq '==') {
                # すべてのファイルに共通する「一致行」
                if ($IncludeMatch.IsPresent) {
                    Format-OutputLine -LineObject $commonLineObject -Indicator ' ' -LineCounters $lineCounters -FileCount $fileCount
                }
            }
            else {
                # 想定外のデータはエラーとして報告
                # 基準オブジェクトは一致行のみのはずなので、"<="や"=>"は出現しない想定。
                Write-Error "予期しないデータが基準オブジェクト内に見つかりました: $($commonLineObject | Out-String)"
            }

            # 手順 4: カウンタの同期
            # 一致行の処理が完了したので、すべてのファイルのカウンタを1つ進める。
            # これにより、各ファイルのポインタが次の一致行の直後に移動し、同期が保たれる。
            for ($fileIndex = 0; $fileIndex -lt $fileCount; $fileIndex++) {
                $lineCounters[$fileIndex]++
            }
        }
    }
}

function Write-OutputContent {
    param(
        [object[]]$Content
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
        [System.IO.File]::WriteAllLines($OutputPath, @($Content), $encodingObject)
        Write-Verbose "出力しました。$OutputPath"
    }
}

function Get-FileComparisonResults {
    param(
        [string[]]$FilePaths,
        [string[]]$MatchingLines
    )
    Write-Verbose "各ファイルを比較中"
    $referenceObject = @(Get-ContentFromLines -MatchingLines $MatchingLines -SourceFileId 0)
    # Write-Verbose "referenceObject: $(Format-DebugString $referenceObject)"

    # 各ファイルを比較し、その結果(オブジェクト配列)をまとめて $fileComparisonResults に格納します。
    # ループ内で += を使うよりもパフォーマンスが向上します。
    $fileComparisonResults = for ($i = 0; $i -lt $FilePaths.Count; $i++) {
        $resolvedFilePath = $FilePaths[$i]
        $sourceFileId = $i + 1
        $differenceObject = @(Get-ContentFromFile -Path $resolvedFilePath -SourceFileId $sourceFileId)

        # Compare-FileObjectの結果はオブジェクトのコレクションを返します。
        # カンマ演算子を先頭に置くことで、各比較結果を配列の新しい要素として効率的に追加します。
        , (Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject)
    }
    return $fileComparisonResults
}

try {
    # ユーティリティ関数を読み込む
    . "$PSScriptRoot\Debug.ps1"

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

    # すべての入力ファイルから一致行を抽出
    Write-Verbose "一致行を抽出中"
    $matchingLines = @(Find-MatchingLines -FilePaths $resolvedFilePaths)
    # Write-Verbose "matchingLines: $(Format-DebugString $matchingLines)"

    # -MatchOnlyが指定されている場合は、一致行を出力して終了
    if ($MatchOnly.IsPresent) {
        Write-OutputContent -Content $matchingLines
        return
    }

    # 一致行と各ファイルを比較し、詳細な比較結果データを生成します。
    $fileComparisonResults = Get-FileComparisonResults -FilePaths $resolvedFilePaths -MatchingLines $matchingLines

    # 結果を出力
    Write-Verbose "結果出力中"
    $formattedDifferences = Format-DiffOutput -FileComparisonResults $fileComparisonResults
    if (-not $formattedDifferences) { $formattedDifferences = @() }
    Write-OutputContent -Content $formattedDifferences
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
