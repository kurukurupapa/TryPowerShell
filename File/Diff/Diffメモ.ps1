# メモ

Set-Location File\Diff
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
function PrintTimeSpan($begin, $end) {
    $span = $end - $begin
    Write-Host $span.TotalSeconds
}
function CreateDummyFile($size) {
    # $size = 100  # MB
    $path = "Work\file_${size}MB.txt"
    ("1234567890" * 10 + "`r`n") * 10000 * $size | Set-Content $path
    return $path
}
$bigPath = CreateDummyFile 100


# MatchText.ps1
.\MatchText.ps1 "SampleMatchText\file1.txt"         "SampleMatchText\file2.txt" "SampleMatchText\match_file1-2.txt"
.\MatchText.ps1 "SampleMatchText\match_file1-2.txt" "SampleMatchText\file3.txt" "SampleMatchText\match_file1-3.txt"
.\MatchText.ps1 "SampleMatchText\file1.txt"         "SampleMatchText\zero.txt"  "SampleMatchText\match_zero.txt"     # 一致なし、入力ゼロバイト
.\MatchText.ps1 -Encoding "Default" "Sample\file1_sjis_crlf.txt" "Sample\file1_sjis_crlf.txt" "SampleMatchText\match_encoding_sjis.txt"
.\MatchText.ps1 -Encoding "UTF8"    "Sample\file1_utf8_crlf.txt" "Sample\file1_utf8_crlf.txt" "SampleMatchText\match_encoding_utf8.txt"
# データ不備テスト
.\MatchText.ps1 "xxx.txt" "xxx.txt" "SampleMatchText\xxx.txt"


# MatchText2.ps1
.\MatchText2.ps1 ("SampleMatchText\file1.txt", "SampleMatchText\file2.txt", "SampleMatchText\file3.txt") "SampleMatchText\match2_file1-3.txt"
.\MatchText2.ps1 "SampleMatchText\file*.txt"                                                             "SampleMatchText\match2_wildcard_file1-3.txt"
.\MatchText2.ps1 "SampleMatchText\Sub"                                                                   "SampleMatchText\match2_folder_file1-3.txt"
.\MatchText2.ps1 ("SampleMatchText\file1.txt", "SampleMatchText\zero.txt")  "SampleMatchText\match_zero.txt"  # 一致なし、入力ゼロバイト
.\MatchText2.ps1 -Encoding "Default" ("Sample\file1_sjis_crlf.txt", "Sample\file1b_sjis_crlf.txt") "SampleMatchText\match_encoding_sjis.txt"
.\MatchText2.ps1 -Encoding "UTF8"    ("Sample\file1_utf8_crlf.txt", "Sample\file1b_utf8_crlf.txt") "SampleMatchText\match_encoding_utf8.txt"
# データ不備テスト
.\MatchText2.ps1 "SampleMatchText\file1.txt" "SampleMatchText\match2.txt"  # 入力ファイル1件
.\MatchText2.ps1 ("xxx.txt", "xxx.txt") "SampleMatchText\match2.txt"       # 入力ファイルが存在しない


# DiffText.ps1
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_file1-2.txt"
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\file1.txt" "SampleDiffText\diff_file1-1.txt"   # 差分なし
.\DiffText.ps1               "SampleDiffText\zero.txt"  "SampleDiffText\file1.txt" "SampleDiffText\diff_zero_add.txt"  # 入力ゼロバイト、追加差分のみ
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\zero.txt"  "SampleDiffText\diff_zero_del.txt"  # 入力ゼロバイト、削除差分のみ
.\DiffText.ps1 -IncludeMatch "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_match_file1-2.txt"
.\DiffText.ps1 -MatchOnly    "SampleDiffText\file1.txt"         "SampleDiffText\file2.txt" "SampleDiffText\match_file1-2.txt"
.\DiffText.ps1 -MatchOnly    "SampleDiffText\match_file1-2.txt" "SampleDiffText\file3.txt" "SampleDiffText\match_file1-3.txt"
.\DiffText.ps1 -n                                        "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_file1-2.txt"
.\DiffText.ps1 -LineNumber                               "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_file1-2.txt"
.\DiffText.ps1 -LineNumber -IncludeMatch                 "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_match_file1-2.txt"
.\DiffText.ps1 -LineNumber -IncludeMatch -Separator "`t" "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_match_separator_file1-2.txt"
.\DiffText.ps1 -Encoding "Default" "Sample\file1_sjis_crlf.txt" "Sample\file2_sjis_crlf.txt" "SampleDiffText\diff_encoding_sjis.txt"
.\DiffText.ps1 -Encoding "UTF8"    "Sample\file1_utf8_crlf.txt" "Sample\file2_utf8_crlf.txt" "SampleDiffText\diff_encoding_utf8.txt"
# データ不備テスト
.\DiffText.ps1 "xxx.txt" "xxx.txt" "SampleDiffText\xxx.txt"


# DiffText2.ps1
Set-Location File\Diff
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
.\DiffText2.ps1                  ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_file1-2.txt"
.\DiffText2.ps1                   "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_file1-3.txt"
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_match_n_file1-2.txt"
.\DiffText2.ps1 -IncludeMatch -n  "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_match_n_file1-3.txt"
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\file1b.txt") "SampleDiffText\diff2_match_n_file1-1.txt"   # 差分なし
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\zero.txt" , "SampleDiffText\file1.txt")  "SampleDiffText\diff2_match_n_zero_add.txt"  # 入力ゼロバイト、追加差分のみ
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\zero.txt")   "SampleDiffText\diff2_match_n_zero_del.txt"  # 入力ゼロバイト、削除差分のみ
.\DiffText2.ps1 -IncludeMatch    ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_match_file1-2.txt"
.\DiffText2.ps1 -IncludeMatch     "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_match_file1-3.txt"
.\DiffText2.ps1 -MatchOnly       ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\match2_file1-2.txt"
.\DiffText2.ps1 -MatchOnly        "SampleDiffText\file?.txt"                               "SampleDiffText\match2_file1-3.txt"
.\DiffText2.ps1 -LineNumber                               ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt") "SampleDiffText\diff2_linenumber_file1-2.txt"
.\DiffText2.ps1 -Separator "`t" -LineNumber -IncludeMatch ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt") "SampleDiffText\diff2_separator_file1-2.txt"
.\DiffText2.ps1 -Encoding "Default" ("Sample\file1_sjis_crlf.txt", "Sample\file2_sjis_crlf.txt") "SampleDiffText\diff2_encoding_sjis.txt"
.\DiffText2.ps1 -Encoding "UTF8"    ("Sample\file1_utf8_crlf.txt", "Sample\file2_utf8_crlf.txt") "SampleDiffText\diff2_encoding_utf8.txt"
# データ不備テスト
.\DiffText2.ps1 "SampleDiffText\file1.txt" -OutputPath "SampleDiffText\diff2.txt"  # 入力ファイル1件
.\DiffText2.ps1 ("xxx.txt", "xxx.txt") "SampleDiffText\diff2.txt"                  # 入力ファイルが存在しない

# DiffText2Coreテスト
# New-Fixture -Name DiffText2_Content
# Invoke-Pester .\DiffText2_Content.Tests.ps1 -CodeCoverage .\DiffText2_Content.ps1
# New-Fixture -Name DiffText2_Result
# Invoke-Pester .\DiffText2_Result.Tests.ps1 -CodeCoverage .\DiffText2_Result.ps1
# New-Fixture -Name DiffText2_ResultsFormatter
# Invoke-Pester .\DiffText2_ResultsFormatter.Tests.ps1 -CodeCoverage .\DiffText2_ResultsFormatter.ps1
Set-Location File\Diff
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
Invoke-Pester .\DiffText2Core.Tests.ps1 -CodeCoverage .\DiffText2Core.ps1
Invoke-Pester .\DiffText2Core.Tests.ps1 -TestName "ComparisonLine"
Invoke-Pester .\DiffText2Core.Tests.ps1 -TestName "FileComparer"
Invoke-Pester .\DiffText2Core.Tests.ps1 -TestName "ComparisonResult"
Invoke-Pester .\DiffText2Core.Tests.ps1 -TestName "ComparisonResultsFormatter"
Invoke-Pester .\DiffText2Core.Tests.ps1 -TestName "Other"


# SplitText.ps1
.\SplitText.ps1 -LineCount 10 "SampleSplitText\page_line_30.txt"
.\SplitText.ps1 -LineCount 10 "SampleSplitText\page_line_31.txt"
.\SplitText.ps1 -LineCount 99 "SampleSplitText\page_line_3.txt"
.\SplitText.ps1 -SplitBefore '\[(START|Start|start)\]' -Path 'SampleSplitText\records1.txt'
.\SplitText.ps1 -SplitAfter  '\[(END|End|end)\]' -Path 'SampleSplitText\records2.txt'
.\SplitText.ps1 -Encoding "Default" -LineCount 10 "Sample\file1_sjis_crlf.txt" -OutputDirectory "SampleSplitText"
.\SplitText.ps1 -Encoding "UTF8"    -LineCount 10 "Sample\file1_utf8_crlf.txt" -OutputDirectory "SampleSplitText"
# データ不備テスト
.\SplitText.ps1 -LineCount 10 "SampleSplitText\xxx.txt"
# パフォーマンステスト
$begin = Get-Date; .\SplitText.ps1 -SplitAfter  '\[(END|End|end)\]' -Path $bigPath; PrintTime $begin (Get-Date)


# JoinText.ps1
.\JoinText.ps1 -InputPath ("SampleJoinText\part1.txt", "SampleJoinText\part2.txt") -OutputPath "SampleJoinText\join_part1-2.txt"
.\JoinText.ps1 -InputPath "SampleJoinText\part*.txt" -OutputPath "SampleJoinText\join_wildcard_part1-2.txt"
.\JoinText.ps1 -InputPath "SampleJoinText\SubParts" -OutputPath "SampleJoinText\join_folder_subparts.txt"
.\JoinText.ps1 -Encoding "Default" -InputPath "Sample\file1_sjis_crlf.txt" -OutputPath "SampleJoinText\join_file1_sjis.txt"
.\JoinText.ps1 -Encoding "UTF8"    -InputPath "Sample\file1_utf8_crlf.txt" -OutputPath "SampleJoinText\join_file1_utf8.txt"
# データ不備テスト
.\JoinText.ps1 -InputPath "SampleJoinText\*.xxx" -OutputPath "SampleJoinText\a.xxx"
# パフォーマンステスト
$begin = Get-Date; .\JoinText.ps1 -InputPath $bigPath -OutputPath "Work\join.txt"; PrintTime $begin (Get-Date)


# ConvertTextEncoding.ps1
.\ConvertTextEncoding.ps1 -InputEncoding "Default" -OutputEncoding "Default" "Sample\file1_sjis_crlf.txt" "SampleConvertTextEncoding\convert_file1_default_default_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "SJIS"    -OutputEncoding "SJIS"    "Sample\file1_sjis_crlf.txt" "SampleConvertTextEncoding\convert_file1_sjis_sjis_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "SJIS"    -OutputEncoding "UTF8"    "Sample\file1_sjis_crlf.txt" "SampleConvertTextEncoding\convert_file1_sjis_utf8_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "SJIS"    -OutputEncoding "UTF8BOM" "Sample\file1_sjis_crlf.txt" "SampleConvertTextEncoding\convert_file1_sjis_utf8bom_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8"    -OutputEncoding "SJIS"    "Sample\file1_utf8_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8_sjis_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8"    -OutputEncoding "UTF8"    "Sample\file1_utf8_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8_utf8_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8"    -OutputEncoding "UTF8BOM" "Sample\file1_utf8_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8_utf8bom_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8BOM" -OutputEncoding "SJIS"    "Sample\file1_utf8bom_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8bom_sjis_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8BOM" -OutputEncoding "UTF8"    "Sample\file1_utf8bom_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8bom_utf8_crlf.txt"
.\ConvertTextEncoding.ps1 -InputEncoding "UTF8BOM" -OutputEncoding "UTF8BOM" "Sample\file1_utf8bom_crlf.txt" "SampleConvertTextEncoding\convert_file1_utf8bom_utf8bom_crlf.txt"
.\ConvertTextEncoding.ps1 -Newline "CRLF" "Sample\file1_sjis_lf.txt"   "SampleConvertTextEncoding\convert_newline_file1_crlf.txt"
.\ConvertTextEncoding.ps1 -Newline "LF"   "Sample\file1_sjis_crlf.txt" "SampleConvertTextEncoding\convert_newline_file1_lf.txt"
# データ不備テスト
.\ConvertTextEncoding.ps1 "SampleConvertTextEncoding\xxx.txt" "SampleConvertTextEncoding\convert_xxx.txt"
# パフォーマンステスト
$begin = Get-Date; .\ConvertTextEncoding.ps1 -InputEncoding "Default" -OutputEncoding "UTF8" $bigPath "Work\convert.txt"; PrintTime $begin (Get-Date)


# .NETのカレントディレクトリを設定
[System.IO.Directory]::SetCurrentDirectory($env:TEMP)

# Get-Module Pester -ListAvailable #=> Version 3.4.0
# [Pester - The ubiquitous test and mock framework for PowerShell | Pester](https://pester.dev/)
# [pester/Pester at 3.4.0](https://github.com/pester/Pester/tree/3.4.0)


# 参考
# Linux diffコマンド
# $ diff --help
# 使用法: diff [OPTION]... FILES
# FILES を行ごとに比較します。
#
# 長い形式のオプションで必須の引数は、それに対応する短い形式のオプションでも同様に必須です。
#       --normal                  通常の diff を出力する (デフォルト)
#   -q, --brief                   ファイルが異なるかどうかのみ表示する
#   -s, --report-identical-files  両方のファイルが同一であるかどうかのみ表示する
#   -c, -C NUM, --context[=NUM]   コンテキスト diff 形式で前後 NUM (デフォルト: 3) 行を表示する
#   -u, -U NUM, --unified[=NUM]   ユニファイド diff 形式で前後 NUM (デフォルト: 3) 行を表示する
#   -e, --ed                      ed スクリプトを出力する
#   -n, --rcs                     RCS 形式の diff を出力する
#   -y, --side-by-side            出力を2列にする
#   -W, --width=NUM               表示する列を最大 NUM (デフォルト: 130) 列にする
#       --left-column             共通行は左側の列のみ表示する
#       --suppress-common-lines   共通行の出力を抑止する
#
#   -p, --show-c-function         変更がある C 関数を表示する
#   -F, --show-function-line=RE   RE に一致する最も近い行を表示する
#       --label LABEL             use LABEL instead of file name and timestamp
#                                   (can be repeated)
#
#   -t, --expand-tabs             出力時にタブをスペースに展開する
#   -T, --initial-tab             タブで始まる行は、前にタブを置いてそろえる
#       --tabsize=NUM             タブ幅を NUM (デフォルト: 8) 列に設定する
#       --suppress-blank-empty    空の出力行の前後ではスペースまたはタブを抑止する
#   -l, --paginate                pass output through 'pr' to paginate it
#
#   -r, --recursive                 サブディレクトリーを再帰的に比較する
#       --no-dereference            don't follow symbolic links
#   -N, --new-file                  存在しないファイルを空ファイルとして扱う
#       --unidirectional-new-file   存在しない最初のファイルを空ファイルとして扱う
#       --ignore-file-name-case     ファイル名の大文字と小文字を区別しない
#       --no-ignore-file-name-case  ファイル名の大文字と小文字を区別する
#   -x, --exclude=PAT               PAT に一致するファイルを除外する
#   -X, --exclude-from=FILE         FILE 内のパターンに一致するファイルを除外する
#   -S, --starting-file=FILE        ディレクトリーを比較する時に FILE から始める
#       --from-file=FILE1           すべての被演算子と FILE1 を比較する
#                                     FILE1 はディレクトリーでもよい
#       --to-file=FILE2             すべての被演算子を FILE2 を比較する
#                                     FILE2 はディレクトリーでもよい
#
#   -i, --ignore-case               ファイル内容の比較時に大文字と小文字を区別しない
#   -E, --ignore-tab-expansion      タブ展開によって発生する違いを無視する
#   -Z, --ignore-trailing-space     行末にあるスペースを無視する
#   -b, --ignore-space-change       スペース数により生じる違いを無視する
#   -w, --ignore-all-space          すべてのスペースを無視する
#   -B, --ignore-blank-lines        ignore changes where lines are all blank
#   -I, --ignore-matching-lines=RE  ignore changes where all lines match RE
#
#   -a, --text                      すべてのファイルをテキストとして扱う
#       --strip-trailing-cr         入力から CR (キャリッジリターン) を除去する
#
#   -D, --ifdef=NAME                output merged file with '#ifdef NAME' diffs
#       --GTYPE-group-format=GFMT   GTYPE の入力グループを GFMT で整形する
#       --line-format=LFMT          すべての入力行を LFMT で整形する
#       --LTYPE-line-format=LFMT    LTYPE 入力行を LFMT で整形する
#     これらの書式整形オプションは -D/--ifdef に適用される diff の出力をきれいに
#       見えるように制御するために提供されます。
#     LTYPE is 'old', 'new', or 'unchanged'.  GTYPE is LTYPE or 'changed'.
#     GFMT でのみ指定できる書式:
#       %<  FILE1 からの行
#       %>  FILE2 からの行
#       %=  FILE1 と FILE2 で共通の行
#       %[-][WIDTH][.[PREC]]{doxX}LETTER  printf 書式の LETTER
#         LETTER は次の通りです。ただし古いグループでは小文字です:
#           F  最初の行番号
#           L  最後の行番号
#           N  行数 = L-F+1
#           E  F-1
#           M  L+1
#       %(A=B?T:E)  A と B が等しい場合は T、等しくない場合は E
#     LFMT でのみ指定できる書式:
#       %L  行の内容
#       %l  行末にあるすべての種類の改行文字を除いた行の内容
#       %[-][WIDTH][.[PREC]]{doxX}n  printf 書式の入力行
#     GFMT と LFMT の両方で指摘できる書式:
#       %%  %
#       %c'C'  単一文字 C
#       %c'\OOO'  八進数コード OOO
#       C    文字 C (他の文字も同様に表す)
#
#   -d, --minimal            差分の大きさが最小となるように違いを検出する
#       --horizon-lines=NUM  差分の前後にある共通部分を NUM 行保持する
#       --speed-large-files  巨大なファイルに小さな差分が分散していると仮定する
#       --color[=WHEN]       color output; WHEN is 'never', 'always', or 'auto';
#                              plain --color means --color='auto'
#       --palette=PALETTE    the colors to use when --color is active; PALETTE is
#                              a colon-separated list of terminfo capabilities
#
#       --help               このヘルプを表示して終了する
#   -v, --version            バージョン情報を表示して終了する
#
# FILES are 'FILE1 FILE2' or 'DIR1 DIR2' or 'DIR FILE' or 'FILE DIR'.
#   --from-file または --to-file が与えられた場合、FILE に制限はありません。
# If a FILE is '-', read standard input.
#   終了コードは、入力ファイルが同じ場合は 0、入力ファイルが異なる場合は 1、
# 問題が発生したときは 2 になります。
#
# Report bugs to: bug-diffutils@gnu.org
# GNU diffutils のホームページ: <https://www.gnu.org/software/diffutils/>
# General help using GNU software: <https://www.gnu.org/gethelp/>

# cd OneDrive/Dev/TryPowerShell/File/Diff
# diff Sample/file1.txt Sample/file2.txt > Sample/diff_result_default.txt
# diff Sample/file1.txt Sample/file2.txt -C     > Sample/diff_result_c-option.txt
# diff Sample/file1.txt Sample/file2.txt -C 999 > Sample/diff_result_c-option2.txt
# diff Sample/file1.txt Sample/file2.txt -U     > Sample/diff_result_u-option.txt
# diff Sample/file1.txt Sample/file2.txt -U 999 > Sample/diff_result_u-option2.txt
# diff Sample/file1.txt Sample/file2.txt -y > Sample/diff_result_y-option.txt
