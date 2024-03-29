# 画面キャプチャを撮るPowerShellスクリプトの開発メモ
# ※Visual Studio Code なら、実行したい行を選択して、F8キーで実行できる。

# 動作確認
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose 'All'           "work\ScreenCapture_All.png"
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose 'Primary'       "work\ScreenCapture_Primary.png"
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose 'Drag'          "work\ScreenCapture_Drag.png"
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose "10,20,500,600" "work\ScreenCapture_Rect.png"
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose "10,20,500,600" "work\space dir\ScreenCapture.png"
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose "10,20,500,600" -Clipboard
$DebugPreference='Continue'; Windows\ScreenCapture\ScreenCapture.ps1 -Verbose "10,20,500,600" "work\ScreenCapture_Repetition.png" -Interval 2 -Repetition 3

# Pesterによる単体テスト
New-Fixture -Name .\Windows\ScreenCapture\Func
Invoke-Pester .\Windows\ScreenCapture\Func.Tests.ps1 -CodeCoverage .\Windows\ScreenCapture\Func.ps1


# 実装検証
# 画面キャプチャ（ファイル出力）
Add-Type -AssemblyName System.Drawing
function CaptureToFile($rect, $outPath) {
  # Save時に、相対パスだとエラーになることがあるので、絶対パスに変更。
  # パスが存在しないことも考慮して.Netで実装。Resolve-Pathだとエラーになる。
  $outPath = GetFullPath $outPath
  # キャプチャ
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  $bitmap.Save($outPath)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "キャプチャしました。 $($rect.Location) $($rect.Size) $outPath"
}
function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
$rect = New-Object System.Drawing.Rectangle(0, 0, 500, 500)
CaptureToFile $rect "work\capture.png"

# 画面キャプチャ（クリップボードへ）
function CaptureToClipboard($rect) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  [Windows.Forms.Clipboard]::SetImage($bitmap)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "キャプチャしました。 $($rect.Location) $($rect.Size)"
}
CaptureToClipboard $rect
Get-Clipboard -Format Image

# マルチモニター考慮
# 全モニターを1つの画像ファイルに保存
$screens = [System.Windows.Forms.Screen]::AllScreens
$top    = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
$left   = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
$right  = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
$bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
$rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
CaptureToFile $rect "work\capture.png"
# プライマリモニターのみ
$rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
CaptureToFile $rect "work\capture.png"
# アクティブモニターのみ →C#/.NET関数を自作する必要がありそうなので省略。

# 画像をクリップボードにコピー
$bitmap = New-Object System.Drawing.Bitmap($outPath)
# 案1
$data = New-Object System.Windows.Forms.DataObject
$data.SetImage($bitmap)
[Windows.Forms.Clipboard]::SetDataObject($data, $true)
# 案2
[Windows.Forms.Clipboard]::SetImage($bitmap)
# 
Get-Clipboard -Format Image
$bitmap.Dispose()

# マウスの座標
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Cursor]::Position
[System.Windows.Forms.Control]::MouseButtons
[System.Windows.Forms.Control]::MousePosition

function GetDragRect() {
  Write-Host "マウスをドラッグして矩形領域を選択してください。"
  while ([System.Windows.Forms.Control]::MouseButtons -eq 'None') { Start-Sleep 0.5 }; Write-Host "Pressed"
  $p1 = [System.Windows.Forms.Control]::MousePosition
  while ([System.Windows.Forms.Control]::MouseButtons -ne 'None') { Start-Sleep 0.5 }; Write-Host "Released"
  $p2 = [System.Windows.Forms.Control]::MousePosition
  $rect = [System.Drawing.Rectangle]::FromLTRB([Math]::Min($p1.X, $p2.X), [Math]::Min($p1.Y, $p2.Y), [Math]::Max($p1.X, $p2.X), [Math]::Max($p1.Y, $p2.Y))
  Write-Host $rect
  return $rect
}
$rect = GetDragRect


# 参考サイト
# [PowerShell モジュール ブラウザー - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/?view=powershell-5.1)
# [.NET API ブラウザー | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/?view=netframework-4.5)
# [Bitmap クラス (System.Drawing) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.drawing.bitmap?view=netframework-4.5)
# [Clipboard クラス (System.Windows) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.clipboard?view=netframework-4.5)
# [Graphics クラス (System.Drawing) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.drawing.graphics?view=netframework-4.5)
# [簡単！PowerShellで作成できる画面録画ツールの紹介と作り方[No18] - BookALittle](https://bookalittle.com/howtocheck-operation-byrecording-pstool/)
# [インターネット上の画像をクリップボードにコピーするコード(PowerShell版)](https://gist.github.com/bu762/6e0f3668e59d4a932821)
# [Windowsのコマンドラインからスクリーンショットを撮る(PowerShell) | Misohena Blog](https://misohena.jp/blog/2021-08-08-take-screenshot-on-windows-power-shell.html)
# [pester/Pester at rel/3.x.x](https://github.com/pester/Pester/tree/rel/3.x.x)

# 動作確認環境
$PSVersionTable
# PSVersion                      5.1.19041.1682
# PSEdition                      Desktop
Get-Item "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
# Version       : 4.8.04084
