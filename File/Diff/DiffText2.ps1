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
        [string[]]$FilePaths,
        [string]$Encoding
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
        [string]$Encoding,
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

function Format-DiffOutput {
    param(
        [object[]]$FileComparisonResults,
        [switch]$IncludeMatch,
        [switch]$LineNumber,
        [string]$Separator
    )

    # パフォーマンスと順序保証のため、比較結果を行番号をキーとするハッシュテーブルに変換します。
    # 各ファイル(基準ファイル含む)の比較結果を格納するための、ハッシュテーブルの配列を準備します。
    # $FileComparisonResultsの要素数は比較対象のファイル数と等しい。基準ファイル(ID=0)も必要なので+1します。
    $fileMapArr = 1..($FileComparisonResults.Count + 1) | ForEach-Object { @{} }

    foreach ($comparisonResult in $FileComparisonResults) {
        foreach ($obj in $comparisonResult) {
            # $obj.SourceFile は 0 (基準) または 1, 2, ... (各ファイル) を示す。
            # 対応するSourceFile IDのハッシュテーブルに、LineNumberをキーとしてオブジェクトを格納する。
            $fileMapArr[$obj.SourceFile][$obj.LineNumber] = $obj
        }
    }

    # 行番号順に出力テキストを整形する
    $fileCount = $fileMapArr.Count
    $lineCounters = @(1) * $fileCount # 各ファイルの現在行を追跡する配列 (初期値は1)
    # 一致/差異行ブロックのループ
    while ($true) {
        # 終了判定
        $noneCount = 0
        for ($i = 0; $i -lt $fileCount; $i++) {
            if (-not $fileMapArr[$i][$lineCounters[$i]]) {
                $noneCount++
            }
            Write-Verbose "終了判定 $i $($lineCounters[$i]) $noneCount"
        }
        if ($noneCount -eq $fileCount) {
            break
        }

        # 各入力ファイルのループ
        # 各入力ファイルにおける現在行の差異ブロックを整形する
        for ($i = 1; $i -lt $fileCount; $i++) {
            while ($fileMapArr[$i].ContainsKey($lineCounters[$i])) {
                $file2Diff = $fileMapArr[$i][$lineCounters[$i]]
                Write-Verbose "SourceFile=$i Line=$($lineCounters[$i]) $($file2Diff.SourceFile) $($file2Diff.SideIndicator) $($file2Diff.Line)"
                if ($file2Diff.SideIndicator -eq '=>') {
                    # 各入力ファイルの差異データで、追加された行
                    $prefix1 = ">$Separator"
                    $prefix2 = if ($LineNumber.IsPresent) { "$($Separator * ($i - 1))$($lineCounters[$i])$($Separator * ($fileCount - $i - 1))$Separator" } else { "" }
                    "$prefix1$prefix2$($file2Diff.Line)"
                    Write-Verbose "差異：$prefix1$prefix2$($file2Diff.Line)"
                }
                else {
                    # 想定外のデータはエラーとして報告
                    Write-Error "予期しないデータ: SourceFile=$i Line=$($lineCounters[$i]) $($file2Diff.SourceFile) $($file2Diff.SideIndicator) $($file2Diff.Line)"
                }
                $lineCounters[$i]++
            }
        }

        # 基準となる一致行セットの処理を進める
        $file1Diff = $fileMapArr[0][$lineCounters[0]]
        Write-Verbose "SourceFile=0 Line=$($lineCounters[0]) $($file1Diff.SourceFile) $($file1Diff.SideIndicator) $($file1Diff.Line)"
        if ($file1Diff) {
            if ($file1Diff.SideIndicator -eq '==') {
                # 一致した行
                if ($IncludeMatch.IsPresent) {
                    $prefix1 = " $Separator"
                    $prefix2 = ""
                    if ($LineNumber.IsPresent) {
                        # 各入力ファイルの行番号を出力する
                        # 基準オブジェクト(SourceFile=0)自体は出力対象外
                        for ($i = 1; $i -lt $fileCount; $i++) {
                            $prefix2 += "$($lineCounters[$i])$Separator"
                        }
                    }
                    "$prefix1$prefix2$($file1Diff.Line)"
                    Write-Verbose "一致：$prefix1$prefix2$($file1Diff.Line)"
                }
            }
            else {
                # 想定外のデータはエラーとして報告
                # 基準オブジェクトは一致行のみのはずなので、"<="や"=>"は出現しない想定。
                Write-Error "予期しないデータ: SourceFile=0 Line=$($lineCounters[0]) $($file1Diff.SourceFile) $($file1Diff.SideIndicator) $($file1Diff.Line)"
            }
            for ($i = 0; $i -lt $fileCount; $i++) {
                $lineCounters[$i]++
            }
        }
    }
}

function Write-OutputContent {
    param(
        [object[]]$Content,
        [string]$OutputPath,
        [string]$Encoding
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

function Format-DebugString {
    param(
        [object]$InputObject
    )
    process {
        if ($null -eq $InputObject) {
            return '$null'
        }

        # 配列やコレクションの場合
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $typeName = $InputObject.GetType().FullName
            $count = @($InputObject).Count
            $content = ($InputObject | ForEach-Object { "'$_'" }) -join ', '
            return "[$typeName](${count}件): $content"
        }
        return $InputObject.ToString()
    }
}

try {
    # 入力パスを解決（ワイルドカードとフォルダ展開）
    # -ErrorAction Stop を指定して、パスが見つからない場合にcatchブロックで処理できるようにする
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique

    # 比較するファイルが2つ以上あるか確認
    if ($resolvedFilePaths.Count -lt 2) {
        throw "比較対象のファイルが2つ以上見つかりませんでした。指定されたパスを確認してください。"
    }

    # すべての入力ファイルから一致行を抽出
    Write-Verbose "一致行を抽出中"
    $matchingLines = @(Find-MatchingLines -FilePaths $resolvedFilePaths -Encoding $Encoding)
    Write-Verbose "matchingLines: $(Format-DebugString $matchingLines)"

    # -MatchOnlyが指定されている場合は、一致行を出力して終了
    if ($MatchOnly.IsPresent) {
        Write-OutputContent -Content $matchingLines -OutputPath $OutputPath -Encoding $Encoding
        return
    }

    # 上記で抽出した一致行と、各入力ファイルを比較する
    Write-Verbose "各ファイルを比較中"
    $referenceObject = @(Get-ContentFromLines -MatchingLines $matchingLines -SourceFileId 0)
    Write-Verbose "referenceObject: $(Format-DebugString $referenceObject)"
    $i = 1
    # 各ファイルの比較結果(オブジェクト配列)を格納する配列です。
    $fileComparisonResults = @()
    foreach ($resolvedFilePath in $resolvedFilePaths) {
        $differenceObject = @(Get-ContentFromFile -Path $resolvedFilePath -Encoding $Encoding -SourceFileId $i)

        # Compare-FileObjectの結果（配列）を、カンマ演算子を使って配列の要素として追加する
        $singleFileResult = Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject
        $fileComparisonResults += , ($singleFileResult)
        $i++
    }

    # 結果を出力
    Write-Verbose "結果出力中"
    $formattedDifferences = Format-DiffOutput -FileComparisonResults $fileComparisonResults -IncludeMatch:$IncludeMatch -LineNumber:$LineNumber -Separator $Separator
    if (-not $formattedDifferences) { $formattedDifferences = @() }
    Write-OutputContent -Content $formattedDifferences -OutputPath $OutputPath -Encoding $Encoding
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
