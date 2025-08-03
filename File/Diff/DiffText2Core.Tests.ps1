$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

$log = "$here\Work\DiffText2Core_Result.Tests.log"
Clear-Content -Path $log
function Write-Log {
    param (
        [string]$Message
    )
    $Message | Add-Content -Path $log
}

Describe "ComparisonLine" {
    It "Calls ComparisonLine constructor" {
        $comparisonLine = [ComparisonLine]@{ Line = "Line 1: This is a test line."; LineNumber = 1; SourceFileIndex = 2 }
        ($comparisonLine | ConvertTo-Json -Compress) | Should Be (
            [ComparisonLine]@{ Line = "Line 1: This is a test line."; LineNumber = 1; SourceFileIndex = 2 } | ConvertTo-Json -Compress
        )
    }
}

Describe "FileComparer" {
    It "Calls FileComparer.GetComparisonLines, ����null" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines($null, 1)
        #=> �{���͋�z��u@()�v��ԋp���Ăق�����Powershell�d�l��$null�ɂȂ� 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.GetComparisonLines, ����0��" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines(@(), 1)
        #=> �{���͋�z��u@()�v��ԋp���Ăق�����Powershell�d�l��$null�ɂȂ� 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.GetComparisonLines, ����1��" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines(@(
                "Line 1: This is a test line."
            ), 1)
        ($comparisonLines | ConvertTo-Json -Compress) | Should Be (@(
                [ComparisonLine]@{ Line = "Line 1: This is a test line."; LineNumber = 1; SourceFileIndex = 1 }
            ) | ConvertTo-Json -Compress)
    }

    It "Calls FileComparer.GetComparisonLines, ����3��" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines(@(
                "Line 1: This is a test line.",
                "Line 2: Another test line.",
                "Line 3: Yet another test line."
            ), 2)
        ($comparisonLines | ConvertTo-Json -Compress) | Should Be (@(
                [ComparisonLine]@{ Line = "Line 1: This is a test line."; LineNumber = 1; SourceFileIndex = 2 },
                [ComparisonLine]@{ Line = "Line 2: Another test line."; LineNumber = 2; SourceFileIndex = 2 },
                [ComparisonLine]@{ Line = "Line 3: Yet another test line."; LineNumber = 3; SourceFileIndex = 2 }
            ) | ConvertTo-Json -Compress)
    }

    # It "Calls FileComparer.CompareComparisonLines, ����null" {
    #     $comparisonLines = [FileComparer]::CompareComparisonLines($null, $null)
    #     #=> ���{�s�H
    #     #   ParameterBindingValidationException: ������ null �ł��邽�߁A�p�����[�^�[ 'ReferenceObject' �Ƀo�C���h�ł��܂���B
    #     #=> �{���͋�z��u@()�v��ԋp���Ăق�����Powershell�d�l��$null�ɂȂ� 
    #     $comparisonLines | Should Be $null
    # }

    It "Calls FileComparer.CompareComparisonLines, ����0��" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.CompareComparisonLines(@(), @())
        #=> �{���͋�z��u@()�v��ԋp���Ăق�����Powershell�d�l��$null�ɂȂ� 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.CompareComparisonLines, ���̓f�[�^����" {
        # Compare-Object������̃I�v�V�����ŌĂяo���Ă��邱�Ƃ��m�F����
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.CompareComparisonLines(@(
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 1; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "�폜�s"; LineNumber = 2; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 3; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 4; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "�ύX�O"; LineNumber = 5; SourceFileIndex = 0 }
            ), @(
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 1; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 2; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "�ǉ��s"; LineNumber = 3; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "��v�s"; LineNumber = 4; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "�ύX��"; LineNumber = 5; SourceFileIndex = 1 }
            ))
        ($comparisonLines | ConvertTo-Json -Compress) | Should Be (@(
                [PSCustomObject]@{ Line = "��v�s"; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "��v�s"; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "��v�s"; LineNumber = 4; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "�ǉ��s"; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' },
                [PSCustomObject]@{ Line = "�ύX��"; LineNumber = 5; SourceFileIndex = 1; SideIndicator = '=>' },
                [PSCustomObject]@{ Line = "�폜�s"; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                [PSCustomObject]@{ Line = "�ύX�O"; LineNumber = 5; SourceFileIndex = 0; SideIndicator = '<=' }
            ) | ConvertTo-Json -Compress)
    }
}

Describe "ComparisonResult" {
    It "Calls ComparisonResult constructor, ����null" {
        $comparisonResult = [ComparisonResult]::new($null)
        Write-Log "Calls ComparisonResult constructor, ����null"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMinReferenceLineNumber() | Should Be -1
        $comparisonResult.GetMaxReferenceLineNumber() | Should Be -1
    }

    It "Calls ComparisonResult constructor, ����0��" {
        $comparisonResult = [ComparisonResult]::new(@())
        Write-Log "Calls ComparisonResult constructor, ����0��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMinReferenceLineNumber() | Should Be -1
        $comparisonResult.GetMaxReferenceLineNumber() | Should Be -1
    }

    It "Calls ComparisonResult constructor, ��v�s1��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        Write-Log "Calls ComparisonResult constructor, ��v�s1��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        $comparisonResult.HasLine(0) | Should Be $false
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $false
        $comparisonResult.HasCommonLine(0) | Should Be $false
        $comparisonResult.HasCommonLine(1) | Should Be $true
        $comparisonResult.HasCommonLine(2) | Should Be $false
        ($comparisonResult.GetCommonLine(0) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, ��v�s3��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        Write-Log "Calls ComparisonResult constructor, ��v�s3��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $true
        $comparisonResult.HasLine(3) | Should Be $true
        $comparisonResult.HasCommonLine(1) | Should Be $true
        $comparisonResult.HasCommonLine(2) | Should Be $true
        $comparisonResult.HasCommonLine(3) | Should Be $true
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 3  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �폜�s1��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }))
        Write-Log "Calls ComparisonResult constructor, �폜�s1��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        $comparisonResult.HasLine(0) | Should Be $false
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $false
        $comparisonResult.HasRemovedLine(0) | Should Be $false
        $comparisonResult.HasRemovedLine(1) | Should Be $true
        $comparisonResult.HasRemovedLine(2) | Should Be $false
        ($comparisonResult.GetRemovedLine(0) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �폜�s3��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }))
        Write-Log "Calls ComparisonResult constructor, �폜�s3��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $true
        $comparisonResult.HasLine(3) | Should Be $true
        $comparisonResult.HasRemovedLine(1) | Should Be $true
        $comparisonResult.HasRemovedLine(2) | Should Be $true
        $comparisonResult.HasRemovedLine(3) | Should Be $true
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ǉ��s1��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, �ǉ��s1��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 0
        $comparisonResult.HasLine(0) | Should Be $true
        $comparisonResult.HasLine(1) | Should Be $false
        $comparisonResult.HasAddedLines(0) | Should Be $true
        $comparisonResult.HasAddedLines(1) | Should Be $false
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 3
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ǉ��s3��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, �ǉ��s3��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 0
        $comparisonResult.HasLine(0) | Should Be $true
        $comparisonResult.HasLine(1) | Should Be $false
        $comparisonResult.HasAddedLines(0) | Should Be $true
        $comparisonResult.HasAddedLines(1) | Should Be $false
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                    DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                    DiffLineNumber  = 3  # ��r�t�@�C���̍s�ԍ�
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ύX1��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1  # ��t�@�C���̍s�ԍ�
                    SourceFileIndex = 0  # 0:��t�@�C��
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 1 �ύX��'
                    LineNumber      = 1  # ��r�t�@�C���̍s�ԍ�
                    SourceFileIndex = 3  # 1�ȏ�:��r�t�@�C��
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, �ύX�s1��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        $comparisonResult.HasLine(0) | Should Be $false
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $false
        $comparisonResult.HasRemovedLine(0) | Should Be $false
        $comparisonResult.HasRemovedLine(1) | Should Be $true
        $comparisonResult.HasRemovedLine(2) | Should Be $false
        $comparisonResult.HasAddedLines(0) | Should Be $false
        $comparisonResult.HasAddedLines(1) | Should Be $true
        $comparisonResult.HasAddedLines(2) | Should Be $false
        ($comparisonResult.GetRemovedLine(0) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1 �ύX��'
                LineNumber      = 1
                SourceFileIndex = 3
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ύX2��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1  # ��t�@�C���̍s�ԍ�
                    SourceFileIndex = 0  # 0:��t�@�C��
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2  # ��t�@�C���̍s�ԍ�
                    SourceFileIndex = 0  # 0:��t�@�C��
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 1 �ύX��'
                    LineNumber      = 1  # ��r�t�@�C���̍s�ԍ�
                    SourceFileIndex = 3  # 1�ȏ�:��r�t�@�C��
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 2 �ύX��'
                    LineNumber      = 2  # ��r�t�@�C���̍s�ԍ�
                    SourceFileIndex = 3  # 1�ȏ�:��r�t�@�C��
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, �ύX�s2��"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 2
        $comparisonResult.HasLine(1) | Should Be $true
        $comparisonResult.HasLine(2) | Should Be $true
        $comparisonResult.HasRemovedLine(1) | Should Be $true
        $comparisonResult.HasRemovedLine(2) | Should Be $true
        $comparisonResult.HasAddedLines(1) | Should Be $false
        $comparisonResult.HasAddedLines(2) | Should Be $true
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 1 �ύX��'
                    LineNumber      = 1
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                    DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
                }, @{
                    Line            = 'Test line 2 �ύX��'
                    LineNumber      = 2
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, ��v�s�E�폜�s" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }))
        Write-Log "Calls ComparisonResult constructor, ��v�s�E�폜�s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, ��v�s�E�ǉ��s" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 2 �ǉ�'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 3 �ǉ�'
                    LineNumber      = 3
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, ��v�s�E�ǉ��s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 2 �ǉ�'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
                }, @{
                    Line            = 'Test line 3 �ǉ�'
                    LineNumber      = 3
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 3  # ��r�t�@�C���̍s�ԍ�
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �폜�s�E��v�s" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        Write-Log "Calls ComparisonResult constructor, �폜�s�E��v�s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �폜�s�E�ǉ��s" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 1
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, �폜�s�E�ǉ��s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 2'
                    LineNumber      = 1
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ǉ��s�E��v�s" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line �ǉ�'
                    LineNumber      = 1
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        Write-Log "Calls ComparisonResult constructor, �ǉ��s�E��v�s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 2
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line �ǉ�'
                LineNumber      = 1
                SourceFileIndex = 10
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 3  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, �ǉ��s�E�폜�s�i�폜�D��ƂȂ�j" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line �ǉ�'
                    LineNumber      = 1
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }))
        Write-Log "Calls ComparisonResult constructor, �ǉ��s�E�폜�s"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 2
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line �ǉ�'
                LineNumber      = 1
                SourceFileIndex = 10
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # ��r�t�@�C���̍s�ԍ�
            } | ConvertTo-Json -Compress)
    }
}

Describe "ComparisonResultsFormatter" {
    It "Calls ComparisonResultsFormatter.Format, ����null" {
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format($null)
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, ����0��" {
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@())
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s1��" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s1��"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 0
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s1��" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s1��"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 1
        ($formattedLines -join "`r`n") | Should Be "< Test line 1"
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s1��" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s1��"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 1
        ($formattedLines -join "`r`n") | Should Be "> Test line 1"
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ύX�s1��" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1 �ύX�O'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 1 �ύX��'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ύX�s1��"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 2
        ($formattedLines -join "`r`n") | Should Be (@(
                "< Test line 1 �ύX�O",
                "> Test line 1 �ύX��"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E��v�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E��v�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "  2 2 Test line 2",
                "  3 3 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�폜�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�폜�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "< 2  Test line 2",
                "< 3  Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�ǉ��s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�ǉ��s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                ">  2 Test line 2",
                ">  3 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�ύX�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2 �ύX�O'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3 �ύX�O'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 �ύX��'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3 �ύX��'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A��v�s�E�ύX�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "< 2  Test line 2 �ύX�O",
                "< 3  Test line 3 �ύX�O",
                ">  2 Test line 2 �ύX��",
                ">  3 Test line 3 �ύX��"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E��v�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E��v�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "  2 1 Test line 2",
                "  3 2 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�폜�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�폜�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "< 2  Test line 2",
                "< 3  Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�ǉ��s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�ǉ��s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                ">  1 Test line 2",
                ">  2 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�ύX�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 �ύX�O'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3 �ύX�O'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 �ύX��'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3 �ύX��'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�폜�s�E�ύX�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "< 2  Test line 2 �ύX�O",
                "< 3  Test line 3 �ύX�O",
                ">  1 Test line 2 �ύX��",
                ">  2 Test line 3 �ύX��"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E��v�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E��v�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1 Test line A",
                "  1 2 Test line B",
                "  2 3 Test line C"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�폜�s�i�폜�D��ƂȂ�j" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�폜�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line B",
                "< 2  Test line C",
                ">  1 Test line A"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�ǉ��s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line C'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�ǉ��s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1 Test line A",
                ">  2 Test line B",
                ">  3 Test line C"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�ύX�s" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B �ύX�O'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line C �ύX�O'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line B �ύX��'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line C �ύX��'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��2���A�ǉ��s�E�ύX�s"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line B �ύX�O",
                "< 2  Test line C �ύX�O",
                ">  1 Test line A",
                ">  2 Test line B �ύX��",
                ">  3 Test line C �ύX��"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A��v�s1��" {
        $comparisonResults = @(
            # ���̓t�@�C��1,2�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' }
                )),
            # ���̓t�@�C��1,3�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A��v�s1��"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 1 Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�폜�s1��" {
        $comparisonResults = @(
            # ���̓t�@�C��1,2�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
                )),
            # ���̓t�@�C��1,3�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�폜�s1��"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1   Test line 1",
                "< 1   Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�ǉ��s1��" {
        $comparisonResults = @(
            # ���̓t�@�C��1,2�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                )),
            # ���̓t�@�C��1,3�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�ǉ��s1��"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1  Test line 1",
                ">   1 Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�ύX�s1��" {
        $comparisonResults = @(
            # ���̓t�@�C��1,2�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1 �ύX�O'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                    @{Line = 'Test line 1 �ύX��'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                )),
            # ���̓t�@�C��1,3�̔�r����
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1 �ύX�O'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                    @{Line = 'Test line 1 �ύX��'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, ���̓t�@�C��3���A�ύX�s1��"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1   Test line 1 �ύX�O",
                "< 1   Test line 1 �ύX�O",
                ">  1  Test line 1 �ύX��",
                ">   1 Test line 1 �ύX��"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, MatchOnly" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line B'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.MatchOnly = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, MatchOnly"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "Test line A"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, MatchOnly, LineNumber�y�s�v�z" {
        # MatchOnly�ł�LineNumber�������ƂȂ�̂ŁA�ЂƂ܂��{�e�X�g�P�[�X�s�v�Ƃ���B

        # $comparisonResult = [ComparisonResult]::new(@(
        #         @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
        #         @{Line = 'Test line B'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
        #         @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
        #     ))
        # $formatter = [ComparisonResultsFormatter]::new()
        # $formatter.MatchOnly = $true
        # $formatter.LineNumber = $true
        # $formattedLines = $formatter.Format(@($comparisonResult))
        # Write-Log "Calls ComparisonResultsFormatter.Format, MatchOnly"
        # Write-Log $comparisonResult.ToString()

        # ($formattedLines -join "`r`n") | Should Be (@(
        #         "  1 1 Test line A"
        #     ) -join "`r`n")
    }
}

Describe "Other" {
    It "Calls other test" {
        Write-Log "Calls other test"

        $comparer = [FileComparer]::new()
        $comparisonResults1 = $comparer.CompareFilesAsResults(@("SampleDiffText\file1.txt", "SampleDiffText\file2.txt"), 'Default')
        $comparisonResults2 = $comparer.CompareFilesAsResults(@("SampleDiffText\file1.txt", "SampleDiffText\file2.txt", "SampleDiffText\file3.txt"), 'Default')
        Write-Log "comparisonResults1[0]:$($comparisonResults1[0].ToString())"
        Write-Log "comparisonResults2[0]:$($comparisonResults2[0].ToString())"
        $comparisonResults1[0].ToString() | Should Be $comparisonResults2[0].ToString()

        # $formatter = [ComparisonResultsFormatter]::new()
        # $formattedLines = $formatter.Format($comparisonResults)
        # ($formattedLines -join "`r`n") | Should Be (@(
        #         "xxx"
        #     ) -join "`r`n")
    }
}
