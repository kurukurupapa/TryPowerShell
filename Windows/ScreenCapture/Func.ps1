<#
ScreenCapture用関数
#>
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Main($areaStr, $outPath, $clipboard) {
  $rect = GetRectArea $areaStr
  if ($outPath) {
    $outPath = GetOutFilePath $outPath "ScreenCapture"
  }
  Capture $rect $outPath $clipboard
}

function GetRectArea($areaStr) {
  $rect = $null
  if (!$areaStr -or $areaStr.ToLower() -eq 'all') {
    # 全モニターを対象にする
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $top    = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
    $left   = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
    $right  = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
    $bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
  } elseif ($areaStr.ToLower() -eq 'primary') {
    # プライマリモニターのみ
    $rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  } elseif ($areaStr.ToLower() -match "^(\d+),(\d+),(\d+),(\d+)$") {
    # 矩形領域
    $rect = New-Object System.Drawing.Rectangle($Matches[1], $Matches[2], $Matches[3], $Matches[4])
  } else {
    throw "引数Areaの解析エラー [$areaStr]"
  }
  Write-Verbose "キャプチャ領域 $rect"
  return $rect
}

function Capture($rect, $outPath, $clipboard) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  if ($outPath) {
    $bitmap.Save($outPath)
    Write-Verbose "ファイル保存しました。 $outPath"
  }
  if ($clipboard) {
    [Windows.Forms.Clipboard]::SetImage($bitmap)
    Write-Verbose "クリップボードへコピーしました。"
  }
  $graphics.Dispose()
  $bitmap.Dispose()
}

function GetOutFilePath($path, $defaultName) {
  # Bitmap.Save()時に、相対パスだとエラーになることがあるので、絶対パスに変更。
  # パスが存在しないことも考慮して.Netで実装。Resolve-Pathだとエラーになる。
  $outPath = GetFullPath $path

  # 引数のパスがディレクトリの場合、ファイル名を付加する。
  if (Test-Path $outPath -PathType Container) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $outPath = Join-Path $outPath "${defaultName}_${timestamp}.png"
  }
  return $outPath
}

function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
