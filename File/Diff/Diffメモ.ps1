# ����

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
.\MatchText.ps1 "SampleMatchText\file1.txt"         "SampleMatchText\zero.txt"  "SampleMatchText\match_zero.txt"     # ��v�Ȃ��A���̓[���o�C�g
.\MatchText.ps1 -Encoding "Default" "Sample\file1_sjis_crlf.txt" "Sample\file1_sjis_crlf.txt" "SampleMatchText\match_encoding_sjis.txt"
.\MatchText.ps1 -Encoding "UTF8"    "Sample\file1_utf8_crlf.txt" "Sample\file1_utf8_crlf.txt" "SampleMatchText\match_encoding_utf8.txt"
# �f�[�^�s���e�X�g
.\MatchText.ps1 "xxx.txt" "xxx.txt" "SampleMatchText\xxx.txt"


# MatchText2.ps1
.\MatchText2.ps1 ("SampleMatchText\file1.txt", "SampleMatchText\file2.txt", "SampleMatchText\file3.txt") "SampleMatchText\match2_file1-3.txt"
.\MatchText2.ps1 "SampleMatchText\file*.txt"                                                             "SampleMatchText\match2_wildcard_file1-3.txt"
.\MatchText2.ps1 "SampleMatchText\Sub"                                                                   "SampleMatchText\match2_folder_file1-3.txt"
.\MatchText2.ps1 ("SampleMatchText\file1.txt", "SampleMatchText\zero.txt")  "SampleMatchText\match_zero.txt"  # ��v�Ȃ��A���̓[���o�C�g
.\MatchText2.ps1 -Encoding "Default" ("Sample\file1_sjis_crlf.txt", "Sample\file1b_sjis_crlf.txt") "SampleMatchText\match_encoding_sjis.txt"
.\MatchText2.ps1 -Encoding "UTF8"    ("Sample\file1_utf8_crlf.txt", "Sample\file1b_utf8_crlf.txt") "SampleMatchText\match_encoding_utf8.txt"
# �f�[�^�s���e�X�g
.\MatchText2.ps1 "SampleMatchText\file1.txt" "SampleMatchText\match2.txt"  # ���̓t�@�C��1��
.\MatchText2.ps1 ("xxx.txt", "xxx.txt") "SampleMatchText\match2.txt"       # ���̓t�@�C�������݂��Ȃ�


# DiffText.ps1
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_file1-2.txt"
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\file1.txt" "SampleDiffText\diff_file1-1.txt"   # �����Ȃ�
.\DiffText.ps1               "SampleDiffText\zero.txt"  "SampleDiffText\file1.txt" "SampleDiffText\diff_zero_add.txt"  # ���̓[���o�C�g�A�ǉ������̂�
.\DiffText.ps1               "SampleDiffText\file1.txt" "SampleDiffText\zero.txt"  "SampleDiffText\diff_zero_del.txt"  # ���̓[���o�C�g�A�폜�����̂�
.\DiffText.ps1 -IncludeMatch "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_match_file1-2.txt"
.\DiffText.ps1 -MatchOnly    "SampleDiffText\file1.txt"         "SampleDiffText\file2.txt" "SampleDiffText\match_file1-2.txt"
.\DiffText.ps1 -MatchOnly    "SampleDiffText\match_file1-2.txt" "SampleDiffText\file3.txt" "SampleDiffText\match_file1-3.txt"
.\DiffText.ps1 -n                                        "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_file1-2.txt"
.\DiffText.ps1 -LineNumber                               "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_file1-2.txt"
.\DiffText.ps1 -LineNumber -IncludeMatch                 "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_match_file1-2.txt"
.\DiffText.ps1 -LineNumber -IncludeMatch -Separator "`t" "SampleDiffText\file1.txt" "SampleDiffText\file2.txt" "SampleDiffText\diff_linenumber_match_separator_file1-2.txt"
.\DiffText.ps1 -Encoding "Default" "Sample\file1_sjis_crlf.txt" "Sample\file2_sjis_crlf.txt" "SampleDiffText\diff_encoding_sjis.txt"
.\DiffText.ps1 -Encoding "UTF8"    "Sample\file1_utf8_crlf.txt" "Sample\file2_utf8_crlf.txt" "SampleDiffText\diff_encoding_utf8.txt"
# �f�[�^�s���e�X�g
.\DiffText.ps1 "xxx.txt" "xxx.txt" "SampleDiffText\xxx.txt"


# DiffText2.ps1
Set-Location File\Diff
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
.\DiffText2.ps1                  ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_file1-2.txt"
.\DiffText2.ps1                   "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_file1-3.txt"
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_match_n_file1-2.txt"
.\DiffText2.ps1 -IncludeMatch -n  "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_match_n_file1-3.txt"
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\file1b.txt") "SampleDiffText\diff2_match_n_file1-1.txt"   # �����Ȃ�
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\zero.txt" , "SampleDiffText\file1.txt")  "SampleDiffText\diff2_match_n_zero_add.txt"  # ���̓[���o�C�g�A�ǉ������̂�
.\DiffText2.ps1 -IncludeMatch -n ("SampleDiffText\file1.txt", "SampleDiffText\zero.txt")   "SampleDiffText\diff2_match_n_zero_del.txt"  # ���̓[���o�C�g�A�폜�����̂�
.\DiffText2.ps1 -IncludeMatch    ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\diff2_match_file1-2.txt"
.\DiffText2.ps1 -IncludeMatch     "SampleDiffText\file?.txt"                               "SampleDiffText\diff2_match_file1-3.txt"
.\DiffText2.ps1 -MatchOnly       ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt")  "SampleDiffText\match2_file1-2.txt"
.\DiffText2.ps1 -MatchOnly        "SampleDiffText\file?.txt"                               "SampleDiffText\match2_file1-3.txt"
.\DiffText2.ps1 -LineNumber                               ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt") "SampleDiffText\diff2_linenumber_file1-2.txt"
.\DiffText2.ps1 -Separator "`t" -LineNumber -IncludeMatch ("SampleDiffText\file1.txt", "SampleDiffText\file2.txt") "SampleDiffText\diff2_separator_file1-2.txt"
.\DiffText2.ps1 -Encoding "Default" ("Sample\file1_sjis_crlf.txt", "Sample\file2_sjis_crlf.txt") "SampleDiffText\diff2_encoding_sjis.txt"
.\DiffText2.ps1 -Encoding "UTF8"    ("Sample\file1_utf8_crlf.txt", "Sample\file2_utf8_crlf.txt") "SampleDiffText\diff2_encoding_utf8.txt"
# �f�[�^�s���e�X�g
.\DiffText2.ps1 "SampleDiffText\file1.txt" -OutputPath "SampleDiffText\diff2.txt"  # ���̓t�@�C��1��
.\DiffText2.ps1 ("xxx.txt", "xxx.txt") "SampleDiffText\diff2.txt"                  # ���̓t�@�C�������݂��Ȃ�

# DiffText2Core�e�X�g
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
# �f�[�^�s���e�X�g
.\SplitText.ps1 -LineCount 10 "SampleSplitText\xxx.txt"
# �p�t�H�[�}���X�e�X�g
$begin = Get-Date; .\SplitText.ps1 -SplitAfter  '\[(END|End|end)\]' -Path $bigPath; PrintTime $begin (Get-Date)


# JoinText.ps1
.\JoinText.ps1 -InputPath ("SampleJoinText\part1.txt", "SampleJoinText\part2.txt") -OutputPath "SampleJoinText\join_part1-2.txt"
.\JoinText.ps1 -InputPath "SampleJoinText\part*.txt" -OutputPath "SampleJoinText\join_wildcard_part1-2.txt"
.\JoinText.ps1 -InputPath "SampleJoinText\SubParts" -OutputPath "SampleJoinText\join_folder_subparts.txt"
.\JoinText.ps1 -Encoding "Default" -InputPath "Sample\file1_sjis_crlf.txt" -OutputPath "SampleJoinText\join_file1_sjis.txt"
.\JoinText.ps1 -Encoding "UTF8"    -InputPath "Sample\file1_utf8_crlf.txt" -OutputPath "SampleJoinText\join_file1_utf8.txt"
# �f�[�^�s���e�X�g
.\JoinText.ps1 -InputPath "SampleJoinText\*.xxx" -OutputPath "SampleJoinText\a.xxx"
# �p�t�H�[�}���X�e�X�g
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
# �f�[�^�s���e�X�g
.\ConvertTextEncoding.ps1 "SampleConvertTextEncoding\xxx.txt" "SampleConvertTextEncoding\convert_xxx.txt"
# �p�t�H�[�}���X�e�X�g
$begin = Get-Date; .\ConvertTextEncoding.ps1 -InputEncoding "Default" -OutputEncoding "UTF8" $bigPath "Work\convert.txt"; PrintTime $begin (Get-Date)


# .NET�̃J�����g�f�B���N�g����ݒ�
[System.IO.Directory]::SetCurrentDirectory($env:TEMP)

# Get-Module Pester -ListAvailable #=> Version 3.4.0
# [Pester - The ubiquitous test and mock framework for PowerShell | Pester](https://pester.dev/)
# [pester/Pester at 3.4.0](https://github.com/pester/Pester/tree/3.4.0)


# �Q�l
# Linux diff�R�}���h
# $ diff --help
# �g�p�@: diff [OPTION]... FILES
# FILES ���s���Ƃɔ�r���܂��B
#
# �����`���̃I�v�V�����ŕK�{�̈����́A����ɑΉ�����Z���`���̃I�v�V�����ł����l�ɕK�{�ł��B
#       --normal                  �ʏ�� diff ���o�͂��� (�f�t�H���g)
#   -q, --brief                   �t�@�C�����قȂ邩�ǂ����̂ݕ\������
#   -s, --report-identical-files  �����̃t�@�C��������ł��邩�ǂ����̂ݕ\������
#   -c, -C NUM, --context[=NUM]   �R���e�L�X�g diff �`���őO�� NUM (�f�t�H���g: 3) �s��\������
#   -u, -U NUM, --unified[=NUM]   ���j�t�@�C�h diff �`���őO�� NUM (�f�t�H���g: 3) �s��\������
#   -e, --ed                      ed �X�N���v�g���o�͂���
#   -n, --rcs                     RCS �`���� diff ���o�͂���
#   -y, --side-by-side            �o�͂�2��ɂ���
#   -W, --width=NUM               �\���������ő� NUM (�f�t�H���g: 130) ��ɂ���
#       --left-column             ���ʍs�͍����̗�̂ݕ\������
#       --suppress-common-lines   ���ʍs�̏o�͂�}�~����
#
#   -p, --show-c-function         �ύX������ C �֐���\������
#   -F, --show-function-line=RE   RE �Ɉ�v����ł��߂��s��\������
#       --label LABEL             use LABEL instead of file name and timestamp
#                                   (can be repeated)
#
#   -t, --expand-tabs             �o�͎��Ƀ^�u���X�y�[�X�ɓW�J����
#   -T, --initial-tab             �^�u�Ŏn�܂�s�́A�O�Ƀ^�u��u���Ă��낦��
#       --tabsize=NUM             �^�u���� NUM (�f�t�H���g: 8) ��ɐݒ肷��
#       --suppress-blank-empty    ��̏o�͍s�̑O��ł̓X�y�[�X�܂��̓^�u��}�~����
#   -l, --paginate                pass output through 'pr' to paginate it
#
#   -r, --recursive                 �T�u�f�B���N�g���[���ċA�I�ɔ�r����
#       --no-dereference            don't follow symbolic links
#   -N, --new-file                  ���݂��Ȃ��t�@�C������t�@�C���Ƃ��Ĉ���
#       --unidirectional-new-file   ���݂��Ȃ��ŏ��̃t�@�C������t�@�C���Ƃ��Ĉ���
#       --ignore-file-name-case     �t�@�C�����̑啶���Ə���������ʂ��Ȃ�
#       --no-ignore-file-name-case  �t�@�C�����̑啶���Ə���������ʂ���
#   -x, --exclude=PAT               PAT �Ɉ�v����t�@�C�������O����
#   -X, --exclude-from=FILE         FILE ���̃p�^�[���Ɉ�v����t�@�C�������O����
#   -S, --starting-file=FILE        �f�B���N�g���[���r���鎞�� FILE ����n�߂�
#       --from-file=FILE1           ���ׂĂ̔퉉�Z�q�� FILE1 ���r����
#                                     FILE1 �̓f�B���N�g���[�ł��悢
#       --to-file=FILE2             ���ׂĂ̔퉉�Z�q�� FILE2 ���r����
#                                     FILE2 �̓f�B���N�g���[�ł��悢
#
#   -i, --ignore-case               �t�@�C�����e�̔�r���ɑ啶���Ə���������ʂ��Ȃ�
#   -E, --ignore-tab-expansion      �^�u�W�J�ɂ���Ĕ�������Ⴂ�𖳎�����
#   -Z, --ignore-trailing-space     �s���ɂ���X�y�[�X�𖳎�����
#   -b, --ignore-space-change       �X�y�[�X���ɂ�萶����Ⴂ�𖳎�����
#   -w, --ignore-all-space          ���ׂẴX�y�[�X�𖳎�����
#   -B, --ignore-blank-lines        ignore changes where lines are all blank
#   -I, --ignore-matching-lines=RE  ignore changes where all lines match RE
#
#   -a, --text                      ���ׂẴt�@�C�����e�L�X�g�Ƃ��Ĉ���
#       --strip-trailing-cr         ���͂��� CR (�L�����b�W���^�[��) ����������
#
#   -D, --ifdef=NAME                output merged file with '#ifdef NAME' diffs
#       --GTYPE-group-format=GFMT   GTYPE �̓��̓O���[�v�� GFMT �Ő��`����
#       --line-format=LFMT          ���ׂĂ̓��͍s�� LFMT �Ő��`����
#       --LTYPE-line-format=LFMT    LTYPE ���͍s�� LFMT �Ő��`����
#     �����̏������`�I�v�V������ -D/--ifdef �ɓK�p����� diff �̏o�͂����ꂢ��
#       ������悤�ɐ��䂷�邽�߂ɒ񋟂���܂��B
#     LTYPE is 'old', 'new', or 'unchanged'.  GTYPE is LTYPE or 'changed'.
#     GFMT �ł̂ݎw��ł��鏑��:
#       %<  FILE1 ����̍s
#       %>  FILE2 ����̍s
#       %=  FILE1 �� FILE2 �ŋ��ʂ̍s
#       %[-][WIDTH][.[PREC]]{doxX}LETTER  printf ������ LETTER
#         LETTER �͎��̒ʂ�ł��B�������Â��O���[�v�ł͏������ł�:
#           F  �ŏ��̍s�ԍ�
#           L  �Ō�̍s�ԍ�
#           N  �s�� = L-F+1
#           E  F-1
#           M  L+1
#       %(A=B?T:E)  A �� B ���������ꍇ�� T�A�������Ȃ��ꍇ�� E
#     LFMT �ł̂ݎw��ł��鏑��:
#       %L  �s�̓��e
#       %l  �s���ɂ��邷�ׂĂ̎�ނ̉��s�������������s�̓��e
#       %[-][WIDTH][.[PREC]]{doxX}n  printf �����̓��͍s
#     GFMT �� LFMT �̗����Ŏw�E�ł��鏑��:
#       %%  %
#       %c'C'  �P�ꕶ�� C
#       %c'\OOO'  ���i���R�[�h OOO
#       C    ���� C (���̕��������l�ɕ\��)
#
#   -d, --minimal            �����̑傫�����ŏ��ƂȂ�悤�ɈႢ�����o����
#       --horizon-lines=NUM  �����̑O��ɂ��鋤�ʕ����� NUM �s�ێ�����
#       --speed-large-files  ����ȃt�@�C���ɏ����ȍ��������U���Ă���Ɖ��肷��
#       --color[=WHEN]       color output; WHEN is 'never', 'always', or 'auto';
#                              plain --color means --color='auto'
#       --palette=PALETTE    the colors to use when --color is active; PALETTE is
#                              a colon-separated list of terminfo capabilities
#
#       --help               ���̃w���v��\�����ďI������
#   -v, --version            �o�[�W��������\�����ďI������
#
# FILES are 'FILE1 FILE2' or 'DIR1 DIR2' or 'DIR FILE' or 'FILE DIR'.
#   --from-file �܂��� --to-file ���^����ꂽ�ꍇ�AFILE �ɐ����͂���܂���B
# If a FILE is '-', read standard input.
#   �I���R�[�h�́A���̓t�@�C���������ꍇ�� 0�A���̓t�@�C�����قȂ�ꍇ�� 1�A
# ��肪���������Ƃ��� 2 �ɂȂ�܂��B
#
# Report bugs to: bug-diffutils@gnu.org
# GNU diffutils �̃z�[���y�[�W: <https://www.gnu.org/software/diffutils/>
# General help using GNU software: <https://www.gnu.org/gethelp/>

# cd OneDrive/Dev/TryPowerShell/File/Diff
# diff Sample/file1.txt Sample/file2.txt > Sample/diff_result_default.txt
# diff Sample/file1.txt Sample/file2.txt -C     > Sample/diff_result_c-option.txt
# diff Sample/file1.txt Sample/file2.txt -C 999 > Sample/diff_result_c-option2.txt
# diff Sample/file1.txt Sample/file2.txt -U     > Sample/diff_result_u-option.txt
# diff Sample/file1.txt Sample/file2.txt -U 999 > Sample/diff_result_u-option2.txt
# diff Sample/file1.txt Sample/file2.txt -y > Sample/diff_result_y-option.txt
