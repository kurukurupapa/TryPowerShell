# �摜�N���X
# ����
# �E���O�Ɏ���Add-Type�����Ă����B
#   Add-Type -AssemblyName System.Drawing
# �E���N���X��`�Ɠ����X�N���v�g����Add-Type����ƁAAdd-Type���N���X��`���D�悵�ēǂݍ��܂��B
# �E�N���X��`���ǂݍ��܂��Ƃ��A�A�Z���u�������[�h����Ă��Ȃ��ƃG���[�ɂȂ�B
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
    Write-Verbose "���̓T�C�Y�F$($this.Image.Width), $($this.Image.Height)"
  }

  # �摜�ǂݍ���
  [void] _Load($srcpath) {
    $this.Dispose()

    $this.Path = $srcpath
    $this.Dir = Split-Path $srcpath -Parent
    $this.FileName = Split-Path $srcpath -Leaf
    #$this.Extension = Split-Path $srcpath -Extension # PowerShell 6.0 �ȍ~
    $this.Extension = [System.IO.Path]::GetExtension($srcpath)

    $tmp = [System.Drawing.Bitmap]::FromFile($srcpath)
    $this._SetOriginalImage($tmp)
  }

  # �摜�ۑ�
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
    Write-Verbose "�ۑ����܂����B${destpath}, ${format}"
  }

  [void] Reset() {
    $this.SetWorkImage($this.OriginalImage.Clone())
    Write-Verbose "���Z�b�g�F$($this.Image.Width), $($this.Image.Height)"
  }

  # ���T�C�Y
  [void] Resize($width, $height) {
    $k = [Math]::Min($width / $this.Image.Width, $height / $this.Image.Height)
    $w = [int][Math]::Round($this.Image.Width * $k)
    $h = [int][Math]::Round($this.Image.Height * $k)
    $destImage = [System.Drawing.Bitmap]::new($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($destImage)
    $g.DrawImage($this.Image, 0, 0, $w, $h)
    $g.Dispose()
    $this.SetWorkImage($destImage)
    Write-Verbose "���T�C�Y�F${w}, ${h}"
  }

  # �t���[���`��
  [void] DrawFrame($color, $size) {
    $pen = New-Object System.Drawing.Pen($color, $size)
    $g = [System.Drawing.Graphics]::FromImage($this.Image)
    $g.DrawRectangle($pen, 0, 0, $this.Image.Width - 1, $this.Image.Height - 1)
    $g.Dispose()
    Write-Verbose "�t���[���`��F$($color.Name), ${size}px"
  }

  # �O���[�X�P�[���ϊ��i�F�����̕��ϒl���v�Z������@�j
  # TODO �������d���̂�Bitmap.LockBits���\�b�h���g�����������������B
  # �Q�l�F[�摜�̃J���[�o�����X��␳���ĕ\������ - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/graphics/colorbalance.html)
  [void] ConvertToGrayByAverage() {
    for ($x = 0; $x -lt $this.Image.Width; $x++) {
      for ($y = 0; $y -lt $this.Image.Height; $y++) {
        $pixel = $this.Image.GetPixel($x, $y)
        $gray  = [Math]::Round([Byte](($pixel.R + $pixel.G + $pixel.B) / 3))
        $color = [System.Drawing.Color]::FromArgb($gray, $gray, $gray)
        $this.Image.SetPixel($x, $y, $color)
      }
    }
    Write-Verbose "�O���[�X�P�[���ϊ��i�F�����̕��ϒl���v�Z������@�j"
  }

  # �O���[�X�P�[���ϊ��iColorMatrix�N���X���g�p������@�j
  # �Q�l�F[�摜���O���[�X�P�[���ɕϊ����ĕ\������ - .NET Tips (VB.NET,C#...)](https://dobon.net/vb/dotnet/graphics/grayscale.html)
  [void] ConvertToGrayByMatrix() {
    # ColorMatrix�I�u�W�F�N�g�̍쐬
    # �O���[�X�P�[���ɕϊ����邽�߂̍s����w�肷��
    $cm = [System.Drawing.Imaging.ColorMatrix]::new(@(
        @(0.299, 0.299, 0.299, 0, 0),
        @(0.587, 0.587, 0.587, 0, 0),
        @(0.114, 0.114, 0.114, 0, 0),
        @(0, 0, 0, 1, 0),
        @(0, 0, 0, 0, 1)))

    # ImageAttributes�I�u�W�F�N�g�̍쐬
    $ia = New-Object System.Drawing.Imaging.ImageAttributes
    $ia.SetColorMatrix($cm)

    # ImageAttributes���g�p���ăO���[�X�P�[����`��
    $g = [System.Drawing.Graphics]::FromImage($this.Image)
    $g.DrawImage(
      $this.Image,
      [System.Drawing.Rectangle]::new(0, 0, $this.Image.Width, $this.Image.Height),
      0, 0, $this.Image.Width, $this.Image.Height,
      [System.Drawing.GraphicsUnit]::Pixel, $ia)
    $g.Dispose()
    Write-Verbose "�O���[�X�P�[���ϊ��iColorMatrix�N���X���g�p������@�j"
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
