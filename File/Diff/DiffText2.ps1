<#
.SYNOPSIS
    �����̃e�L�X�g�t�@�C�����r���A�����̂���s�܂��͈�v����s�𒊏o���܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A�����̓��̓e�L�X�g�t�@�C����ǂݍ��݁A���ׂẴt�@�C���ɋ��ʂ��Ȃ��s�i�����j�������o���܂��B
    ���ʂ́A�W���o�͂ɏ����o����邩�A�w�肳�ꂽ�o�̓t�@�C���ɕۑ�����܂��B
    ���ʂɂ́A�����s�ɂ�'>'�A��v�s�ɂ͋󔒂̃C���W�P�[�^���t�^����܂��B-IncludeMatch�X�C�b�`���w�肷��ƁA��v�s���o�͂���܂��B

.PARAMETER InputPath
    ��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B

.PARAMETER OutputPath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B�w�肵�Ȃ��ꍇ�A���ʂ͕W���o�͂ɕ\������܂��B

.PARAMETER IncludeMatch
    ���̃X�C�b�`���w�肷��ƁA���������łȂ��A���ׂẴt�@�C���ɑ��݂����v�s���o�͂��܂��B

.PARAMETER LineNumber
    ���̃X�C�b�`���w�肷��ƁA�o�͂ɍs�ԍ���t���܂��B�G�C���A�X -n ���g�p�ł��܂��B

.PARAMETER MatchOnly
    ���̃X�C�b�`���w�肷��ƁA�����s���o�͂����A���ׂẴt�@�C���ɋ��ʂ����v�s�݂̂��C���W�P�[�^�Ȃ��ŏo�͂��܂��B

.PARAMETER Separator
    ���ʏo�͎��̋�؂蕶�����w�肵�܂��B�f�t�H���g�̓X�y�[�X�ł��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'Default' (�V�X�e����ANSI�R�[�h�y�[�W) �ł��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt
    2�̃t�@�C���̍�����W���o�͂ɕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -OutputPath diff_lines.txt
    �����̃t�@�C���̍����� 'diff_lines.txt' �ɏo�͂��܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch
    �t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file*.txt -MatchOnly
    �����̃t�@�C���ɋ��ʂ����v�s�݂̂��A�C���W�P�[�^�Ȃ��ŕ\�����܂��B

.EXAMPLE
    .\DiffText2.ps1 Sample\file1.txt Sample\file2.txt -IncludeMatch -n
    �s�ԍ��t���ŁA�t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '��r����t�@�C���p�X��2�ȏ�w�肵�܂��B�t�H���_�p�X�⃏�C���h�J�[�h���g�p�ł��܂��B')]
    [ValidateCount(1, [int]::MaxValue)]
    [string[]]$InputPath,

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = '���ʂ�ۑ�����o�̓t�@�C���̃p�X���w�肵�܂��B')]
    [string]$OutputPath,

    [Parameter(Mandatory = $false, HelpMessage = '��v�s���o�͂Ɋ܂߂�ꍇ�Ɏw�肵�܂��B')]
    [switch]$IncludeMatch,

    [Parameter(Mandatory = $false, HelpMessage = '�o�͂ɍs�ԍ���t����ꍇ�Ɏw�肵�܂��B')]
    [Alias('n')]
    [switch]$LineNumber,

    [Parameter(Mandatory = $false, HelpMessage = '��v�s�݂̂��o�͂���ꍇ�Ɏw�肵�܂��B')]
    [switch]$MatchOnly,

    [Parameter(Mandatory = $false, HelpMessage = '���ʏo�͎��̋�؂蕶�����w�肵�܂��B')]
    [string]$Separator = ' ',

    [ValidateSet('UTF8', 'Default')]
    [string]$Encoding = 'Default'
)

function Write-OutputContent {
    param(
        [string[]]$Content
    )
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # �W���o�͂�
        $Content
    }
    else {
        # �t�@�C���֏o��
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        [System.IO.File]::WriteAllLines($OutputPath, $Content, $encodingObject)
        Write-Verbose "�o�͂��܂����B$OutputPath"
    }
}

try {
    . "$PSScriptRoot\Debug.ps1"
    . "$PSScriptRoot\DiffText2Core.ps1"

    # .NET�̃J�����g�f�B���N�g����PowerShell�̃J�����g�f�B���N�g���ɓ���������
    # ����ɂ��A[System.IO.Path]::GetFullPath() �����Ғʂ�ɓ��삷��
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # ���̓p�X�������i���C���h�J�[�h�ƃt�H���_�W�J�j
    # -ErrorAction Stop ���w�肵�āA�p�X��������Ȃ��ꍇ��catch�u���b�N�ŏ����ł���悤�ɂ���
    $resolvedFilePaths = (Get-ChildItem -Path $InputPath -File -ErrorAction Stop).FullName | Get-Unique

    # ��r����t�@�C����2�ȏ゠�邩�m�F
    if ($resolvedFilePaths.Count -lt 2) {
        throw "��r�Ώۂ̃t�@�C����2�ȏ㌩����܂���ł����B�w�肳�ꂽ�p�X���m�F���Ă��������B"
    }

    # �e�t�@�C�����r���A�ڍׂȔ�r���ʃf�[�^�𐶐����܂��B
    $comparer = [FileComparer]::new()
    $fileComparisonResults = $comparer.CompareFilesAsResults($resolvedFilePaths, $Encoding)

    # ���ʂ��o��
    Write-Verbose "���ʏo�͒�"
    $formatter = [ComparisonResultsFormatter]::new()
    $formatter.IncludeMatch = $IncludeMatch
    $formatter.MatchOnly = $MatchOnly
    $formatter.LineNumber = $LineNumber
    $formatter.Separator = $Separator
    $formattedDifferences = $formatter.Format($fileComparisonResults)
    Write-OutputContent -Content $formattedDifferences
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
