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
