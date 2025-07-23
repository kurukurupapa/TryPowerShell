<#
.SYNOPSIS
    2�̃e�L�X�g�t�@�C�����r���A�����̂���s�𒊏o���܂��B

.DESCRIPTION
    ���̃X�N���v�g�́A2�̓��̓e�L�X�g�t�@�C����ǂݍ��݁A����ɂ̂ݑ��݂���s�i�����j�������o���܂��B
    ���ʂ́A�W���o�͂ɏ����o����邩�A�w�肳�ꂽ�o�̓t�@�C���ɕۑ�����܂��B
    ���ʂɂ́A�ǂ���̃t�@�C���ɑ�����s���������C���W�P�[�^�i< Path1�̂�, > Path2�̂݁j���t�^����܂��B-IncludeMatch�X�C�b�`���w�肷��ƁA��v�s���󔒃C���W�P�[�^�t���ŏo�͂���܂��B

.PARAMETER Path1
    ��r���̃t�@�C���p�X���w�肵�܂��B

.PARAMETER Path2
    ��r�Ώۂ̃t�@�C���p�X���w�肵�܂��B

.PARAMETER OutputPath
    ���ʂ�ۑ�����o�̓t�@�C���̃p�X�B�w�肵�Ȃ��ꍇ�A���ʂ͕W���o�͂ɕ\������܂��B

.PARAMETER IncludeMatch
    ���̃X�C�b�`���w�肷��ƁA���������łȂ��A�����̃t�@�C���ɑ��݂����v�s���o�͂��܂��B

.PARAMETER LineNumber
    ���̃X�C�b�`���w�肷��ƁA�o�͂ɍs�ԍ���t���܂��B�Z���G�C���A�X -n ���g�p�ł��܂��B

.PARAMETER MatchOnly
    ���̃X�C�b�`���w�肷��ƁA�����s���o�͂����A��v�s�݂̂��C���W�P�[�^�Ȃ��ŏo�͂��܂��B���̃I�v�V�����͈ÖٓI�Ɉ�v�s�̔�r��L���ɂ��܂��B

.PARAMETER Separator
    ���ʏo�͎��̋�؂蕶�����w�肵�܂��B�w�肵�Ȃ��ꍇ�́A�f�t�H���g�̋�؂蕶���i�X�y�[�X�j���g�p����܂��B

.PARAMETER Encoding
    ���o�̓t�@�C���̃G���R�[�f�B���O���w�肵�܂��B�f�t�H���g�� 'UTF8' �ł��B

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt
    2�̃t�@�C���̍�����W���o�͂ɕ\�����܂��B

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -OutputPath diff_lines.txt
    2�̃t�@�C���̍����� 'diff_lines.txt' �ɏo�͂��܂��B

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -IncludeMatch
    2�̃t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -MatchOnly
    2�̃t�@�C���̈�v�s�݂̂��A�C���W�P�[�^�Ȃ��ŕ\�����܂��B�iExtractTextPattern.ps1 �Ɠ��l�̏o�́j

.EXAMPLE
    .\File\Diff\DiffText.ps1 -Path1 Sample\file1.txt -Path2 Sample\file2.txt -IncludeMatch -n
    �s�ԍ��t���ŁA2�̃t�@�C���̈�v�s�ƍ����s�����ׂĕ\�����܂��B-n �� -LineNumber �̃G�C���A�X�ł��B
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0, HelpMessage = '��r���̃t�@�C���p�X���w�肵�܂��B')]
    [string]$Path1,

    [Parameter(Mandatory = $true, Position = 1, HelpMessage = '��r�Ώۂ̃t�@�C���p�X���w�肵�܂��B')]
    [string]$Path2,

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

function Get-ContentWithLineNumber {
    param(
        [string]$Path,
        [string]$Encoding,
        [int]$SourceFileId
    )
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "�t�@�C����������܂���: $Path"
    }
    Write-Verbose "${SourceFileId}�ڂ̃t�@�C����ǂݍ��ݒ�: $Path"
    Get-Content -Path $Path -Encoding $Encoding | ForEach-Object -Begin { $i = 1 } -Process {
        [PSCustomObject]@{
            Line       = $_
            LineNumber = $i++
            SourceFile = $SourceFileId # �\�[�g�������肳���邽�߂̃L�[
        }
    }
}

# Compare-Object���g�p���č����𒊏o����
function Compare-FileObject {
    param(
        [psobject[]]$ReferenceObject,
        [psobject[]]$DifferenceObject
    )
    $compareParams = @{
        ReferenceObject  = $ReferenceObject
        DifferenceObject = $DifferenceObject
        Property         = 'Line'
        PassThru         = $true
    }
    # �㑱�̍s�����𕜌����邽�߂̃I�v�V������ǉ�
    # if ($IncludeMatch.IsPresent) {
    #     $compareParams['IncludeEqual'] = $true # Compare-Object�ɂ�-IncludeEqual��n��
    # }
    $compareParams['IncludeEqual'] = $true
    Compare-Object @compareParams
}

function Format-DiffOutput {
    param(
        [psobject[]]$DiffObjects,
        [switch]$IncludeMatch,
        [switch]$LineNumber,
        [switch]$MatchOnly,
        [string]$Separator
    )
    # �s�ԍ��Ń\�[�g�������A�o�̓e�L�X�g�𐮌`����
    # ����s�ԍ��̏ꍇ�� file1 -> file2 �̏��ɕ��ׂ�
    # $formattedDifferences = $DiffObjects | Sort-Object -Property LineNumber, SourceFile | ForEach-Object {
    #     $indicator = switch ($_.SideIndicator) {
    #         '<=' { '<' } # Path1�ɂ̂ݑ���
    #         '=>' { '>' } # Path2�ɂ̂ݑ���
    #         '==' { ' ' } # �����ɑ���
    #     }
    #     "$indicator $($_.Line)"
    # }
    #=> file2�Œǉ����ꂽ�s���{���̈ʒu����Y���ďo�͂��ꂽ�B
    # Compare-Object��file1��file2�̍s�ԍ����\���ɕێ����Ȃ��̂����̖͗l�B

    # �ʈ�
    # �������A���G�ȍ����i�傫�ȃu���b�N�̑}��/�폜�Ȃǁj�����������ꍇ�ɁA�o�͂̏��������Ғʂ�ɂȂ�Ȃ��\�������肻���B
    # �p�t�H�[�}���X���P�̂��߁A��r���ʂ��s�ԍ����L�[�Ƃ���n�b�V���e�[�u���ɕϊ�
    $file1Map = @{}
    $file2Map = @{}
    foreach ($obj in $DiffObjects) {
        if ($obj.SourceFile -eq 1) {
            $file1Map[$obj.LineNumber] = $obj
        }
        else {
            $file2Map[$obj.LineNumber] = $obj
        }
    }
    # �s�ԍ����ɏo�̓e�L�X�g�𐮌`����
    $i = 1
    $j = 1
    while ($true) {
        $file1Diff = $file1Map[$i]
        $file2Diff = $file2Map[$j]
        if ($file1Diff -and $file1Diff.SideIndicator -eq '<=') {
            # file1�݂̂ɑ��݁A�܂��͕ύX���������s
            if (-not $MatchOnly.IsPresent) {
                $prefix1 = "<$Separator"
                $prefix2 = if ($LineNumber.IsPresent) { "${i}$Separator$Separator" } else { "" }
                "$prefix1$prefix2$($file1Diff.Line)"
            }
            $i++
        }
        elseif ($file2Diff -and $file2Diff.SideIndicator -eq '=>') {
            # file2�݂̂ɑ��݁A�܂��͕ύX���������s
            if (-not $MatchOnly.IsPresent) {
                $prefix1 = ">$Separator"
                $prefix2 = if ($LineNumber.IsPresent) { "$Separator${j}$Separator" } else { "" }
                "$prefix1$prefix2$($file2Diff.Line)"
            }
            $j++
        }
        elseif ($file1Diff -and $file1Diff.SideIndicator -eq '==') {
            # file1,file2�ň�v�����s
            if ($IncludeMatch.IsPresent -or $MatchOnly.IsPresent) {
                if ($MatchOnly.IsPresent) {
                    $file1Diff.Line
                }
                else {
                    $prefix1 = " $Separator"
                    $prefix2 = if ($LineNumber.IsPresent) { "${i}$Separator${j}$Separator" } else { "" }
                    "$prefix1$prefix2$($file1Diff.Line)"
                }
            }
            $i++
            $j++
        }
        else {
            # �z��O�̃f�[�^�̓G���[�Ƃ��ĕ�
            if ($file1Diff) { Write-Error "�\�����Ȃ��f�[�^: $($file1Diff.SideIndicator) $($file1Diff.Line)" }
            if ($file2Diff) { Write-Error "�\�����Ȃ��f�[�^: $($file2Diff.SideIndicator) $($file2Diff.Line)" }
            # ���[�v�I��
            break
        }
    }
}

try {
    # .NET�̃J�����g�f�B���N�g����PowerShell�̃J�����g�f�B���N�g���ɓ���������
    # ����ɂ��A[System.IO.Path]::GetFullPath() �����Ғʂ�ɓ��삷��
    [System.IO.Directory]::SetCurrentDirectory((Get-Location).Path)

    # �t�@�C����ǂݍ���
    $referenceObject = @(Get-ContentWithLineNumber -Path $Path1 -Encoding $Encoding -SourceFileId 1)
    $differenceObject = @(Get-ContentWithLineNumber -Path $Path2 -Encoding $Encoding -SourceFileId 2)

    # ��r����
    $diffObjects = Compare-FileObject -ReferenceObject $referenceObject -DifferenceObject $differenceObject

    # ���ʂ��o��
    $formattedDifferences = Format-DiffOutput -DiffObjects $diffObjects -IncludeMatch:$IncludeMatch -LineNumber:$LineNumber -MatchOnly:$MatchOnly -Separator $Separator
    if ([string]::IsNullOrEmpty($OutputPath)) {
        # �W���o�͂�
        $formattedDifferences
    }
    else {
        # �t�@�C���֏o��
        $encodingObject = switch ($Encoding) {
            'UTF8' { New-Object System.Text.UTF8Encoding($false) }
            'Default' { [System.Text.Encoding]::Default }
        }
        # WriteAllLines��string[]��v�����邽�߁A���ʂ��P�ꕶ�����null�̏ꍇ���l�����ăL���X�g����
        [System.IO.File]::WriteAllLines($OutputPath, @($formattedDifferences), $encodingObject)
        Write-Verbose "������ $OutputPath �ɏo�͂��܂����B"
    }
}
catch {
    Write-Error "�������ɃG���[���������܂���: $($_.Exception.Message)"
}
