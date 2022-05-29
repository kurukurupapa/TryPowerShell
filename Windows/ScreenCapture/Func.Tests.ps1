$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Main関数のテスト" {
  It "矩形領域をファイル保存" {
    $areaStr = "10,20,30,40"
    $expectedRect = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    $resultPath = "work\ScreenCapture_Test.png"
    if (Test-Path $resultPath) {
      Remove-Item $resultPath
    }
    Main $areaStr $resultPath

    Test-Path $resultPath -PathType Leaf | Should Be $true
    $bitmap = New-Object System.Drawing.Bitmap($resultPath)
    $bitmap.Size | Should Be $expectedRect.Size
    $bitmap.Dispose()
  }

  It "プライマリモニターをクリップボードへ" {
    $areaStr = 'Primary'
    $expectedRect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    Set-Clipboard $null
    Main $areaStr -clipboard $true

    $result = Get-Clipboard -Format Image
    $result | Should BeOfType System.Drawing.Bitmap
    $result.Size | Should Be $expectedRect.Size
  }

  It "繰り返しキャプチャ_1秒間隔1回" {
    $areaStr = "10,20,30,40"
    $resultPath = "work\ScreenCapture_Test_Repetition.png"
    if (Test-Path "work\ScreenCapture_Test_Repetition_*.png") {
      Remove-Item "work\ScreenCapture_Test_Repetition_*.png"
    }
    Main $areaStr $resultPath -interval 1 -repetition 1

    $count = (Get-Item "work\ScreenCapture_Test_Repetition_*.png" | Measure-Object).Count
    $count | Should Be 1
  }
  It "繰り返しキャプチャ_2秒間隔3回" {
    $areaStr = "10,20,30,40"
    $resultPath = "work\ScreenCapture_Test_Repetition.png"
    if (Test-Path "work\ScreenCapture_Test_Repetition_*.png") {
      Remove-Item "work\ScreenCapture_Test_Repetition_*.png"
    }
    Main $areaStr $resultPath -interval 2 -repetition 3

    $count = (Get-Item "work\ScreenCapture_Test_Repetition_*.png" | Measure-Object).Count
    $count | Should Be 3
  }
  It "繰り返しキャプチャ_回数制限なし" {
    Write-Warning "テスト不可"
  }
}

Describe "Capture関数のテスト" {
  It "引数ファイルを指定" {
    $rect = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    $resultPath = ".\work\ScreenCapture_Test.png"
    if (Test-Path $resultPath) {
      Remove-Item $resultPath
    }
    Capture $rect $resultPath

    Test-Path $resultPath -PathType Leaf | Should Be $true
    $bitmap = New-Object System.Drawing.Bitmap($resultPath)
    $bitmap.Size | Should Be $rect.Size
    $bitmap.Dispose()
  }

  It "引数クリップボードを指定" {
    $rect = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    Set-Clipboard $null
    Capture $rect -clipboard $true

    $result = Get-Clipboard -Format Image
    $result | Should BeOfType System.Drawing.Bitmap
    $result.Size | Should Be $rect.Size
  }
}

Describe "GetRectArea関数のテスト" {
  It "引数が矩形" {
    $expected = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    GetRectArea "10,20,30,40" | Should Be $expected
  }
  It "引数が矩形で、要素が少ない" {
    { GetRectArea "10,20,30" } | Should Throw "解析エラー"
  }
  It "引数が矩形で、要素が多い" {
    { GetRectArea "10,20,30,40,50" } | Should Throw "解析エラー"
  }

  It "引数がPrimary" {
    $expected = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    GetRectArea 'Primary' | Should Be $expected
    GetRectArea 'primary' | Should Be $expected
    GetRectArea 'PRIMARY' | Should Be $expected
  }
  It "引数がAll" {
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $top = ($screens.Bounds.Top | Measure-Object -Minimum).Minimum
    $left = ($screens.Bounds.Left | Measure-Object -Minimum).Minimum
    $right = ($screens.Bounds.Right | Measure-Object -Maximum).Maximum
    $bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $expected = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
    GetRectArea 'All' | Should Be $expected
    GetRectArea 'all' | Should Be $expected
    GetRectArea 'ALL' | Should Be $expected
    if ([System.Windows.Forms.Screen]::AllScreens.Count -le 1) {
      Write-Warning "マルチモニターでないため、十分なテストになっていない。"
    }
  }
  It "引数が不正文字列" {
    { GetRectArea "Unknown" } | Should Throw "解析エラー"
  }
}

Describe "GetOutFilePath関数のテスト" {
  It "引数に相対パス" {
    GetOutFilePath "work\a.png" | Should Be "$(Get-Location)\work\a.png"
  }

  It "引数に絶対パス" {
    GetOutFilePath "$(Get-Location)\work\a.png" | Should Be "$(Get-Location)\work\a.png"
  }

  It "引数にディレクトリ" {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    GetOutFilePath "work" "ScreenCapture" | Should Be "$(Get-Location)\work\ScreenCapture_${timestamp}.png"
  }
}
