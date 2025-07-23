<#
.SYNOPSIS
    �����̃e�L�X�g�t�@�C�����r���A���ׂẴt�@�C���ɑ��݂���s�𒊏o���܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A�����̓��̓e�L�X�g�t�@�C����ǂݍ��݁A���ׂẴt�@�C���ɋ��ʂ��đ��݂���s�������o���܂��B
    ���ʂ́A�W���o�͂ɏ����o����邩�A�w�肳�ꂽ�o�̓t�@�C���ɕۑ�����܂��B

.PARAMETER InputPath
    ��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B
    �������ꂽ���ׂẴt�@�C���ɂ��āA�ŏ���2���r���A���̌��ʂ�3�ڂ��r...�Ƃ����悤�ɏ������s����܂��B

.PARAMETER OutputPath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X�B�w�肵�Ȃ��ꍇ�A���ʂ͕W���o�͂ɕ\������܂��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'Default' �ł��B

.EXAMPLE
    .\MatchText2.ps1 -InputPath file1.txt, file2.txt, file3.txt
    3�̃t�@�C���̋��ʍs��W���o�͂ɕ\�����܂��B

.EXAMPLE
    .\MatchText2.ps1 file1.txt file2.txt -OutputPath common_lines.txt
    2�̃t�@�C���̋��ʍs�� 'common_lines.txt' �ɏo�͂��܂��B

.EXAMPLE
    .\MatchText2.ps1 -InputPath C:\Logs\*.log, C:\Archive\
    C:\Logs �t�H���_���̑S���O�t�@�C���� C:\Archive �t�H���_���̑S�t�@�C���̋��ʍs�𒊏o���܂��B
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B')]
    [ValidateCount(1, [int]::MaxValue)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = '���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B')]
    [string]$OutputPath,

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)
try {
    # .NET�̃J�����g�f�B���N�g����PowerShell�̃J�����g�f�B���N�g���ɓ���������
    # ����ɂ��A[System.IO.Path]::GetFullPath() �����Ғʂ�ɓ��삷��
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # ���̓p�X�������i���C���h�J�[�h�ƃt�H���_�W�J�j
    Write-Verbose "���̓p�X���������Ă��܂�: $($InputPath -join ', ')"
    # -ErrorAction Stop ���w�肵�āA�p�X��������Ȃ��ꍇ��catch�u���b�N�ŏ����ł���悤�ɂ���
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique
    Write-Verbose "�������ꂽ�t�@�C��: $($resolvedFilePaths -join ', ')"

    # ��r����t�@�C����2�ȏ゠�邩�m�F
    if ($resolvedFilePaths.Count -lt 2) {
        throw "��r�Ώۂ̃t�@�C����2�ȏ㌩����܂���ł����B�w�肳�ꂽ�p�X���m�F���Ă��������B"
    }

    # �ŏ��̃t�@�C����ǂݍ���
    $firstPath = $resolvedFilePaths[0]
    Write-Verbose "1�ڂ̃t�@�C����ǂݍ��ݒ�: $firstPath"
    [string[]]$matchingLines = @(Get-Content -Path $firstPath -Encoding $Encoding)

    # 2�ڈȍ~�̃t�@�C����������r
    for ($i = 1; $i -lt $resolvedFilePaths.Count; $i++) {
        # �r���ň�v����s���Ȃ��Ȃ�Ώ������I��
        if ($matchingLines.Count -eq 0) {
            Write-Verbose "�r���ň�v����s���Ȃ��Ȃ�܂����B�����𒆒f���܂��B"
            break
        }

        $currentPath = $resolvedFilePaths[$i]
        Write-Verbose "$($i + 1)�ڂ̃t�@�C����ǂݍ��݁A��r��: $currentPath"
        $differenceObject = @(Get-Content -Path $currentPath -Encoding $Encoding)

        # Compare-Object���g�p���ċ��ʍs�𒊏o���A���̍s�f�[�^�݂̂����o��
        $matchingLines = @(Compare-Object -ReferenceObject $matchingLines -DifferenceObject $differenceObject -IncludeEqual -ExcludeDifferent | Select-Object -ExpandProperty InputObject -ErrorAction SilentlyContinue)
    }

    # ���ʂ��o��
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # �W���o�͂�
        $matchingLines
    }
    else {
        # �t�@�C���֏o��
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        # WriteAllLines��string[]��v�����邽�߁A���ʂ��P��̕������$null�ɂȂ�\�����l�����A�m���ɔz��Ƃ��ēn�����߂�@()�ň݂͂܂��B
        [System.IO.File]::WriteAllLines($OutputPath, @($matchingLines), $encodingObject)
        Write-Verbose "��v�����s�� $OutputPath �ɏo�͂��܂����B"
    }
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
