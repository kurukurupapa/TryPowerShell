<#
.SYNOPSIS
画像をクリップします。

.DESCRIPTION
このスクリプトは、画像をクリップ領域を指定して、別ファイルに保存します。
エラー処理は、考慮していません。
<CommonParameters> は、Verbose のみサポートしています。

.EXAMPLE
ClipImage.ps1 D:\tmp\srcimage.jpg 10 10 10 10
ClipImage.ps1 D:\tmp\srcimage.jpg -offsetleft 10 -offsettop 10 -width 800 -height 600
#>

[CmdletBinding()]
param(
  [String]$path,
  [int]$offsetleft = -1,
  [int]$offsettop = -1,
  [int]$offsetright = -1,
  [int]$offsetbottom = -1,
  [int]$width = -1,
  [int]$height = -1
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# ヘルプ
Write-Output "引数：${offsetleft}, ${offsettop}, ${offsetright}, ${offsetbottom}, ${width}, ${height}"
if (!$path -or
  (($offsetleft -ge 0) -and ($offsetright -ge 0) -and ($width -ge 1)) -or
  (($offsetleft -lt 0) -and ($offsetright -lt 0) -and ($width -lt 1)) -or
  (($offsettop -ge 0) -and ($offsetbottom -ge 0) -and ($height -ge 1)) -or
  (($offsettop -lt 0) -and ($offsetbottom -lt 0) -and ($height -lt 1))) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# 画像読み込み
function LoadImage($path) {
  return [System.Drawing.Image]::FromFile($path)
}

# 画像保存
function SaveImage($path, $image) {
  $image.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  # $image.Dispose()
}

# 画像をクリップする
function ClipImage($srcimage, $offsetleft, $offsettop, $width, $height) {
  $srcrect = [System.Drawing.Rectangle]::new($offsetleft, $offsettop, $width, $height)
  $destimage = [System.Drawing.Bitmap]::new($width, $height)
  $g = [System.Drawing.Graphics]::FromImage($destimage)
  $g.DrawImage($srcimage, 0, 0, $srcrect, [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  return $destimage
}

# 入力画像データ取得
$srcimage = LoadImage $path
Write-Verbose "入力サイズ：$($srcimage.Width), $($srcimage.Height)"
if ($width -le 0) {
  $width = $srcimage.Width - $offsetleft - $offsetright
}
if ($offsetleft -lt 0) {
  $offsetleft = $srcimage.Width - $width - $offsetright
}
if ($offsetright -lt 0) {
  $offsetright = $srcimage.Width - $width - $offsetleft
}
if ($height -le 0) {
  $height = $srcimage.Height - $offsettop - $offsetbottom
}
if ($offsettop -lt 0) {
  $offsettop = $srcimage.Height - $height - $offsetbottom
}
if ($offsetbottom -lt 0) {
  $offsetbottom = $srcimage.Height - $height - $offsettop
}
Write-Verbose "オフセット：${offsetleft}, ${offsettop}, ${offsetright}, ${offsetbottom}"
Write-Verbose "出力サイズ：${width}, ${height}"
# クリップ
$destimage = ClipImage $srcimage $offsetleft $offsettop $width $height
# 保存
$destpath = $path -replace "(.*)(\..*?)", "`$1_clip`$2"
SaveImage $destpath $destimage
Write-Output "保存しました。${destpath}"
# 後片付け
$destimage.Dispose()
$srcimage.Dispose()
