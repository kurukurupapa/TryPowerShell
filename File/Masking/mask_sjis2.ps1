<#
�l�����܂�CSV�t�@�C�����A�}�X�L���O����CSV�t�@�C���ɕϊ�����X�N���v�g�ł��B

.SYNOPSIS
CSV�t�@�C���̌l���J�������}�X�L���O�����V����CSV�t�@�C�����o�͂��܂��B
���o��CSV�t�@�C����Shift_JIS�ŌŒ肵�Ă��܂��B

�Q�l
[[���W��] Python�œ��{��̐��K�\���`�F�b�N������ #���{����� - Qiita](https://qiita.com/tikaranimaru/items/a2e85ae66bf75e16f74f)
[�����R�[�h | �v���O���~���O�Z�p](https://so-zou.jp/software/tech/programming/tech/character-code/)
[Character Classes in .NET Regular Expressions - .NET | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/standard/base-types/character-classes-in-regular-expressions#supported-unicode-general-categories)
Shift_JIS
[JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
[Microsoft�R�[�h�y�[�W932 - Wikipedia](https://ja.wikipedia.org/wiki/Microsoft%E3%82%B3%E3%83%BC%E3%83%89%E3%83%9A%E3%83%BC%E3%82%B8932)
[Windows-31J ���](https://www2d.biglobe.ne.jp/~msyk/charcode/cp932/index.html)
Unicode
[Unicode�i���A�W�A�j - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/e_asia.html)
[Unicode Character Table - Full List of Unicode Symbols SYMBL](https://symbl.cc/en/unicode-table/)

.PARAMETER inputPath
����CSV�t�@�C���̃p�X
.PARAMETER outputPath
�o��CSV�t�@�C���̃p�X

.EXAMPLE
powershell -File .\mask_sjis2.ps1 .\in.csv .\out.csv
.\File\Masking\mask_sjis2.ps1 .\File\Masking\sample_input_sjis.csv .\work\sample_masked_sjis2.csv
#>

param(
    [string]$inputPath,
    [string]$outputPath
)

if ($PSBoundParameters.Count -lt 2) {
    Get-Help $MyInvocation.MyCommand.Path
    exit 1
}

# �G���R�[�f�B���O��Shift_JIS�iDefault�j�ŌŒ�
#$encoding = [System.Text.Encoding]::GetEncoding("shift_jis")
$importEncoding = "Default"
$exportEncoding = "Default"

# �}�X�L���O�֐�
function Convert-MaskChar {
    param($char)
    switch ($char) {
        # ���p����
        # ASCII�R�[�h�F0x30-0x39
        # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)

        # �S�p����
        # SJIS�R�[�h�F0x824F-0x8258
        # Unicode�R�[�h�F0xFF10-0xFF19
        # [JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode ���p�E�S�p�` - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)

        # ���p/�S�p����
        { $_ -match '\d' } { return '9' }

        # ���[�}����
        # SJIS�R�[�h�F
        #   0x8754-0x875D�i�T-�]�ANEC���ꕶ���AUnicode��SJIS�ϊ��Ŏg�p�j
        #   0xFA4A-0xFA53�i�T-�]�AIBM�g�������j
        #   0xFA40-0xFA49�i�@-�I�AIBM�g�������AUnicode��SJIS�ϊ��Ŏg�p�j
        #   0xEEEF-0xEEF8�i�@-�I�ANEC�I��IBM�g�������j
        # Unicode�R�[�h�F
        #   0x2160-0x2169�i�T-�]�j�A�`0x216B�i??�j
        #   0x2170-0x2179�i�@-�I�j�A�`0x217B�i??�j
        # Unicode�J�e�S���F
        #   0x2150-0x218F�iIsNumberForms�j
        # [Windows-31J �̏d�������������� Unicode](https://www2d.biglobe.ne.jp/~msyk/charcode/cp932/uni2sjis-Windows-31J.html)
        # [Unicode �����ɏ�������� - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u2150.html)
        { $_ -match '\p{IsNumberForms}' } { return '�V' }

        # ���p�p��
        # ASCII�R�[�h�F0x41-0x5A, 0x61-0x7A
        # [ASCII - Wikipedia](https://ja.wikipedia.org/wiki/ASCII)
        { $_ -match '[A-Za-z]' } { return 'A' }

        # �S�p�p��
        # SJIS�R�[�h�F0x8260-0x8279, 0x8281-0x829A
        # Unicode�R�[�h�F0xFF21-0xFF3A, 0xFF41-0xFF5A
        # [JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode ���p�E�S�p�` - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
        { $_ -match '[�`-�y��-��]' } { return '�`' }

        # ���p�J�^�J�i
        # ����������������������������������������������������������
        # SJIS�R�[�h�F0xA6-0xDF
        # Unicode�R�[�h�F0xFF66-0xFF9F
        # [���p�J�i - Wikipedia](https://ja.wikipedia.org/wiki/%E5%8D%8A%E8%A7%92%E3%82%AB%E3%83%8A)
        # [Unicode ���p�E�S�p�` - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/uff00.html)
        # [Unicode Character Table - Full List of Unicode Symbols SYMBL](https://symbl.cc/en/unicode-table/#halfwidth-and-fullwidth-forms)
        { $_ -match '[�-�]' } { return '�' }

        # �S�p�J�^�J�i
        # �@�A�B�C�D�E�F�G�H�I�J�K�L�M�N�O�P�Q�R�S�T�U�V�W�X�Y�Z�[�\�]�^�_�`�a�b�c�d�e�f�g�h�i�j�k�l�m�n�o�p�q�r�s�t�u�v�w�x�y�z�{�|�}�~����������������������������������������������
        # SJIS�R�[�h�F0x8340-0x8396
        # Unicode�R�[�h�F0x30A1-0x30F6, �`0x30FA�i????�j
        # Unicode�J�e�S���F0x30A0-0x30FF�iIsKatakana�j
        # [JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode �Љ��� - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u30a0.html)
        { $_ -match '\p{IsKatakana}' } { return '�A' }

        # �S�p�Ђ炪��
        # �����������������������������������������������������������������������ÂĂłƂǂȂɂʂ˂̂͂΂ςЂт҂ӂԂՂւׂ؂قڂۂ܂݂ނ߂��������������������
        # SJIS�R�[�h�F0x829F-0x82F1
        # Unicode�R�[�h�F0x3041-0x3093, �`0x3096�i???�j
        # Unicode�J�e�S���F0x3040-0x309F�iIsHiragana�j
        # [JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode ������ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/u3040.html)
        { $_ -match '\p{IsHiragana}' } { return '��' }

        # ����
        # SJIS�R�[�h�F0x889F-0xEAA4�i��-꤁j�ASJIS�͑�1,2�����̂݁B
        # Unicode�R�[�h�F0x4E00-0x9FFC�i��-?�j�A�g��/�݊������͏ȗ��B
        # Unicode�J�e�S���F0x4E00-0x9FFF�iIsCJKUnifiedIdeographs�j
        # [JIS X 0208�R�[�h�\ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/jisx0208.html)
        # [Unicode CJK���������|�S�����ꗗ - CyberLibrarian](https://www.asahi-net.or.jp/~ax2s-kmtn/ref/unicode/cjku_klist.html)
        { $_ -match '\p{IsCJKUnifiedIdeographs}' } { return '��' }

        # �󔒁E�L���Ȃǂ͂��̂܂�
        default { return $char }
    }
}
function Convert-Field {
    param($text)
    if ([string]::IsNullOrEmpty($text)) { return $text }
    return ($text.ToCharArray() | ForEach-Object { Convert-MaskChar $_ }) -join ''
}

# CSV�Ǎ��E�}�X�L���O�E�o��
$csv = Import-Csv -Path $inputPath -Encoding $importEncoding
foreach ($row in $csv) {
    # �K�v�ȃJ�������ɍ��킹�ďC�����Ă�������
    if ($row.PSObject.Properties["���O�i�����j"]) { $row.'���O�i�����j' = Convert-Field $row.'���O�i�����j' }
    if ($row.PSObject.Properties["���O�i�ӂ肪�ȁj"]) { $row.'���O�i�ӂ肪�ȁj' = Convert-Field $row.'���O�i�ӂ肪�ȁj' }
    if ($row.PSObject.Properties["���O�i�p���j"]) { $row.'���O�i�p���j' = Convert-Field $row.'���O�i�p���j' }
    if ($row.PSObject.Properties["�Z��1�i�s���{���j"]) { $row.'�Z��1�i�s���{���j' = Convert-Field $row.'�Z��1�i�s���{���j' }
    if ($row.PSObject.Properties["�Z��2"]) { $row.'�Z��2' = Convert-Field $row.'�Z��2' }
    if ($row.PSObject.Properties["�d�b�ԍ�"]) { $row.'�d�b�ԍ�' = Convert-Field $row.'�d�b�ԍ�' }
    if ($row.PSObject.Properties["�a����"]) { $row.'�a����' = Convert-Field $row.'�a����' }
}
$csv | Export-Csv -Path $outputPath -Encoding $exportEncoding -NoTypeInformation

Write-Host "�}�X�L���O�ς�CSV�� $outputPath �ɏo�͂��܂����B"
