<#
.SYNOPSIS
画像ファイルを編集します。

.DESCRIPTION
このスクリプトは、画像ファイルを編集し別ファイルに保存します。
エラー処理は、考慮していません。
<CommonParameters> は、Verbose のみサポートしています。

.EXAMPLE
ImageEditForm.ps1 D:\tmp\srcimage.jpg
#>

[CmdletBinding()]
param(
  [String]$Path,
  [switch]$Help = $false
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $psDir "CustomImage.ps1")
. (Join-Path $psDir "ImageService.ps1")

# ヘルプ
if ($Help) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# フォーム
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Width = 800
$form.Height = 600

# メニュー
$menu = New-Object System.Windows.Forms.MenuStrip
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.text = "ファイル"
# ファイルを開く
$loadMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$loadMenu.Text = "ファイルを開く"
$loadMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::O)
$loadMenu.Add_Click({
    $ImageService.LoadFileWithDialog()
  })
# ファイルへ保存
$saveMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$saveMenu.Text = "ファイルへ保存"
$saveMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::S)
$saveMenu.Add_Click({
    $ImageService.SaveFileWithDialog()
  })
# クリップボードから貼り付け
$loadClipboardMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$loadClipboardMenu.Text = "クリップボードから貼り付け"
$loadClipboardMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::V)
$loadClipboardMenu.Add_Click({
    $ImageService.LoadClipboard()
  })
# クリップボードへコピー
$saveClipboardMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$saveClipboardMenu.Text = "クリップボードへコピー"
$saveClipboardMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::C)
$saveClipboardMenu.Add_Click({
    $ImageService.SaveClipboard()
  })
# メニュー項目の関連付け
$fileMenu.DropDownItems.AddRange(@($loadMenu, $saveMenu, $loadClipboardMenu, $saveClipboardMenu))
$menu.Items.AddRange(@($fileMenu))
# $form.Controls.Add($menu)

# 画像ボックス
$imageBox = New-Object Windows.Forms.PictureBox
$imageBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
# 親コントロールとの調整
$imageBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($imageBox)

# ボタンパネル
$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.AutoSize = $true
$buttonPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
# 親コントロールとの調整
$buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($buttonPanel)

# ファイル読み込みボタン
# →メニューへ移動
# $loadFileButton = New-Object System.Windows.Forms.Button
# $loadFileButton.AutoSize = $true
# $loadFileButton.Text = "ファイル読み込み"
# $loadFileButton.Add_Click({
#     $ImageService.LoadFileWithDialog()
#   })
# # 親コントロールとの調整
# $loadFileButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($loadFileButton)

# クリップボード読み込みボタン
# →メニューへ移動
# $loadClipboardButton = New-Object System.Windows.Forms.Button
# $loadClipboardButton.AutoSize = $true
# $loadClipboardButton.Text = "クリップボード読み込み"
# $loadClipboardButton.Add_Click({
#     $ImageService.LoadClipboard()
#   })
# # 親コントロールとの調整
# $loadClipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($loadClipboardButton)

# クリップボタン
$clipLabel = New-Object System.Windows.Forms.Label
$clipLabel.Text = "クリップ"
$clipLabel.AutoSize = $true
$clipLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($clipLabel)

# クリップ幅入力用テキストボックス
$clipSizeTextBox = New-Object System.Windows.Forms.TextBox
$clipSizeTextBox.Text = "10"  # デフォルト値
$clipSizeTextBox.AutoSize = $true
$buttonPanel.Controls.Add($clipSizeTextBox)

$clipArr = @(
  @("上", 0, 1, 0, 0),
  @("下", 0, 0, 0, 1),
  @("左", 1, 0, 0, 0),
  @("右", 0, 0, 1, 0)
)

for ($i = 0; $i -lt $clipArr.Length; $i++) {
  $label, $left, $top, $right, $bottom = $clipArr[$i]
  $clipButton = New-Object System.Windows.Forms.Button
  $clipButton.AutoSize = $true
  $clipButton.Text = "$label"
  $clipButton.Tag = $i
  $clipButton.Add_Click({
      $label, $left, $top, $right, $bottom = $clipArr[$this.Tag]
      $size = [int]$clipSizeTextBox.Text
      $ImageService.ClipWithOffset($left * $size, $top * $size, $right * $size, $bottom * $size)
    })
  # 親コントロールとの調整
  $clipButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($clipButton)
}

# リサイズボタン
$resizeLabel = New-Object System.Windows.Forms.Label
$resizeLabel.Text = "リサイズ"
$resizeLabel.AutoSize = $true
$resizeLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($resizeLabel)
$sizeArr = @(
  @(160, 120, "QQVGA", "Quarter QVGA"),
  @(300, 200, "", ""),
  @(320, 240, "QVGA", "Quarter VGA"),
  @(640, 480, "VGA", ""),
  @(800, 600, "SVGA", "Super VGA")
)
for ($i = 0; $i -lt $sizeArr.Length; $i++) {
  $w, $h, $comment, $tmp = $sizeArr[$i]
  $resizeButton = New-Object System.Windows.Forms.Button
  $resizeButton.AutoSize = $true
  #$resizeButton.Text = "リサイズ ${w}x${h} $comment"
  #$resizeButton.Text = "リサイズ ${w}x${h}"
  $resizeButton.Text = "${w}x${h} ${comment}"
  $resizeButton.Tag = $i
  $resizeButton.Add_Click({
      $w, $h, $comment, $tmp = $sizeArr[$this.Tag]
      $ImageService.Resize($w, $h)
    })
  # 親コントロールとの調整
  $resizeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($resizeButton)
}

# フレーム追加ボタン
$frameLabel = New-Object System.Windows.Forms.Label
$frameLabel.Text = "フレーム"
$frameLabel.AutoSize = $true
$frameLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($frameLabel)
$frameArr = @(
  @([System.Drawing.Color]::Black, 1),
  @([System.Drawing.Color]::Gray, 1)
)
for ($i = 0; $i -lt $frameArr.Length; $i++) {
  $color, $size = $frameArr[$i]
  $frameButton = New-Object System.Windows.Forms.Button
  $frameButton.AutoSize = $true
  # $frameButton.Text = "フレーム $($color.Name) ${size}px"
  $frameButton.Text = "$($color.Name) ${size}px"
  $frameButton.Tag = $i
  $frameButton.Add_Click({
      $color, $size = $frameArr[$this.Tag]
      $ImageService.DrawFrame($color, $size)
    })
  # 親コントロールとの調整
  $frameButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($frameButton)
}

# グレースケールボタン
$grayLabel = New-Object System.Windows.Forms.Label
$grayLabel.Text = "グレースケール"
$grayLabel.AutoSize = $true
$grayLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($grayLabel)

# グレースケールボタン（色成分の平均値を計算する方法）
$grayButton = New-Object System.Windows.Forms.Button
$grayButton.AutoSize = $true
# $grayButton.Text = "グレースケール変換（平均値）"
$grayButton.Text = "平均値 方式"
$grayButton.Add_Click({
    $ImageService.ConvertToGrayByAverage()
  })
# 親コントロールとの調整
$grayButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton)

# グレースケールボタン（ColorMatrixクラスを使用する方法）
$grayButton2 = New-Object System.Windows.Forms.Button
$grayButton2.AutoSize = $true
# $grayButton2.Text = "グレースケール変換（Matrix）"
$grayButton2.Text = "Matrix 方式"
$grayButton2.Add_Click({
    $ImageService.ConvertToGrayByMatrix()
  })
# 親コントロールとの調整
$grayButton2.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton2)

# リセットボタン
$otherLabel = New-Object System.Windows.Forms.Label
$otherLabel.Text = "その他"
$otherLabel.AutoSize = $true
$otherLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($otherLabel)
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.AutoSize = $true
$resetButton.Text = "リセット"
$resetButton.Add_Click({
    $ImageService.Reset()
  })
# 親コントロールとの調整
$resetButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($resetButton)

# クリップボードボタン
# →メニューへ移動
# $clipboardButton = New-Object System.Windows.Forms.Button
# $clipboardButton.AutoSize = $true
# $clipboardButton.Text = "クリップボードへ"
# $clipboardButton.Add_Click({
#     $ImageService.SaveClipboard()
#   })
# # 親コントロールとの調整
# $clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($clipboardButton)

# 保存ボタン
# →メニューへ移動
# $saveButton = New-Object System.Windows.Forms.Button
# $saveButton.AutoSize = $true
# $saveButton.Text = "保存"
# $saveButton.Add_Click({
#     $ImageService.SaveFileWithDialog()
#   })
# # 親コントロールとの調整
# $saveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($saveButton)

# 閉じるボタン
# →ウインドウの閉じるボタンから閉じればいいのでコメントアウト
# $closeButton = New-Object System.Windows.Forms.Button
# $closeButton.AutoSize = $true
# $closeButton.Text = "閉じる"
# $closeButton.Add_Click({
#     $form.Close()
#   })
# # 親コントロールとの調整
# $closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($closeButton)

# 表示
# メニューはDock=Topとなるので、最後に追加する必要あり。
$ImageService = New-Object ImageService($imageBox, $Path)
$form.Controls.Add($menu)
$form.ShowDialog() | Out-Null

# 後片付け
$form.Dispose()
$ImageService.Dispose()
