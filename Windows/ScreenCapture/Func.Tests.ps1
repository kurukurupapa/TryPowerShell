$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Main�֐��̃e�X�g" {
  It "��`�̈���t�@�C���ۑ�" {
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

  It "�v���C�}�����j�^�[���N���b�v�{�[�h��" {
    $areaStr = 'Primary'
    $expectedRect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    Set-Clipboard $null
    Main $areaStr -clipboard $true

    $result = Get-Clipboard -Format Image
    $result | Should BeOfType System.Drawing.Bitmap
    $result.Size | Should Be $expectedRect.Size
  }

  It "�J��Ԃ��L���v�`��_1�b�Ԋu1��" {
    $areaStr = "10,20,30,40"
    $resultPath = "work\ScreenCapture_Test_Repetition.png"
    if (Test-Path "work\ScreenCapture_Test_Repetition_*.png") {
      Remove-Item "work\ScreenCapture_Test_Repetition_*.png"
    }
    Main $areaStr $resultPath -interval 1 -repetition 1

    $count = (Get-Item "work\ScreenCapture_Test_Repetition_*.png" | Measure-Object).Count
    $count | Should Be 1
  }
  It "�J��Ԃ��L���v�`��_2�b�Ԋu3��" {
    $areaStr = "10,20,30,40"
    $resultPath = "work\ScreenCapture_Test_Repetition.png"
    if (Test-Path "work\ScreenCapture_Test_Repetition_*.png") {
      Remove-Item "work\ScreenCapture_Test_Repetition_*.png"
    }
    Main $areaStr $resultPath -interval 2 -repetition 3

    $count = (Get-Item "work\ScreenCapture_Test_Repetition_*.png" | Measure-Object).Count
    $count | Should Be 3
  }
  It "�J��Ԃ��L���v�`��_�񐔐����Ȃ�" {
    Write-Warning "�e�X�g�s��"
  }
}

Describe "Capture�֐��̃e�X�g" {
  It "�����t�@�C�����w��" {
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

  It "�����N���b�v�{�[�h���w��" {
    $rect = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    Set-Clipboard $null
    Capture $rect -clipboard $true

    $result = Get-Clipboard -Format Image
    $result | Should BeOfType System.Drawing.Bitmap
    $result.Size | Should Be $rect.Size
  }
}

Describe "GetRectArea�֐��̃e�X�g" {
  It "��������`" {
    $expected = New-Object System.Drawing.Rectangle(10, 20, 30, 40)
    GetRectArea "10,20,30,40" | Should Be $expected
  }
  It "��������`�ŁA�v�f�����Ȃ�" {
    { GetRectArea "10,20,30" } | Should Throw "��̓G���["
  }
  It "��������`�ŁA�v�f������" {
    { GetRectArea "10,20,30,40,50" } | Should Throw "��̓G���["
  }

  It "������Primary" {
    $expected = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    GetRectArea 'Primary' | Should Be $expected
    GetRectArea 'primary' | Should Be $expected
    GetRectArea 'PRIMARY' | Should Be $expected
  }
  It "������All" {
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
      Write-Warning "�}���`���j�^�[�łȂ����߁A�\���ȃe�X�g�ɂȂ��Ă��Ȃ��B"
    }
  }
  It "�������s��������" {
    { GetRectArea "Unknown" } | Should Throw "��̓G���["
  }
}

Describe "GetOutFilePath�֐��̃e�X�g" {
  It "�����ɑ��΃p�X" {
    GetOutFilePath "work\a.png" | Should Be "$(Get-Location)\work\a.png"
  }

  It "�����ɐ�΃p�X" {
    GetOutFilePath "$(Get-Location)\work\a.png" | Should Be "$(Get-Location)\work\a.png"
  }

  It "�����Ƀf�B���N�g��" {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    GetOutFilePath "work" "ScreenCapture" | Should Be "$(Get-Location)\work\ScreenCapture_${timestamp}.png"
  }
}
