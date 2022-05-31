<#
ScreenCapture用関数
#>
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Main($areaStr, $outPath, $clipboard, $interval, $repetition) {
  $rect = GetRectArea $areaStr
  $outPath2 = $null
  if (!$interval) {
    if ($outPath) {
      $outPath2 = GetOutFilePath $outPath "ScreenCapture"
    }
    Capture $rect $outPath2 $clipboard
  }
  else {
    Write-Verbose "繰り返し 間隔:$interval 回数:$repetition"
    $i = 0
    while ($true) {
      $i++
      if ($outPath) {
        $outPath2 = GetOutFilePath $outPath "ScreenCapture" $i
      }
      Capture $rect $outPath2 $clipboard
      if ($repetition -and $i -ge $repetition) {
        break
      }
      Start-Sleep $interval
    }
  }
}

function GetRectArea($areaStr) {
  $rect = $null
  if (!$areaStr -or $areaStr.ToLower() -eq 'all') {
    # 全モニターを対象にする
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $top = ($screens.Bounds.Top | Measure-Object -Minimum).Minimum
    $left = ($screens.Bounds.Left | Measure-Object -Minimum).Minimum
    $right = ($screens.Bounds.Right | Measure-Object -Maximum).Maximum
    $bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
  }
  elseif ($areaStr.ToLower() -eq 'primary') {
    # プライマリモニターのみ
    $rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  }
  elseif ($areaStr.ToLower() -match "^(\d+),(\d+),(\d+),(\d+)$") {
    # 矩形領域
    $rect = New-Object System.Drawing.Rectangle($Matches[1], $Matches[2], $Matches[3], $Matches[4])
  }
  elseif ($areaStr.ToLower() -eq 'drag') {
    $rect = GetDragRect
  }
  else {
    throw "引数Areaの解析エラー [$areaStr]"
  }
  Write-Verbose "キャプチャ領域 X,Y,W,H:$($rect.X),$($rect.Y),$($rect.Width),$($rect.Height)"
  return $rect
}

function GetDragRect() {
  Write-Host "マウスをドラッグして矩形領域を選択してください。"
  while ([System.Windows.Forms.Control]::MouseButtons -eq 'None') { Start-Sleep 0.5 }
  $p1 = [System.Windows.Forms.Control]::MousePosition
  while ([System.Windows.Forms.Control]::MouseButtons -ne 'None') { Start-Sleep 0.5 }
  $p2 = [System.Windows.Forms.Control]::MousePosition
  $rect = [System.Drawing.Rectangle]::FromLTRB(
    [Math]::Min($p1.X, $p2.X),
    [Math]::Min($p1.Y, $p2.Y),
    [Math]::Max($p1.X, $p2.X),
    [Math]::Max($p1.Y, $p2.Y)
  )
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

function GetOutFilePath($path, $defaultName, $index) {
  # Bitmap.Save()時に、相対パスだとエラーになることがあるので、絶対パスに変更。
  # パスが存在しないことも考慮して.Netで実装。Resolve-Pathだとエラーになる。
  $outPath = GetFullPath $path

  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  if (Test-Path $outPath -PathType Container) {
    # 引数のパスがディレクトリの場合、ファイル名を付加する。
    $outPath = Join-Path $outPath "${defaultName}_${timestamp}.png"
  }
  elseif ($index) {
    # 繰り返しキャプチャの場合、ファイル名にタイムスタンプを付与する。
    $dir = Split-Path $outPath -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($outPath) + "_$timestamp" + [System.IO.Path]::GetExtension($outPath)
    $outPath = Join-Path $dir $name
  }
  return $outPath
}

function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
