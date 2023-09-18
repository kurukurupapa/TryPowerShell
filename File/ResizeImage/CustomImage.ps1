# 画像クラス
# 注意
# ・事前に次のAdd-Typeをしておく。
#   Add-Type -AssemblyName System.Drawing
# ・当クラス定義と同じスクリプト内でAdd-Typeすると、Add-Typeよりクラス定義が優先して読み込まれる。
# ・クラス定義が読み込まれるとき、アセンブリがロードされていないとエラーになる。
class CustomImage {
  $Path
  $Dir
  $FileName
  $Extension
  $OriginalImage
  $Image

  static [CustomImage] FromDummy() {
    $obj = New-Object CustomImage
    return $obj
  }

  static [CustomImage] FromFile([string]$path) {
    $obj = New-Object CustomImage($path)
    return $obj
  }

  static [CustomImage] FromImage([System.Drawing.Bitmap]$image) {
    $obj = New-Object CustomImage($image)
    return $obj
  }

  CustomImage() {
    $this._SetDummyImage()
  }

  CustomImage([string]$path) {
    $this._Load($path)
  }

  CustomImage([System.Drawing.Bitmap]$image) {
    $this._SetOriginalImage($image)
  }

  [void] _SetDummyImage() {
    $tmp = [System.Drawing.Bitmap]::new(320, 240)
    $g = [System.Drawing.Graphics]::FromImage($tmp)
    $brush = [System.Drawing.Brushes]::White
    $g.FillRectangle($brush, 0, 0, $tmp.Width, $tmp.Height)
    $g.Dispose()
    $this._SetOriginalImage($tmp)
  }

  [void] _SetOriginalImage($image) {
    $this.Dispose()
    $this.OriginalImage = $image.Clone()
    $this.Image = $image
    Write-Verbose "入力サイズ：$($this.Image.Width), $($this.Image.Height)"
  }

  # 画像読み込み
  [void] _Load($srcpath) {
    $this.Dispose()

    $this.Path = $srcpath
    $this.Dir = Split-Path $srcpath -Parent
    $this.FileName = Split-Path $srcpath -Leaf
    #$this.Extension = Split-Path $srcpath -Extension # PowerShell 6.0 以降
    $this.Extension = [System.IO.Path]::GetExtension($srcpath)

    $tmp = [System.Drawing.Bitmap]::FromFile($srcpath)
    $this._SetOriginalImage($tmp)
  }

  # 画像保存
  [void] Save($destpath) {
    #$destpath = $path -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
    #$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    #$destpath = $this.Path -replace "(.*)(\..*?)", "`$1_${timestamp}`$2"
    $format = $this.Image.RawFormat.Guid
    switch ([System.IO.Path]::GetExtension($destpath)) {
      '.bmp' { $format = [System.Drawing.Imaging.ImageFormat]::Bmp }
      '.gif' { $format = [System.Drawing.Imaging.ImageFormat]::Gif }
      '.jpeg' { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
      '.jpg' { $format = [System.Drawing.Imaging.ImageFormat]::Jpeg }
      '.png' { $format = [System.Drawing.Imaging.ImageFormat]::Png }
    }
    $this.Image.Save($destpath, $format)
    Write-Verbose "保存しました。${destpath}, ${format}"
  }

  [void] Reset() {
    $this.SetWorkImage($this.OriginalImage.Clone())
    Write-Verbose "リセット：$($this.Image.Width), $($this.Image.Height)"
  }

  # リサイズ
  [void] Resize($width, $height) {
    $k = [Math]::Min($width / $this.Image.Width, $height / $this.Image.Height)
    $w = [int][Math]::Round($this.Image.Width * $k)
    $h = [int][Math]::Round($this.Image.Height * $k)
    $destImage = [System.Drawing.Bitmap]::new($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($destImage)
    $g.DrawImage($this.Image, 0, 0, $w, $h)
    $g.Dispose()
    $this.SetWorkImage($destImage)
    Write-Verbose "リサイズ：${w}, ${h}"
  }

  # フレーム描画
  [void] DrawFrame($color, $size) {
    $pen = New-Object System.Drawing.Pen($color, $size)
    $g = [System.Drawing.Graphics]::FromImage($this.Image)
    $g.DrawRectangle($pen, 0, 0, $this.Image.Width - 1, $this.Image.Height - 1)
    $g.Dispose()
    Write-Verbose "フレーム描画：$($color.Name), ${size}px"
  }

  # グレースケール変換（色成分の平均値を計算する方法）
  # TODO 処理が重いのでBitmap.LockBitsメソッドを使った方がいいかも。
  # 参考：[画像のカラーバランスを補正して表示する - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/graphics/colorbalance.html)
  [void] ConvertToGrayByAverage() {
    for ($x = 0; $x -lt $this.Image.Width; $x++) {
      for ($y = 0; $y -lt $this.Image.Height; $y++) {
        $pixel = $this.Image.GetPixel($x, $y)
        $gray  = [Math]::Round([Byte](($pixel.R + $pixel.G + $pixel.B) / 3))
        $color = [System.Drawing.Color]::FromArgb($gray, $gray, $gray)
        $this.Image.SetPixel($x, $y, $color)
      }
    }
    Write-Verbose "グレースケール変換（色成分の平均値を計算する方法）"
  }

  # グレースケール変換（ColorMatrixクラスを使用する方法）
  # 参考：[画像をグレースケールに変換して表示する - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/graphics/grayscale.html)
  [void] ConvertToGrayByMatrix() {
    # ColorMatrixオブジェクトの作成
    # グレースケールに変換するための行列を指定する
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0.299, 0.299, 0.299, 0, 0),
        @(0.587, 0.587, 0.587, 0, 0),
        @(0.114, 0.114, 0.114, 0, 0),
        @(0, 0, 0, 1, 0),
        @(0, 0, 0, 0, 1)))

    # ImageAttributesオブジェクトの作成
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $ia.SetColorMatrix($cm)

    # ImageAttributesを使用してグレースケールを描画
    $g = [System.Drawing.Graphics]::FromImage($this.Image)
    $g.DrawImage(
      $this.Image,
      [System.Drawing.Rectangle]::new(0, 0, $this.Image.Width, $this.Image.Height),
      0, 0, $this.Image.Width, $this.Image.Height,
      [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Dispose()
    Write-Verbose "グレースケール変換（ColorMatrixクラスを使用する方法）"
  }

  [void] SetWorkImage($image) {
    $this.Image.Dispose()
    $this.Image = $image
  }

  [void] Dispose() {
    if ($this.Image) {
      $this.OriginalImage.Dispose()
      $this.OriginalImage = $null
      $this.Image.Dispose()
      $this.Image = $null
    }
  }
}
