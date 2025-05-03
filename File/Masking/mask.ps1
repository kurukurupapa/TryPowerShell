<#
�l�����܂�CSV�t�@�C�����A�}�X�L���O����CSV�t�@�C���ɕϊ�����X�N���v�g�ł��B

.SYNOPSIS
CSV�t�@�C���̌l���J�������}�X�L���O�����V����CSV�t�@�C�����o�͂��܂��B

.PARAMETER inputPath
����CSV�t�@�C���̃p�X
.PARAMETER outputPath
�o��CSV�t�@�C���̃p�X
.PARAMETER inputEncoding
���̓t�@�C���̃G���R�[�f�B���O�iUTF8 �܂��� SJIS�j
.PARAMETER outputEncoding
�o�̓t�@�C���̃G���R�[�f�B���O�iUTF8 �܂��� SJIS�j

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

# �G���R�[�f�B���O�擾
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

# �}�X�L���O�֐�
function Convert-MaskChar {
    param($char)
    switch ($char) {
        { $_ -match '[0-9]' } { return '9' } # ���p����
        { $_ -match '[A-Za-z]' } { return 'A' } # ���p�p��
        { $_ -match '[�O-�X]' } { return '�X' } # �S�p����
        { $_ -match '[�`-�y��-��]' } { return '�`' } # �S�p�p��
        { $_ -match '[��-��]' } { return '��' } # �S�p�Ђ炪��
        { $_ -match '[�@-���[]' } { return '�A' } # �S�p�J�^�J�i
        { $_ -match '[��-���X�Y����]' } { return '��' } # �S�p�����iSJIS�͈́j
        { $_ -match '[�@-�`�p-���F�v]' } { return '?' } # �L��������
        default { return $char } # �󔒁E�L���Ȃǂ͂��̂܂�
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

Write-Host "�}�X�L���O�ς�CSV�� $outputPath �ɏo�͂��܂����B�i���o�̓G���R�[�f�B���O: $inputEncodingName �� $outputEncodingName�j" 
