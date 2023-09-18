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
$loadFileButton = New-Object System.Windows.Forms.Button
$loadFileButton.AutoSize = $true
$loadFileButton.Text = "ファイル読み込み"
$loadFileButton.Add_Click({
    $ImageService.LoadFileWithDialog()
  })
# 親コントロールとの調整
$loadFileButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($loadFileButton)

# クリップボード読み込みボタン
$loadClipboardButton = New-Object System.Windows.Forms.Button
$loadClipboardButton.AutoSize = $true
$loadClipboardButton.Text = "クリップボード読み込み"
$loadClipboardButton.Add_Click({
    $ImageService.LoadClipboard()
  })
# 親コントロールとの調整
$loadClipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($loadClipboardButton)

# リサイズボタン
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
  $resizeButton.Text = "リサイズ ${w}x${h}"
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
$frameArr = @(
  @([System.Drawing.Color]::Black, 1),
  @([System.Drawing.Color]::Gray, 1)
)
for ($i = 0; $i -lt $frameArr.Length; $i++) {
  $color, $size = $frameArr[$i]
  $frameButton = New-Object System.Windows.Forms.Button
  $frameButton.AutoSize = $true
  $frameButton.Text = "フレーム $($color.Name) ${size}px"
  $frameButton.Tag = $i
  $frameButton.Add_Click({
      $color, $size = $frameArr[$this.Tag]
      $ImageService.DrawFrame($color, $size)
    })
  # 親コントロールとの調整
  $frameButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($frameButton)
}

# グレースケールボタン（色成分の平均値を計算する方法）
$grayButton = New-Object System.Windows.Forms.Button
$grayButton.AutoSize = $true
$grayButton.Text = "グレースケール変換（平均値）"
$grayButton.Add_Click({
    $ImageService.ConvertToGrayByAverage()
  })
# 親コントロールとの調整
$grayButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton)

# グレースケールボタン（ColorMatrixクラスを使用する方法）
$grayButton2 = New-Object System.Windows.Forms.Button
$grayButton2.AutoSize = $true
$grayButton2.Text = "グレースケール変換（Matrix）"
$grayButton2.Add_Click({
    $ImageService.ConvertToGrayByMatrix()
  })
# 親コントロールとの調整
$grayButton2.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton2)

# リセットボタン
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
$clipboardButton = New-Object System.Windows.Forms.Button
$clipboardButton.AutoSize = $true
$clipboardButton.Text = "クリップボードへ"
$clipboardButton.Add_Click({
    $ImageService.SaveClipboard()
  })
# 親コントロールとの調整
$clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($clipboardButton)

# 保存ボタン
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.AutoSize = $true
$saveButton.Text = "保存"
$saveButton.Add_Click({
    $ImageService.SaveFileWithDialog()
  })
# 親コントロールとの調整
$saveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($saveButton)

# 閉じるボタン
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.AutoSize = $true
$closeButton.Text = "閉じる"
$closeButton.Add_Click({
    $form.Close()
  })
# 親コントロールとの調整
$closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($closeButton)

# 表示
$ImageService = New-Object ImageService($imageBox, $Path)
$form.ShowDialog() | Out-Null

# 後片付け
$form.Dispose()
$ImageService.Dispose()
