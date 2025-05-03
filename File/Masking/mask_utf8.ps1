<#
個人情報を含むCSVファイルを、マスキングしたCSVファイルに変換するスクリプトです。

.SYNOPSIS
CSVファイルの個人情報カラムをマスキングした新しいCSVファイルを出力します。
入出力CSVファイルをUTF-8で固定しています。
当スクリプト自体は、UTF-8 with BOMです。

参考
[[総集編] Pythonで日本語の正規表現チェックをする #日本語入力 - Qiita](https://qiita.com/tikaranimaru/items/a2e85ae66bf75e16f74f)
[文字コード | プログラミング技術](https://so-zou.jp/software/tech/programming/tech/character-code/)
Shift_JIS
[JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
[Microsoftコードページ932 - Wikipedia](https://ja.wikipedia.org/wiki/Microsoft%E3%82%B3%E3%83%BC%E3%83%89%E3%83%9A%E3%83%BC%E3%82%B8932)
[Windows-31J 情報](https://www2d.biglobe.ne.jp/~msyk/charcode/cp932/index.html)
Unicode
[Unicode（東アジア） - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/e_asia.html)
[Unicode Character Table - Full List of Unicode Symbols SYMBL](https://symbl.cc/en/unicode-table/)

.PARAMETER inputPath
入力CSVファイルのパス
.PARAMETER outputPath
出力CSVファイルのパス

.EXAMPLE
powershell -File .\mask_utf8.ps1 ./in.csv ./out.csv
.\File\Masking\mask_utf8.ps1 .\File\Masking\sample_input_utf8.csv .\work\sample_masked_utf8.csv
#>

param(
    [string]$inputPath,
    [string]$outputPath
)

if ($PSBoundParameters.Count -lt 2) {
    Get-Help $MyInvocation.MyCommand.Path
    exit 1
}

# エンコーディングはUTF-8で固定
$encoding = [System.Text.Encoding]::UTF8
$importEncoding = "UTF8"
$exportEncoding = "UTF8"

# マスキング関数
function Convert-MaskChar {
    param($char)
    switch ($char) {
        # 半角数字
        # ASCIIコード：0x30-0x39
        # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)
        { $_ -match '[0-9]' } { return '9' }

        # 全角数字
        # SJISコード：0x824F-0x8258
        # Unicodeコード：0xFF10-0xFF19
        # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
        { $_ -match '[０-９]' } { return '９' }

        # ローマ数字
        # SJISコード：
        #   0x8754-0x875D（Ⅰ-Ⅹ、NEC特殊文字、Unicode→SJIS変換で使用）
        #   0xFA4A-0xFA53（Ⅰ-Ⅹ、IBM拡張文字）
        #   0xFA40-0xFA49（ⅰ-ⅹ、IBM拡張文字、Unicode→SJIS変換で使用）
        #   0xEEEF-0xEEF8（ⅰ-ⅹ、NEC選定IBM拡張文字）
        # Unicodeコード：
        #   0x2160-0x2169（Ⅰ-Ⅹ）、～0x216B（ⅪⅫ）
        #   0x2170-0x2179（ⅰ-ⅹ）、～0x217B（ⅺⅻ）
        # [Windows-31J の重複符号化文字と Unicode](https://www2d.biglobe.ne.jp/~msyk/charcode/cp932/uni2sjis-Windows-31J.html)
        # [Unicode 数字に準じるもの - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u2150.html)
        { $_ -match '[Ⅰ-Ⅹⅰ-ⅹ]' } { return 'Ⅲ' }
        { $_ -match '[Ⅰ-Ⅻⅰ-ⅻ]' } { return 'Ⅳ' }

        # 半角英字
        # ASCIIコード：0x41-0x5A, 0x61-0x7A
        # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)
        { $_ -match '[A-Za-z]' } { return 'A' }

        # 全角英字
        # SJISコード：0x8260-0x8279, 0x8281-0x829A
        # Unicodeコード：0xFF21-0xFF3A, 0xFF41-0xFF5A
        # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
        { $_ -match '[Ａ-Ｚａ-ｚ]' } { return 'Ａ' }

        # 半角カタカナ
        # ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ
        # SJISコード：0xA6-0xDF
        # Unicodeコード：0xFF66-0xFF9F
        # [半角カナ - Wikipedia](https://ja.wikipedia.org/wiki/%E5%8D%8A%E8%A7%92%E3%82%AB%E3%83%8A)
        # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
        # [Unicode Character Table - Full List of Unicode Symbols SYMBL](https://symbl.cc/en/unicode-table/#halfwidth-and-fullwidth-forms)
        { $_ -match '[ｦ-ﾟ]' } { return 'ｱ' }

        # 全角カタカナ
        # ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ
        # SJISコード：0x8340-0x8396
        # Unicodeコード：0x30A1-0x30F6, ～0x30FA（ヷヸヹヺ）
        # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode 片仮名 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u30a0.html)
        { $_ -match '[ァ-ヶ]' } { return 'ア' }
        { $_ -match '[ァ-ヺ]' } { return 'イ' }

        # 全角ひらがな
        # ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん
        # SJISコード：0x829F-0x82F1
        # Unicodeコード：0x3041-0x3093, ～0x3096（ゔゕゖ）
        # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode 平仮名 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u3040.html)
        { $_ -match '[ぁ-ん]' } { return 'あ' }
        { $_ -match '[ぁ-ゖ]' } { return 'い' }

        # 漢字
        # SJISコード：0x889F-0xEAA4（亜-熙）、SJISは第1,2水準のみ。
        # Unicodeコード：0x4E00-0x9FFC（一-鿼）、拡張/互換漢字は省略。
        # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode CJK統合漢字－全漢字一覧 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/cjku_klist.html)
        { $_ -match '[一-鿼]' } { return '亜' }

        # 空白・記号などはそのまま
        default { return $char }
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

Write-Host "マスキング済みCSVを $outputPath に出力しました。"
