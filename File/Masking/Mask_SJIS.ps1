<#
個人情報を含むCSVファイルを、マスキングしたCSVファイルに変換するスクリプトです。

.SYNOPSIS
CSVファイルの個人情報カラムをマスキングした新しいCSVファイルを出力します。
入出力CSVファイルをShift_JISで固定しています。

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

.PARAMETER InputPath
入力CSVファイルのパス
.PARAMETER OutputPath
出力CSVファイルのパス

.EXAMPLE
powershell -File Mask_SJIS.ps1 in.csv out.csv
.\File\Masking\Mask_SJIS.ps1 .\File\Masking\SampleInput\sjis_CRLF.csv .\File\Masking\SampleOutput_Mask_SJIS\sjis_CRLF.csv
#>

param(
    [string]$InputPath,
    [string]$OutputPath
)

if ($PSBoundParameters.Count -lt 2) {
    Get-Help $MyInvocation.MyCommand.Path
    exit 1
}

# マスキング関数
function Convert-Field {
    param($text)
    if ([string]::IsNullOrEmpty($text)) { return $text }

    # 半角数字
    # ASCIIコード：0x30-0x39
    # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)
    $text = $text -replace '[0-9]', '9'

    # 全角数字
    # SJISコード：0x824F-0x8258
    # Unicodeコード：0xFF10-0xFF19
    # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
    # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
    $text = $text -replace '[０-９]', '９'

    # ローマ数字
    # SJISコード：
    #   0x8754-0x875D（�T-�]、NEC特殊文字、Unicode→SJIS変換で使用）
    #   0xFA4A-0xFA53（�T-�]、IBM拡張文字）
    #   0xFA40-0xFA49（�@-�I、IBM拡張文字、Unicode→SJIS変換で使用）
    #   0xEEEF-0xEEF8（�@-�I、NEC選定IBM拡張文字）
    # Unicodeコード：
    #   0x2160-0x2169（�T-�]）、〜0x216B（??）
    #   0x2170-0x2179（�@-�I）、〜0x217B（??）
    # Unicodeカテゴリ：
    #   0x2150-0x218F（IsNumberForms）
    # [Windows-31J の重複符号化文字と Unicode](https://www2d.biglobe.ne.jp/~msyk/charcode/cp932/uni2sjis-Windows-31J.html)
    # [Unicode 数字に準じるもの - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u2150.html)
    $text = $text -replace '[�T-�]�@-�I]', '�V'

    # 半角英字
    # ASCIIコード：0x41-0x5A, 0x61-0x7A
    # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)
    $text = $text -replace '[A-Za-z]', 'A'

    # 全角英字
    # SJISコード：0x8260-0x8279, 0x8281-0x829A
    # Unicodeコード：0xFF21-0xFF3A, 0xFF41-0xFF5A
    # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
    # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
    $text = $text -replace '[Ａ-Ｚａ-ｚ]', 'Ａ'

    # 半角カタカナ
    # ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞﾟ
    # SJISコード：0xA6-0xDF
    # Unicodeコード：0xFF66-0xFF9F
    # [半角カナ - Wikipedia](https://ja.wikipedia.org/wiki/%E5%8D%8A%E8%A7%92%E3%82%AB%E3%83%8A)
    # [Unicode 半角・全角形 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
    # [Unicode Character Table - Full List of Unicode Symbols SYMBL](https://symbl.cc/en/unicode-table/#halfwidth-and-fullwidth-forms)
    $text = $text -replace '[ｦ-ﾟ]', 'ｱ'

    # 全角カタカナ
    # ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶ
    # SJISコード：0x8340-0x8396
    # Unicodeコード：0x30A1-0x30F6, 〜0x30FA（????）
    # Unicodeカテゴリ：0x30A0-0x30FF（IsKatakana）
    # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
    # [Unicode 片仮名 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u30a0.html)
    $text = $text -replace '[ァ-ヶ]', 'ア'

    # 全角ひらがな
    # ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをん
    # SJISコード：0x829F-0x82F1
    # Unicodeコード：0x3041-0x3093, 〜0x3096（???）
    # Unicodeカテゴリ：0x3040-0x309F（IsHiragana）
    # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
    # [Unicode 平仮名 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u3040.html)
    $text = $text -replace '[ぁ-ん]', 'あ'

    # 漢字
    # SJISコード：0x889F-0xEAA4（亜-熙）、SJISは第1,2水準のみ。
    # Unicodeコード：0x4E00-0x9FFC（一-?）、拡張/互換漢字は省略。
    # Unicodeカテゴリ：0x4E00-0x9FFF（IsCJKUnifiedIdeographs）
    # [JIS X 0208コード表 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
    # [Unicode CJK統合漢字−全漢字一覧 - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/cjku_klist.html)
    #{ $_ -match '[亜-熙]' } { return '亜' }
    # →NG。変換されない漢字あり。Powershellでは内部的にUTF-16で処理しているから？
    # Unicode CJK統合漢字 のうち、SJISで表現できそうな範囲で変換してみる。
    $text = $text -replace '[一-龠]', '亜'
    return $text
}

# 処理開始
$startTime = Get-Date
Write-Host "START $($startTime.ToString('yyyy/MM/dd HH:mm:ss'))"

# CSVストリーム処理
$first = $true
$count = 0
$columnIndexes = @{}
$columnNames = @('名前（漢字）', '名前（ふりがな）', '名前（英字）', '住所1（都道府県）', '住所2', '電話番号', '誕生日')
Get-Content $InputPath | ForEach-Object {
    $columns = $_ -split ','
    if ($first) {
        $first = $false
        # マスキング対象カラムのインデックス番号を保持
        $columnIndexes = @()
        for ($i = 0; $i -lt $columns.Count; $i++) {
            $column = $columns[$i] -replace '^"(.*)"$', '$1'
            if ($columnNames -contains $column) {
                $columnIndexes += $i
            }
        }
    }
    else {
        $count++
        # マスキング対象カラムのみ処理
        for ($i = 0; $i -lt $columns.Count; $i++) {
            if ($columnIndexes -contains $i) {
                $columns[$i] = Convert-Field $columns[$i]
            }
        }
    }
    # CSV行を生成
    $csvLine = $columns -join ','
    return $csvLine
} |
Set-Content $OutputPath

Write-Host "マスキング済みCSVを $OutputPath に出力しました。"
$endTime = Get-Date
Write-Host "END $($endTime.ToString('yyyy/MM/dd HH:mm:ss'))"
Write-Host "データ件数: $count"
Write-Host "処理時間: $(($endTime - $startTime).ToString())"
