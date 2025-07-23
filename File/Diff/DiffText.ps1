<#
.SYNOPSIS
    2つのテキストファイルを比較し、差分のある行を抽出します。

.DESCRIPTION
    このスクリプトは、2つの入力テキストファイルを読み込み、一方にのみ存在する行（差分）を見つけ出します。
    結果は、標準出力に書き出されるか、指定された出力ファイルに保存されます。
    結果には、どちらのファイルに属する行かを示すインジケータ（< Path1のみ, > Path2のみ）が付与されます。-IncludeMatchスイッチを指定すると、一致行も空白インジケータ付きで出力されます。

.PARAMETER Path1
    比較元のファイルパスを指定します。

.PARAMETER Path2
    比較対象のファイルパスを指定します。

.PARAMETER OutputPath
    結果を保存する出力ファイルのパス。指定しない場合、結果は標準出力に表示されます。

.PARAMETER IncludeMatch
    このスイッチを指定すると、差分だけでなく、両方のファイルに存在する一致行も出力します。

.PARAMETER LineNumber
    このスイッチを指定すると、出力に行番号を付けます。短いエイリアス -n も使用できます。

.PARAMETER MatchOnly
    このスイッチを指定すると、差分行を出力せず、一致行のみをインジケータなしで出力します。このオプションは暗黙的に一致行の比較を有効にします。

.PARAMETER Separator
    結果出力時の区切り文字を指定します。指定しない場合は、デフォルトの区切り文字（スペース）が使用されます。

.PARAMETER Encoding
    入出力ファイルのエンコーディングを指定します。デフォルトは 'UTF8' です。

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt
    2つのファイルの差分を標準出力に表示します。

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -OutputPath diff_lines.txt
    2つのファイルの差分を 'diff_lines.txt' に出力します。

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -IncludeMatch
    2つのファイルの一致行と差分行をすべて表示します。

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -MatchOnly
    2つのファイルの一致行のみを、インジケータなしで表示します。（ExtractTextPattern.ps1 と同様の出力）

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -IncludeMatch -n
    行番号付きで、2つのファイルの一致行と差分行をすべて表示します。-n は -LineNumber のエイリアスです。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '比較元のファイルパスを指定します。')]
    [string]$Path1,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = '比較対象のファイルパスを指定します。')]
    [string]$Path2,

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

function Get-ContentWithLineNumber {
    param(
        [string]$Path,
        [string]$Encoding,
        [int]$SourceFileId
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "ファイルが見つかりません: $Path"
    }
    Write-Verbose "${SourceFileId}つ目のファイルを読み込み中: $Path"
    Get-Content -Path $Path -Encoding $Encoding | ForEach-Object -Begin { $i = 1 } -Process {
        [PSCustomObject]@{
            Line       = $_
            LineNumber = $i++
            SourceFile = $SourceFileId # ソート順を安定させるためのキー
        }
    }
}

# Compare-Objectを使用して差分を抽出する
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
    }
    # 後続の行順序を復元するためのオプションを追加
    # if ($IncludeMatch.IsPresent) {
    #     $compareParams['IncludeEqual'] = $true # Compare-Objectには-IncludeEqualを渡す
    # }
    $compareParams['IncludeEqual'] = $true
    Compare-Object @compareParams
}

function Format-DiffOutput {
    param(
        [psobject[]]$DiffObjects,
        [switch]$IncludeMatch,
        [switch]$LineNumber,
        [switch]$MatchOnly,
        [string]$Separator
    )
    # 行番号でソートし直し、出力テキストを整形する
    # 同一行番号の場合は file1 -> file2 の順に並べる
    # $formattedDifferences = $DiffObjects | Sort-Object -Property LineNumber, SourceFile | ForEach-Object {
    #     $indicator = switch ($_.SideIndicator) {
    #         '<=' { '<' } # Path1にのみ存在
    #         '=>' { '>' } # Path2にのみ存在
    #         '==' { ' ' } # 両方に存在
    #     }
    #     "$indicator $($_.Line)"
    # }
    #=> file2で追加された行が本来の位置からズレて出力された。
    # Compare-Objectがfile1とfile2の行番号を十分に保持しないのが問題の模様。

    # 別案
    # ただし、複雑な差分（大きなブロックの挿入/削除など）が発生した場合に、出力の順序が期待通りにならない可能性がありそう。
    # パフォーマンス改善のため、比較結果を行番号をキーとするハッシュテーブルに変換
    $file1Map = @{}
    $file2Map = @{}
    foreach ($obj in $DiffObjects) {
        if ($obj.SourceFile -eq 1) {
            $file1Map[$obj.LineNumber] = $obj
        }
        else {
            $file2Map[$obj.LineNumber] = $obj
        }
    }
    # 行番号順に出力テキストを整形する
    $i = 1
    $j = 1
    while ($true) {
        $file1Diff = $file1Map[$i]
        $file2Diff = $file2Map[$j]
        if ($file1Diff -and $file1Diff.SideIndicator -eq '<=') {
            # file1のみに存在、または変更があった行
            if (-not $MatchOnly.IsPresent) {
                $prefix1 = "<$Separator"
                $prefix2 = if ($LineNumber.IsPresent) { "${i}$Separator$Separator" } else { "" }
                "$prefix1$prefix2$($file1Diff.Line)"
            }
            $i++
        }
        elseif ($file2Diff -and $file2Diff.SideIndicator -eq '=>') {
            # file2のみに存在、または変更があった行
            if (-not $MatchOnly.IsPresent) {
                $prefix1 = ">$Separator"
                $prefix2 = if ($LineNumber.IsPresent) { "$Separator${j}$Separator" } else { "" }
                "$prefix1$prefix2$($file2Diff.Line)"
            }
            $j++
        }
        elseif ($file1Diff -and $file1Diff.SideIndicator -eq '==') {
            # file1,file2で一致した行
            if ($IncludeMatch.IsPresent -or $MatchOnly.IsPresent) {
                if ($MatchOnly.IsPresent) {
                    $file1Diff.Line
                }
                else {
                    $prefix1 = " $Separator"
                    $prefix2 = if ($LineNumber.IsPresent) { "${i}$Separator${j}$Separator" } else { "" }
                    "$prefix1$prefix2$($file1Diff.Line)"
                }
            }
            $i++
            $j++
        }
        else {
            # 想定外のデータはエラーとして報告
            if ($file1Diff) { Write-Error "予期しないデータ: $($file1Diff.SideIndicator) $($file1Diff.Line)" }
            if ($file2Diff) { Write-Error "予期しないデータ: $($file2Diff.SideIndicator) $($file2Diff.Line)" }
            # ループ終了
            break
        }
    }
}

try {
    # .NETのカレントディレクトリをPowerShellのカレントディレクトリに同期させる
    # これにより、[System.IO.Path]::GetFullPath() が期待通りに動作する
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # ファイルを読み込む
    $referenceObject = @(Get-ContentWithLineNumber -Path $Path1 -Encoding $Encoding -SourceFileId 1)
    $differenceObject = @(Get-ContentWithLineNumber -Path $Path2 -Encoding $Encoding -SourceFileId 2)

    # 比較する
    $diffObjects = Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject

    # 結果を出力
    $formattedDifferences = Format-DiffOutput -DiffObjects $diffObjects -IncludeMatch:$IncludeMatch -LineNumber:$LineNumber -MatchOnly:$MatchOnly -Separator $Separator
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # 標準出力へ
        $formattedDifferences
    }
    else {
        # ファイルへ出力
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        # WriteAllLinesはstring[]を要求するため、結果が単一文字列やnullの場合も考慮してキャストする
        [System.IO.File]::WriteAllLines($OutputPath, @($formattedDifferences), $encodingObject)
        Write-Verbose "差分を $OutputPath に出力しました。"
    }
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
