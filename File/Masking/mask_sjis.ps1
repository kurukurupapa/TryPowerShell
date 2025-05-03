<#
個人情報を含むCSVファイルを、マスキングしたCSVファイルに変換するスクリプトです。

.SYNOPSIS
CSVファイルの個人情報カラムをマスキングした新しいCSVファイルを出力します。

.PARAMETER inputPath
入力CSVファイルのパス
.PARAMETER outputPath
出力CSVファイルのパス
.PARAMETER inputEncoding
入力ファイルのエンコーディング（UTF8 または SJIS）
.PARAMETER outputEncoding
出力ファイルのエンコーディング（UTF8 または SJIS）

.EXAMPLE
powershell -File .\mask.ps1 ./in.csv ./out.csv UTF8 SJIS
.\File\Masking\mask.ps1 .\File\Masking\sample_input_sjis.csv .\work\sample_masked_sjis.csv SJIS SJIS
#>

param(
    [string]$inputPath,
    [string]$outputPath,
    [ValidateSet("UTF8", "SJIS")]
    [string]$inputEncodingName,
    [ValidateSet("UTF8", "SJIS")]
    [string]$outputEncodingName
)

if ($PSBoundParameters.Count -lt 4) {
    Get-Help $MyInvocation.MyCommand.Path
    exit 1
}

# エンコーディング取得
if ($inputEncodingName -eq "SJIS") {
    $inputEncoding = [System.Text.Encoding]::GetEncoding("shift_jis")
    $importEncoding = "Default"
} else {
    $inputEncoding = [System.Text.Encoding]::UTF8
    $importEncoding = "UTF8"
}
if ($outputEncodingName -eq "SJIS") {
    $outputEncoding = [System.Text.Encoding]::GetEncoding("shift_jis")
    $exportEncoding = "Default"
} else {
    $outputEncoding = [System.Text.Encoding]::UTF8
    $exportEncoding = "UTF8"
}

# マスキング関数
function Convert-MaskChar {
    param($char)
    switch ($char) {
        { $_ -match '[0-9]' } { return '9' } # 半角数字
        { $_ -match '[A-Za-z]' } { return 'A' } # 半角英字
        { $_ -match '[０-９]' } { return '９' } # 全角数字
        { $_ -match '[Ａ-Ｚａ-ｚ]' } { return 'Ａ' } # 全角英字
        { $_ -match '[ぁ-ん]' } { return 'あ' } # 全角ひらがな
        { $_ -match '[ァ-ヶー]' } { return 'ア' } # 全角カタカナ
        { $_ -match '[一-麿々〆ヵヶ]' } { return '亜' } # 全角漢字（SJIS範囲）
        { $_ -match '[А-Яа-яЁё]' } { return '?' } # キリル文字
        default { return $char } # 空白・記号などはそのまま
    }
}
function Convert-Field {
    param($text)
    if ([string]::IsNullOrEmpty($text)) { return $text }
    return ($text.ToCharArray() | ForEach-Object { Convert-MaskChar $_ }) -join ''
}

# CSV読込・マスキング・出力
$csv = Import-Csv -Path $inputPath -Encoding $importEncoding
foreach ($row in $csv) {
    # 必要なカラム名に合わせて修正してください
    if ($row.PSObject.Properties["名前（漢字）"]) { $row.'名前（漢字）' = Convert-Field $row.'名前（漢字）' }
    if ($row.PSObject.Properties["名前（ふりがな）"]) { $row.'名前（ふりがな）' = Convert-Field $row.'名前（ふりがな）' }
    if ($row.PSObject.Properties["名前（英字）"]) { $row.'名前（英字）' = Convert-Field $row.'名前（英字）' }
    if ($row.PSObject.Properties["住所1（都道府県）"]) { $row.'住所1（都道府県）' = Convert-Field $row.'住所1（都道府県）' }
    if ($row.PSObject.Properties["住所2"]) { $row.'住所2' = Convert-Field $row.'住所2' }
    if ($row.PSObject.Properties["電話番号"]) { $row.'電話番号' = Convert-Field $row.'電話番号' }
    if ($row.PSObject.Properties["誕生日"]) { $row.'誕生日' = Convert-Field $row.'誕生日' }
}
$csv | Export-Csv -Path $outputPath -Encoding $exportEncoding -NoTypeInformation

Write-Host "マスキング済みCSVを $outputPath に出力しました。（入出力エンコーディング: $inputEncodingName → $outputEncodingName）" 
