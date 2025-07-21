<#
.SYNOPSIS
    テキストファイルの文字エンコードと改行コードを変換します。

.DESCRIPTION
    指定された入力ファイルを読み込み、指定された文字エンコードと改行コードで新しいファイルに出力します。

.PARAMETER InputPath
    変換元の入力ファイルパスを指定します。

.PARAMETER OutputPath
    変換後の出力ファイルパスを指定します。

.PARAMETER InputEncoding
    入力ファイルの文字エンコードを指定します。
    指定可能な値: Default, SJIS, UTF8, UTF8BOM
    DefaultとSJISはShift_JIS、UTF8はBOMなし、UTF8BOMはBOMありのUTF-8として扱います。(読み込み時、UTF8/UTF8BOMはBOMの有無を自動判別します)

.PARAMETER OutputEncoding
    出力ファイルの文字エンコードを指定します。
    指定可能な値: Default, SJIS, UTF8, UTF8BOM
    DefaultとSJISはShift_JIS、UTF8はBOMなしUTF-8、UTF8BOMはBOM付きUTF-8です。

.PARAMETER NewLine
    出力ファイルの改行コードを指定します。
    指定可能な値: CRLF, LF

.EXAMPLE
    # Shift_JIS(Default)のファイルを、BOMなしUTF-8、改行コードLFに変換する
    .\Convert-TextEncoding.ps1 -InputPath 'sjis_file.txt' -OutputPath 'utf8_file.txt' -InputEncoding Default -OutputEncoding UTF8 -NewLine LF

.EXAMPLE
    # UTF-8のファイルを、Shift_JIS(Default)、改行コードCRLFに変換する
    .\Convert-TextEncoding.ps1 -InputPath 'utf8_file.txt' -OutputPath 'sjis_file.txt' -InputEncoding UTF8 -OutputEncoding Default -NewLine CRLF

.EXAMPLE
    # 詳細なログを表示しながら変換する
    .\Convert-TextEncoding.ps1 -InputPath 'in.txt' -OutputPath 'out.txt' -OutputEncoding UTF8 -Verbose
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputPath,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$OutputPath,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Default', 'SJIS', 'UTF8', 'UTF8BOM')]
    [string]$InputEncoding = 'Default',

    [Parameter(Mandatory = $false)]
    [ValidateSet('Default', 'SJIS', 'UTF8', 'UTF8BOM')]
    [string]$OutputEncoding = 'Default',

    [Parameter(Mandatory = $false)]
    [ValidateSet("CRLF", "LF")]
    [string]$NewLine = "CRLF"
)

try {
    # .NETのカレントディレクトリをPowerShellのカレントディレクトリに同期させる
    # これにより、[System.IO.Path]::GetFullPath() が期待通りに動作する
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # パスを絶対パスに解決する
    # 入力パスは存在する必要があるため Resolve-Path を使用 →エラーメッセージが分かりにくくなるのでGetFullPathを使用
    # $absoluteInputPath = (Resolve-Path -Path $InputPath -ErrorAction Stop).ProviderPath
    $absoluteInputPath = [System.IO.Path]::GetFullPath($InputPath)
    # 出力パスは存在しない可能性があるため、.NETメソッドで絶対パスを生成
    $absoluteOutputPath = [System.IO.Path]::GetFullPath($OutputPath)

    # ファイルの存在チェック
    if (-not (Test-Path -Path $absoluteInputPath -PathType Leaf)) {
        throw "入力ファイルが見つかりません: $absoluteInputPath"
    }

    # 改行コードを設定
    $newLineCode = switch ($NewLine) {
        "CRLF" { "`r`n" }
        "LF" { "`n" }
    }

    # Get-Contentが受け付けるエンコーディング名に変換する
    $readEncoding = switch ($InputEncoding) {
        'SJIS' { 'Default' }
        'UTF8BOM' { 'UTF8' }
        default { $InputEncoding } # Default, UTF8
    }

    # ファイルを読み込み (-Rawでファイル全体を単一の文字列として読み込む)
    Write-Verbose "入力ファイルを読み込んでいます..."
    $content = Get-Content -Path $absoluteInputPath -Encoding $readEncoding -Raw

    # 改行コードをLFに正規化してから、指定の改行コードに変換
    Write-Verbose "改行コードを変換しています..."
    $normalizedContent = $content.Replace("`r`n", "`n").Replace("`r", "`n")
    $convertedContent = $normalizedContent.Replace("`n", $newLineCode)

    # 指定されたエンコーディングでファイルに書き出し
    Write-Verbose "変換後のファイルを出力しています..."
    # if ($OutputEncoding -eq 'UTF8NoBOM') {
    #     $encodingObject = New-Object System.Text.UTF8Encoding($false)
    #     [System.IO.File]::WriteAllText($OutputPath, $convertedContent, $encodingObject)
    # }
    # else {
    #     Set-Content -Path $OutputPath -Value $convertedContent -Encoding $OutputEncoding -NoNewline
    # }
    $encodingObject = switch ($OutputEncoding) {
        'UTF8' { New-Object System.Text.UTF8Encoding($false) } # BOMなし
        'UTF8BOM' { New-Object System.Text.UTF8Encoding($true) }  # BOM付き
        'SJIS' { [System.Text.Encoding]::GetEncoding('shift_jis') } # Shift_JIS
        'Default' { [System.Text.Encoding]::Default }             # システムの既定 (日本語環境ではShift_JIS)
    }

    # .NETメソッドは末尾に改行を自動追加しないため、-NoNewlineは不要
    [System.IO.File]::WriteAllText($absoluteOutputPath, $convertedContent, $encodingObject)

    Write-Host "変換処理が正常に完了しました。 -> $absoluteOutputPath"
}
catch {
    Write-Error "エラーが発生しました: $($_.Exception.Message)"
    exit 1
}
