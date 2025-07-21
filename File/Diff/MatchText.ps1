<#
.SYNOPSIS
    2つのテキストファイルを比較し、両方のファイルに存在する行を抽出します。

.DESCRIPTION
    このスクリプトは、2つの入力テキストファイルを読み込み、両方のファイルに共通して存在する行を見つけ出します。
    結果は、標準出力に書き出されるか、指定された出力ファイルに保存されます。

.PARAMETER Path1
    比較元のファイルパスを指定します。

.PARAMETER Path2
    比較対象のファイルパスを指定します。

.PARAMETER OutputPath
    結果を保存する出力ファイルのパス。指定しない場合、結果は標準出力に表示されます。

.PARAMETER Encoding
    入出力ファイルのエンコーディングを指定します。デフォルトは 'Default' です。

.EXAMPLE
    .\MatchText.ps1 -Path1 file1.txt -Path2 file2.txt
    2つのファイルの共通行を標準出力に表示します。

.EXAMPLE
    .\MatchText.ps1 -Path1 file1.txt -Path2 file2.txt -OutputPath common_lines.txt
    2つのファイルの共通行を 'common_lines.txt' に出力します。
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '比較元のファイルパスを指定します。')]
    [string]$Path1,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = '比較対象のファイルパスを指定します。')]
    [string]$Path2,

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = '結果を保存する出力ファイルのパスを指定します。')]
    [string]$OutputPath,

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)
try {
    # 比較元のファイルを読み込む
    if (-not (Test-Path -Path $Path1 -PathType Leaf)) {
        throw "ファイルが見つかりません: $Path1"
    }
    Write-Verbose "1つ目のファイルを読み込み中: $Path1"
    $referenceObject = @(Get-Content -Path $Path1 -Encoding $Encoding)

    # 比較対象のファイルを読み込む
    if (-not (Test-Path -Path $Path2 -PathType Leaf)) {
        throw "ファイルが見つかりません: $Path2"
    }
    Write-Verbose "2つ目のファイルを読み込み、比較中: $Path2"
    $differenceObject = @(Get-Content -Path $Path2 -Encoding $Encoding)

    # Compare-Objectを使用して共通行を抽出し、元の行データのみを取り出す
    $matchingLines = Compare-Object -ReferenceObject $referenceObject -DifferenceObject $differenceObject -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue

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
        # WriteAllLinesはstring[]を要求するため、結果が単一の文字列や$nullの場合でも配列に変換します。
        [System.IO.File]::WriteAllLines($OutputPath, @($matchingLines), $encodingObject)
        Write-Verbose "一致した行を $OutputPath に出力しました。"
    }
}
catch {
    Write-Error "処理中にエラーが発生しました: $($_.Exception.Message)"
}
