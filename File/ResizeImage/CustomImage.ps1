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
  $Image

  CustomImage($path) {
    $this.Path = $path
    $this.Dir = Split-Path $path -Parent
    $this.FileName = Split-Path $path -Leaf
    #$this.Extension = Split-Path $path -Extension # PowerShell 6.0 �ȍ~
    $this.Extension = [System.IO.Path]::GetExtension($path)
  }

  # �摜�ǂݍ���
  [void] Load() {
    $this.Dispose()
    $this.Image = [System.Drawing.Bitmap]::FromFile($this.Path)
    Write-Verbose "���̓T�C�Y�F$($this.Image.Width), $($this.Image.Height)"
  }

  # �摜�ۑ�
  [void] Save($destpath) {
    #$destpath = $path -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
    #$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    #$destpath = $this.Path -replace "(.*)(\..*?)", "`$1_${timestamp}`$2"
    $this.Image.Save($destpath, $this.Image.RawFormat.Guid)
    Write-Verbose "�ۑ����܂����B${destpath}"
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
    $this.SetImage($destImage)
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

  [void] SetImage($image) {
    $this.Dispose()
    $this.Image = $image
  }

  [void] Dispose() {
    if ($this.Image) {
      $this.Image.Dispose()
      $this.Image = $null
    }
  }
}
