# PowerShellスクリプト: DiffText2Core.ps1

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
            return "$typeName ${count}件 $content"
        }
        return $InputObject.ToString()
    }
}

<#
1行分の比較情報を保持するクラス
#>
class ComparisonLine {
    [string]$Line          # 行の内容
    [int]$LineNumber       # 行番号
    [int]$SourceFileIndex  # 元ファイルのインデックス
    [string]$SideIndicator # Compare-Objectで設定
    [int]$DiffLineNumber   # 比較ファイルの行番号
}

class FileComparer {
    [string[]] GetLinesFromFile(
        [string]$Path,
        [string]$Encoding
    ) {
        if (-not (Test-Path -Path $Path -PathType Leaf)) {
            throw "ファイルが見つかりません: $Path"
        }
        return Get-Content -Path $Path -Encoding $Encoding
    }

    # 指定ファイルの内容を1行ずつオブジェクト化して取得
    [ComparisonLine[]] GetComparisonLines(
        [string[]]$Lines,         # 入力行配列
        [int]$SourceFileIndex     # 元ファイルのインデックス
    ) {
        if ($null -eq $Lines) {
            $Lines = @()
        }
        # 各行をComparisonLineオブジェクト化
        $comparisonLines = $Lines | ForEach-Object -Begin { $i = 1 } -Process {
            [ComparisonLine]@{
                Line            = $_
                LineNumber      = $i++
                SourceFileIndex = $SourceFileIndex
            }
        }
        Write-Debug "GetComparisonLines: 結果件数:$($comparisonLines.Count)"
        return $comparisonLines
    }

    # 指定ファイルの内容を1行ずつオブジェクト化して取得
    [ComparisonLine[]] GetComparisonLinesFromFile(
        [string]$Path,
        [string]$Encoding,
        [int]$SourceFileIndex
    ) {
        Write-Verbose "$($SourceFileIndex + 1)件目のファイルを読み込み中: $Path"
        $lines = $this.GetLinesFromFile($Path, $Encoding)
        $comparisonLines = $this.GetComparisonLines($lines, $SourceFileIndex)
        Write-Debug "GetComparisonLinesFromFile: 結果件数:$($comparisonLines.Count)"
        return $comparisonLines
    }

    # 2ファイルの行オブジェクト配列を比較し、差分・一致情報を返す
    [ComparisonLine[]] CompareComparisonLines(
        [ComparisonLine[]]$ReferenceObject,
        [ComparisonLine[]]$DifferenceObject
    ) {
        # Write-Debug "CompareComparisonLines: ReferenceObject:$(Format-DebugString $ReferenceObject)"
        # Write-Debug "CompareComparisonLines: DifferenceObject:$(Format-DebugString $DifferenceObject)"

        if ($null -eq $ReferenceObject) {
            $ReferenceObject = @()
        }
        if ($null -eq $DifferenceObject) {
            $DifferenceObject = @()
        }

        $params = @{
            ReferenceObject  = $ReferenceObject
            DifferenceObject = $DifferenceObject
            Property         = 'Line'
            PassThru         = $true
            IncludeEqual     = $true
        }
        $comparisonResult = Compare-Object @params
        #=> $ReferenceObjectが $null, @('') の場合、次のエラーが発生。@()なら正常処理。
        #   処理中にエラーが発生しました: 引数が null であるため、パラメーター 'ReferenceObject' にバインドできません。

        Write-Debug "CompareComparisonLines: 結果件数:$($comparisonResult.Count)"
        return $comparisonResult
    }

    # 複数ファイルを比較し、差分情報オブジェクト配列を返す
    [ComparisonLine[][]] CompareFiles(
        [string[]]$FilePaths,
        [string]$Encoding
    ) {
        Write-Debug "CompareFiles: FilePaths.Count:$($FilePaths.Count)"
        Write-Verbose "各ファイルを比較中"
        $referenceRawLines = $this.GetLinesFromFile($FilePaths[0], $Encoding)

        [ComparisonLine[][]]$comparisonResults = @()
        for ($i = 1; $i -lt $FilePaths.Count; $i++) {
            # $referenceLinesのディープコピーを作るため毎回作り直す
            $referenceLines = $this.GetComparisonLines($referenceRawLines, 0)
            $differenceLines = $this.GetComparisonLinesFromFile($FilePaths[$i], $Encoding, $i)
            $comparisonResults += , ($this.CompareComparisonLines($referenceLines, $differenceLines))
        }
        Write-Debug "CompareFiles: 結果件数:$($comparisonResults.Count)"
        return $comparisonResults
    }

    [ComparisonResult[]] CompareFilesAsResults(
        [string[]]$FilePaths,
        [string]$Encoding
    ) {
        return $this.CompareFiles($FilePaths, $Encoding) | ForEach-Object { [ComparisonResult]::new($_) }
    }
}

<#
2ファイルの比較結果を「基準ファイルの行番号」ごとに管理するクラス。
DiffMapByRefLine: キー=基準ファイルの行番号, 値={ '<=':削除行, '=>':追加行, '==':一致行(配列) }
MaxReferenceLineNumber: 基準ファイルの最大行番号
#>
class ComparisonResult {
    # DiffMap: キー=基準ファイルの行番号, 値={ '<=':削除行, '=>':追加行, '==':一致行 }
    [hashtable]$DiffMapByRefLine = @{}
    [int]$MinReferenceLineNumber = -1
    [int]$MaxReferenceLineNumber = -1

    # コンストラクタ: Compare-Object の結果(配列)からDiffMapByRefLineを構築
    ComparisonResult([object[]]$ComparisonLines) {
        # 比較結果を基準ファイルと比較ファイルに分けてマップ化
        $refComparisonLines = @{}
        $diffComparisonLines = @{}
        if (-not $ComparisonLines) { $ComparisonLines = @() }
        # $ComparisonLines | ForEach-Object {
        foreach ($obj in $ComparisonLines) {
            # SourceFileIndex: 0=基準ファイル, 1以上=比較ファイル
            if ($obj.SourceFileIndex -eq 0) {
                $refComparisonLines[$obj.LineNumber] = $obj
            }
            else {
                $diffComparisonLines[$obj.LineNumber] = $obj
            }
        }

        $refLineNumber = 0
        $diffLineNumber = 0
        while ($true) {
            $refComparisonLine = $refComparisonLines[$refLineNumber + 1]
            $diffComparisonLine = $diffComparisonLines[$diffLineNumber + 1]
            # 削除行(基準ファイルにのみ存在)
            if ($refComparisonLine -and $refComparisonLine.SideIndicator -eq '<=') {
                $refLineNumber++
                $this.InitializeLineIfNeeded($refLineNumber)
                $refComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['<='] = $refComparisonLine
            }
            # 追加行(比較ファイルにのみ存在)
            elseif ($diffComparisonLine -and $diffComparisonLine.SideIndicator -eq '=>') {
                $this.InitializeLineIfNeeded($refLineNumber)
                $diffLineNumber++
                $diffComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['=>'].Add($diffComparisonLine)
            }
            # 一致行(両ファイルに同じ内容)
            elseif ($refComparisonLine -and $refComparisonLine.SideIndicator -eq '==') {
                $refLineNumber++
                $this.InitializeLineIfNeeded($refLineNumber)
                $diffLineNumber++
                $refComparisonLine.DiffLineNumber = $diffLineNumber
                $this.DiffMapByRefLine[$refLineNumber]['=='] = $refComparisonLine
            }
            else {
                break
            }
        }

        Write-Debug "ComparisonResultコンストラクタ: 結果件数:$($this.DiffMapByRefLine.Count)"
    }

    [void]InitializeLineIfNeeded($ReferenceLineNumber) {
        if (-not $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            $this.InitializeLine($ReferenceLineNumber)
        }
    }

    [void]InitializeLine($ReferenceLineNumber) {
        $this.DiffMapByRefLine[$ReferenceLineNumber] = @{
            '==' = $null
            '<=' = $null
            '=>' = [System.Collections.Generic.List[object]]::new()
        }
        if ($this.MinReferenceLineNumber -lt 0 -or $this.MinReferenceLineNumber -gt $ReferenceLineNumber) {
            $this.MinReferenceLineNumber = $ReferenceLineNumber
        }
        if ($this.MaxReferenceLineNumber -lt 0 -or $this.MaxReferenceLineNumber -lt $ReferenceLineNumber) {
            $this.MaxReferenceLineNumber = $ReferenceLineNumber
        }
    }

    # 基準ファイルの最小行番号を返す（0行目が存在すれば0、なければ1）
    [int]GetMinReferenceLineNumber() { return $this.MinReferenceLineNumber }

    # 基準ファイルの最大行番号を返す
    [int]GetMaxReferenceLineNumber() { return $this.MaxReferenceLineNumber }

    # 指定行の追加行（比較ファイルにのみ存在）を配列で返す
    [object[]]GetAddedLines($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['=>']
        }
        else {
            return @()
        }
    }

    # 指定行の削除行（基準ファイルにのみ存在）を1件だけ返す（なければ$null）
    [object]GetRemovedLine($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['<=']
        }
        else {
            return $null
        }
    }

    # 指定行の一致行（両ファイルに同じ内容）を1件だけ返す（なければ$null）
    [object]GetCommonLine($ReferenceLineNumber) {
        if ($this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber)) {
            return $this.DiffMapByRefLine[$ReferenceLineNumber]['==']
        }
        else {
            return $null
        }
    }

    # 指定行が存在するか
    [bool]HasLine($ReferenceLineNumber) { return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) }

    # 指定行に追加行があるか
    [bool]HasAddedLines($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $this.DiffMapByRefLine[$ReferenceLineNumber]['=>'].Count -gt 0
    }

    # 指定行に削除行があるか
    [bool]HasRemovedLine($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $null -ne $this.DiffMapByRefLine[$ReferenceLineNumber]['<=']
    }

    # 指定行に一致行があるか
    [bool]HasCommonLine($ReferenceLineNumber) {
        return $this.DiffMapByRefLine.ContainsKey($ReferenceLineNumber) -and $null -ne $this.DiffMapByRefLine[$ReferenceLineNumber]['==']
    }

    # オブジェクト内容をJSON文字列で返す（デバッグ用）
    [string]ToString() {
        $result = $this.DiffMapByRefLine.GetEnumerator() | Sort-Object { $_.Key } | ForEach-Object { $_ } | ConvertTo-Json -Depth 99 #-Compress
        return $result
    }
}

<#
複数ファイルの差分情報を整形して出力用テキスト配列を生成するクラス
#>
class ComparisonResultsFormatter {
    [bool]$IncludeMatch = $false
    [bool]$MatchOnly = $false
    [bool]$LineNumber = $false
    [string]$Separator = ' '

    # 各行番号ごとに、削除・追加・一致行を順に出力用テキストへ整形
    [string[]]Format([ComparisonResult[]]$ComparisonResults) {
        $comparisonCount = $ComparisonResults.Count
        $formattedLines = @()

        # 各ComparisonResultのMinReferenceLineNumberの最小値を取得
        [int]$minLineNumber = ($ComparisonResults | ForEach-Object { $_.MinReferenceLineNumber }) | Measure-Object -Minimum | Select-Object -ExpandProperty Minimum
        [int]$maxLineNumber = ($ComparisonResults | ForEach-Object { $_.MaxReferenceLineNumber }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

        Write-Debug "ComparisonResultsFormatter.Format: comparisonCount:$comparisonCount minLineNumber:$minLineNumber maxLineNumber:$maxLineNumber"

        for ($count = $minLineNumber; $count -le $maxLineNumber; $count++) {
            # $isFinished = $true
            # for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
            #     if ($ComparisonResults[$comparisonIndex].HasLine($lineNumber)) {
            #         $isFinished = $false
            #         break
            #     }
            # }
            # if ($isFinished) { break }

            # 一致行
            if ($this.MatchOnly -or $this.IncludeMatch) {
                $isCommonInAll = $true
                for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                    if (-not $ComparisonResults[$comparisonIndex].HasCommonLine($count)) {
                        $isCommonInAll = $false
                        break
                    }
                }
                if ($isCommonInAll) {
                    $formattedLines += $this.FormatCommonLine($ComparisonResults, $count)
                }
            }
            # 削除行
            for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                if ($ComparisonResults[$comparisonIndex].HasRemovedLine($count)) {
                    if (-not $this.MatchOnly) {
                        $formattedLines += $this.FormatRemovedLine($ComparisonResults, $comparisonIndex, $count)
                    }
                }
            }
            # 追加行
            for ($comparisonIndex = 0; $comparisonIndex -lt $comparisonCount; $comparisonIndex++) {
                if ($ComparisonResults[$comparisonIndex].HasAddedLines($count)) {
                    if (-not $this.MatchOnly) {
                        $formattedLines += $this.FormatAddedLines($ComparisonResults, $comparisonIndex, $count)
                    }
                }
            }

            # $lineCounter++
        }

        Write-Debug "ComparisonResultsFormatter.Format: 結果件数:$($formattedLines.Count)"
        return $formattedLines
    }

    # 指定行番号の追加行を出力用テキスト配列に整形
    [string[]]FormatAddedLines([ComparisonResult[]]$ComparisonResults, [int]$ComparisonIndex, [int]$ReferenceLineNumber) {
        $LineNumbers = @('') * ($ComparisonResults.Count + 1)
        $addedLines = $ComparisonResults[$ComparisonIndex].GetAddedLines($ReferenceLineNumber) | ForEach-Object {
            $LineNumbers[$ComparisonIndex + 1] = $_.DiffLineNumber
            $this.FormatOutputLine('>', $LineNumbers, $_.Line)
        }
        return $addedLines
    }
    # 指定行番号の削除行を出力用テキスト配列に整形
    [string]FormatRemovedLine([ComparisonResult[]]$ComparisonResults, [int]$ComparisonIndex, [int]$ReferenceLineNumber) {
        $LineNumbers = @('') * ($ComparisonResults.Count + 1)
        $removedLine = $ComparisonResults[$ComparisonIndex].GetRemovedLine($ReferenceLineNumber) | ForEach-Object {
            $LineNumbers[0] = $_.LineNumber
            $this.FormatOutputLine('<', $LineNumbers, $_.Line)
        }
        return $removedLine
    }
    # 指定行番号の一致行を出力用テキストに整形
    [string]FormatCommonLine([ComparisonResult[]]$ComparisonResults, [int]$ReferenceLineNumber) {
        if ($this.MatchOnly) {
            return $ComparisonResults[0].GetCommonLine($ReferenceLineNumber).Line
        }
        else {
            $LineNumbers = @($ReferenceLineNumber)
            $LineNumbers += $ComparisonResults | ForEach-Object { $_.GetCommonLine($ReferenceLineNumber).DiffLineNumber }
            return $this.FormatOutputLine(' ', $LineNumbers, $ComparisonResults[0].GetCommonLine($ReferenceLineNumber).Line)
        }
    }
    # 1行分の出力テキストを生成
    [string]FormatOutputLine([string]$Indicator, [string[]]$LineNumberStrings, [string]$Line) {
        $lineNumberPart = ""
        if ($this.LineNumber) {
            $lineNumberPart = ($LineNumberStrings -join $this.Separator) + $this.Separator
        }
        return "$Indicator$($this.Separator)$lineNumberPart$Line"
    }
}
