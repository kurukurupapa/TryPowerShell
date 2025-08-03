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
    It "Calls FileComparer.GetComparisonLines, 入力null" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines($null, 1)
        #=> 本当は空配列「@()」を返却してほしいがPowershell仕様で$nullになる 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.GetComparisonLines, 入力0件" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines(@(), 1)
        #=> 本当は空配列「@()」を返却してほしいがPowershell仕様で$nullになる 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.GetComparisonLines, 入力1件" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.GetComparisonLines(@(
                "Line 1: This is a test line."
            ), 1)
        ($comparisonLines | ConvertTo-Json -Compress) | Should Be (@(
                [ComparisonLine]@{ Line = "Line 1: This is a test line."; LineNumber = 1; SourceFileIndex = 1 }
            ) | ConvertTo-Json -Compress)
    }

    It "Calls FileComparer.GetComparisonLines, 入力3件" {
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

    # It "Calls FileComparer.CompareComparisonLines, 入力null" {
    #     $comparisonLines = [FileComparer]::CompareComparisonLines($null, $null)
    #     #=> 実施不可？
    #     #   ParameterBindingValidationException: 引数が null であるため、パラメーター 'ReferenceObject' にバインドできません。
    #     #=> 本当は空配列「@()」を返却してほしいがPowershell仕様で$nullになる 
    #     $comparisonLines | Should Be $null
    # }

    It "Calls FileComparer.CompareComparisonLines, 入力0件" {
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.CompareComparisonLines(@(), @())
        #=> 本当は空配列「@()」を返却してほしいがPowershell仕様で$nullになる 
        $comparisonLines | Should Be $null
    }

    It "Calls FileComparer.CompareComparisonLines, 入力データあり" {
        # Compare-Objectを所定のオプションで呼び出せていることを確認する
        $comparer = [FileComparer]::new()
        $comparisonLines = $comparer.CompareComparisonLines(@(
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 1; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "削除行"; LineNumber = 2; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 3; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 4; SourceFileIndex = 0 },
                [ComparisonLine]@{ Line = "変更前"; LineNumber = 5; SourceFileIndex = 0 }
            ), @(
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 1; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 2; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "追加行"; LineNumber = 3; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "一致行"; LineNumber = 4; SourceFileIndex = 1 },
                [ComparisonLine]@{ Line = "変更後"; LineNumber = 5; SourceFileIndex = 1 }
            ))
        ($comparisonLines | ConvertTo-Json -Compress) | Should Be (@(
                [PSCustomObject]@{ Line = "一致行"; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "一致行"; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "一致行"; LineNumber = 4; SourceFileIndex = 0; SideIndicator = '==' },
                [PSCustomObject]@{ Line = "追加行"; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' },
                [PSCustomObject]@{ Line = "変更後"; LineNumber = 5; SourceFileIndex = 1; SideIndicator = '=>' },
                [PSCustomObject]@{ Line = "削除行"; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                [PSCustomObject]@{ Line = "変更前"; LineNumber = 5; SourceFileIndex = 0; SideIndicator = '<=' }
            ) | ConvertTo-Json -Compress)
    }
}

Describe "ComparisonResult" {
    It "Calls ComparisonResult constructor, 入力null" {
        $comparisonResult = [ComparisonResult]::new($null)
        Write-Log "Calls ComparisonResult constructor, 入力null"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMinReferenceLineNumber() | Should Be -1
        $comparisonResult.GetMaxReferenceLineNumber() | Should Be -1
    }

    It "Calls ComparisonResult constructor, 入力0件" {
        $comparisonResult = [ComparisonResult]::new(@())
        Write-Log "Calls ComparisonResult constructor, 入力0件"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMinReferenceLineNumber() | Should Be -1
        $comparisonResult.GetMaxReferenceLineNumber() | Should Be -1
    }

    It "Calls ComparisonResult constructor, 一致行1件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        Write-Log "Calls ComparisonResult constructor, 一致行1件"
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
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 一致行3件" {
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
        Write-Log "Calls ComparisonResult constructor, 一致行3件"
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
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 3  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 削除行1件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '<='
                }))
        Write-Log "Calls ComparisonResult constructor, 削除行1件"
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
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 削除行3件" {
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
        Write-Log "Calls ComparisonResult constructor, 削除行3件"
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
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 追加行1件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, 追加行1件"
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
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 追加行3件" {
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
        Write-Log "Calls ComparisonResult constructor, 追加行3件"
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
                    DiffLineNumber  = 1  # 比較ファイルの行番号
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # 比較ファイルの行番号
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 3
                    SourceFileIndex = 13
                    SideIndicator   = '=>'
                    DiffLineNumber  = 3  # 比較ファイルの行番号
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 変更1件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1  # 基準ファイルの行番号
                    SourceFileIndex = 0  # 0:基準ファイル
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 1 変更後'
                    LineNumber      = 1  # 比較ファイルの行番号
                    SourceFileIndex = 3  # 1以上:比較ファイル
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, 変更行1件"
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
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1 変更後'
                LineNumber      = 1
                SourceFileIndex = 3
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 変更2件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1  # 基準ファイルの行番号
                    SourceFileIndex = 0  # 0:基準ファイル
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 2'
                    LineNumber      = 2  # 基準ファイルの行番号
                    SourceFileIndex = 0  # 0:基準ファイル
                    SideIndicator   = '<='
                }, @{
                    Line            = 'Test line 1 変更後'
                    LineNumber      = 1  # 比較ファイルの行番号
                    SourceFileIndex = 3  # 1以上:比較ファイル
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 2 変更後'
                    LineNumber      = 2  # 比較ファイルの行番号
                    SourceFileIndex = 3  # 1以上:比較ファイル
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, 変更行2件"
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
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@() | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 1 変更後'
                    LineNumber      = 1
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                    DiffLineNumber  = 1  # 比較ファイルの行番号
                }, @{
                    Line            = 'Test line 2 変更後'
                    LineNumber      = 2
                    SourceFileIndex = 3
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # 比較ファイルの行番号
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 一致行・削除行" {
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
        Write-Log "Calls ComparisonResult constructor, 一致行・削除行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 一致行・追加行" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }, @{
                    Line            = 'Test line 2 追加'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }, @{
                    Line            = 'Test line 3 追加'
                    LineNumber      = 3
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                }))
        Write-Log "Calls ComparisonResult constructor, 一致行・追加行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 2 追加'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # 比較ファイルの行番号
                }, @{
                    Line            = 'Test line 3 追加'
                    LineNumber      = 3
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 3  # 比較ファイルの行番号
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 削除行・一致行" {
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
        Write-Log "Calls ComparisonResult constructor, 削除行・一致行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 3
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(3) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 3'
                LineNumber      = 3
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 削除行・追加行" {
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
        Write-Log "Calls ComparisonResult constructor, 削除行・追加行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 1
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(1) | ConvertTo-Json -Compress) | Should Be (@(@{
                    Line            = 'Test line 2'
                    LineNumber      = 1
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 1  # 比較ファイルの行番号
                }, @{
                    Line            = 'Test line 3'
                    LineNumber      = 2
                    SourceFileIndex = 10
                    SideIndicator   = '=>'
                    DiffLineNumber  = 2  # 比較ファイルの行番号
                }) | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 追加行・一致行" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 追加'
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
        Write-Log "Calls ComparisonResult constructor, 追加行・一致行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 2
        ($comparisonResult.GetAddedLines(0) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 追加'
                LineNumber      = 1
                SourceFileIndex = 10
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 2  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetCommonLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '=='
                DiffLineNumber  = 3  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }

    It "Calls ComparisonResult constructor, 追加行・削除行（削除優先となる）" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 追加'
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
        Write-Log "Calls ComparisonResult constructor, 追加行・削除行"
        Write-Log $comparisonResult.ToString()

        $comparisonResult.GetMaxReferenceLineNumber() | Should Be 2
        ($comparisonResult.GetRemovedLine(1) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 1'
                LineNumber      = 1
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetRemovedLine(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 2'
                LineNumber      = 2
                SourceFileIndex = 0
                SideIndicator   = '<='
                DiffLineNumber  = 0  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
        ($comparisonResult.GetAddedLines(2) | ConvertTo-Json -Compress) | Should Be (@{
                Line            = 'Test line 追加'
                LineNumber      = 1
                SourceFileIndex = 10
                SideIndicator   = '=>'
                DiffLineNumber  = 1  # 比較ファイルの行番号
            } | ConvertTo-Json -Compress)
    }
}

Describe "ComparisonResultsFormatter" {
    It "Calls ComparisonResultsFormatter.Format, 入力null" {
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format($null)
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, 入力0件" {
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@())
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行1件" {
        $comparisonResult = [ComparisonResult]::new(@(@{
                    Line            = 'Test line 1'
                    LineNumber      = 1
                    SourceFileIndex = 0
                    SideIndicator   = '=='
                }))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行1件"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 0
        ($formattedLines -join "`r`n") | Should Be ""
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行1件" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行1件"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 1
        ($formattedLines -join "`r`n") | Should Be "< Test line 1"
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行1件" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行1件"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 1
        ($formattedLines -join "`r`n") | Should Be "> Test line 1"
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、変更行1件" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1 変更前'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 1 変更後'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、変更行1件"
        Write-Log $comparisonResult.ToString()

        $formattedLines.Count | Should Be 2
        ($formattedLines -join "`r`n") | Should Be (@(
                "< Test line 1 変更前",
                "> Test line 1 変更後"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・一致行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・一致行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "  2 2 Test line 2",
                "  3 3 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・削除行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・削除行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "< 2  Test line 2",
                "< 3  Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・追加行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・追加行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                ">  2 Test line 2",
                ">  3 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・変更行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 2 変更前'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3 変更前'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 変更後'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3 変更後'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、一致行・変更行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 Test line 1",
                "< 2  Test line 2 変更前",
                "< 3  Test line 3 変更前",
                ">  2 Test line 2 変更後",
                ">  3 Test line 3 変更後"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・一致行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・一致行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "  2 1 Test line 2",
                "  3 2 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・削除行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・削除行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "< 2  Test line 2",
                "< 3  Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・追加行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・追加行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                ">  1 Test line 2",
                ">  2 Test line 3"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・変更行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 変更前'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 3 変更前'; LineNumber = 3; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line 2 変更後'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line 3 変更後'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、削除行・変更行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line 1",
                "< 2  Test line 2 変更前",
                "< 3  Test line 3 変更前",
                ">  1 Test line 2 変更後",
                ">  2 Test line 3 変更後"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・一致行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' },
                @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '==' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・一致行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1 Test line A",
                "  1 2 Test line B",
                "  2 3 Test line C"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・削除行（削除優先となる）" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line C'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・削除行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line B",
                "< 2  Test line C",
                ">  1 Test line A"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・追加行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line C'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・追加行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1 Test line A",
                ">  2 Test line B",
                ">  3 Test line C"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・変更行" {
        $comparisonResult = [ComparisonResult]::new(@(
                @{Line = 'Test line A'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line B 変更前'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line C 変更前'; LineNumber = 2; SourceFileIndex = 0; SideIndicator = '<=' },
                @{Line = 'Test line B 変更後'; LineNumber = 2; SourceFileIndex = 1; SideIndicator = '=>' },
                @{Line = 'Test line C 変更後'; LineNumber = 3; SourceFileIndex = 1; SideIndicator = '=>' }
            ))
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format(@($comparisonResult))
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル2件、追加行・変更行"
        Write-Log $comparisonResult.ToString()

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1  Test line B 変更前",
                "< 2  Test line C 変更前",
                ">  1 Test line A",
                ">  2 Test line B 変更後",
                ">  3 Test line C 変更後"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、一致行1件" {
        $comparisonResults = @(
            # 入力ファイル1,2の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' }
                )),
            # 入力ファイル1,3の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '==' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、一致行1件"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "  1 1 1 Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、削除行1件" {
        $comparisonResults = @(
            # 入力ファイル1,2の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
                )),
            # 入力ファイル1,3の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、削除行1件"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1   Test line 1",
                "< 1   Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、追加行1件" {
        $comparisonResults = @(
            # 入力ファイル1,2の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                )),
            # 入力ファイル1,3の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、追加行1件"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                ">  1  Test line 1",
                ">   1 Test line 1"
            ) -join "`r`n")
    }

    It "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、変更行1件" {
        $comparisonResults = @(
            # 入力ファイル1,2の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1 変更前'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                    @{Line = 'Test line 1 変更後'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                )),
            # 入力ファイル1,3の比較結果
            [ComparisonResult]::new(@(
                    @{Line = 'Test line 1 変更前'; LineNumber = 1; SourceFileIndex = 0; SideIndicator = '<=' },
                    @{Line = 'Test line 1 変更後'; LineNumber = 1; SourceFileIndex = 1; SideIndicator = '=>' }
                ))
        )
        $formatter = [ComparisonResultsFormatter]::new()
        $formatter.IncludeMatch = $true
        $formatter.LineNumber = $true
        $formattedLines = $formatter.Format($comparisonResults)
        Write-Log "Calls ComparisonResultsFormatter.Format, 入力ファイル3件、変更行1件"
        $comparisonResults | ForEach-Object { Write-Log $_.ToString() }

        ($formattedLines -join "`r`n") | Should Be (@(
                "< 1   Test line 1 変更前",
                "< 1   Test line 1 変更前",
                ">  1  Test line 1 変更後",
                ">   1 Test line 1 変更後"
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

    It "Calls ComparisonResultsFormatter.Format, MatchOnly, LineNumber【不要】" {
        # MatchOnlyではLineNumberが無効となるので、ひとまず本テストケース不要とする。

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
