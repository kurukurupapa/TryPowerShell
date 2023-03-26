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
  $Image

  CustomImage($path) {
    $this.Path = $path
    $this.Dir = Split-Path $path -Parent
    $this.FileName = Split-Path $path -Leaf
    #$this.Extension = Split-Path $path -Extension # PowerShell 6.0 以降
    $this.Extension = [System.IO.Path]::GetExtension($path)
  }

  # 画像読み込み
  [void] Load() {
    $this.Dispose()
    $this.Image = [System.Drawing.Bitmap]::FromFile($this.Path)
    Write-Verbose "入力サイズ：$($this.Image.Width), $($this.Image.Height)"
  }

  # 画像保存
  [void] Save($destpath) {
    #$destpath = $path -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
    #$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    #$destpath = $this.Path -replace "(.*)(\..*?)", "`$1_${timestamp}`$2"
    $this.Image.Save($destpath, $this.Image.RawFormat.Guid)
    Write-Verbose "保存しました。${destpath}"
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
    $this.SetImage($destImage)
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
