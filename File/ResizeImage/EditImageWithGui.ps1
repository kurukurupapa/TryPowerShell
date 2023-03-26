<#
.SYNOPSIS
画像ファイルを編集します。

.DESCRIPTION
このスクリプトは、画像ファイルを編集し別ファイルに保存します。
エラー処理は、考慮していません。
<CommonParameters> は、Verbose のみサポートしています。

.EXAMPLE
EditImageGui.ps1 D:\tmp\srcimage.jpg
#>

[CmdletBinding()]
param(
  [String]$path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $psDir "CustomImage.ps1")

# ヘルプ
if (!$path) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# 画像読み込み
$imageObj = New-Object CustomImage($path)
$imageObj.Load()

# フォーム
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName

# 画像ボックス
$imageBox = New-Object Windows.Forms.PictureBox
$imageBox.Image = $imageObj.Image
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
    $imageObj.Resize($w, $h)
    $imageBox.Image = $imageObj.Image
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
    $imageObj.DrawFrame($color, $size)
    $imageBox.Image = $imageObj.Image
  })
  # 親コントロールとの調整
  $frameButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($frameButton)
}

# リセットボタン
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.AutoSize = $true
$resetButton.Text = "リセット"
$resetButton.Add_Click({
  $imageObj.Load()
  $imageBox.Image = $imageObj.Image
})
# 親コントロールとの調整
$resetButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($resetButton)

# クリップボードボタン
$clipboardButton = New-Object System.Windows.Forms.Button
$clipboardButton.AutoSize = $true
$clipboardButton.Text = "クリップボードへ"
$clipboardButton.Add_Click({
  [System.Windows.Forms.Clipboard]::SetImage($imageObj.Image)
  Write-Verbose "クリップボードにコピーしました。"
})
# 親コントロールとの調整
$clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($clipboardButton)

# 保存ボタン
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.AutoSize = $true
$saveButton.Text = "保存"
$saveButton.Add_Click({
  $dialog = New-Object System.Windows.Forms.SaveFileDialog
  $dialog.Filter = "画像ファイル（*$($imageObj.Extension)）|*$($imageObj.Extension)|すべてのファイル（*.*）|*.*"
  $dialog.InitialDirectory = $imageObj.Dir
  $dialog.FileName = $imageObj.FileName
  $result = $dialog.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $savePath = $dialog.FileName
    $imageObj.Save($savePath)
  }
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
$form.ShowDialog() | Out-Null

# 後片付け
$form.Dispose()
$imageObj.Dispose()
