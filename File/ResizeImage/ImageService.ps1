# 画像操作クラス
# 注意
# ・事前に次のAdd-Typeをしておく。
#   Add-Type -AssemblyName System.Windows.Forms
# ・当クラス定義と同じスクリプト内でAdd-Typeすると、Add-Typeよりクラス定義が優先して読み込まれる。
# ・クラス定義が読み込まれるとき、アセンブリがロードされていないとエラーになる。
class ImageService {
  $ImageBox
  $CustomImage

  ImageService($ImageBox, $SrcPath) {
    if ($SrcPath) {
      $this.CustomImage = New-Object CustomImage $SrcPath
    } else {
      $this.CustomImage = New-Object CustomImage
    }
    $this.ImageBox = $ImageBox
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  [void] Dispose() {
    $this.CustomImage.Dispose()
  }

  # フレーム描画
  [void] DrawFrame($Color, $Size) {
    $this.CustomImage.DrawFrame($color, $size)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # クリップボードから画像読み込み
  [bool] LoadClipboard() {
    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if ($image) {
      $this.CustomImage = New-Object CustomImage($image)
      $this.ImageBox.Image = $image
      # Write-Verbose "クリップボードから読み込みました。"
      return $true
    }
    return $false
  }

  # 画像ファイル読み込み
  [void] LoadFile($FilePath) {
    $this.CustomImage = New-Object CustomImage($FilePath)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # ファイル読み込みダイアログボックスを表示してファイル読み込み
  [bool] LoadFileWithDialog() {
    # ファイルパス取得
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "ファイルを開く"
    $openFileDialog.Filter = "画像ファイル|*.bmp;*.jpg;*.jpeg;*.png;*.gif|すべてのファイル（*.*）|*.*"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
      # 画像ファイル読み込み
      $this.LoadFile($openFileDialog.FileName)
      return $true
    }
    return $false
  }

  # リセット
  [void] Reset() {
    $this.CustomImage.Reset()
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # リサイズ
  [void] Resize($width, $Height) {
    $this.CustomImage.Resize($Width, $Height)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # クリップボードへ保存
  [void] SaveClipboard() {
    [System.Windows.Forms.Clipboard]::SetImage($this.CustomImage.Image)
    Write-Verbose "クリップボードにコピーしました。"
  }

  # 画像ファイル保存
  [void] SaveFile($FilePath) {
    $this.CustomImage.Save($FilePath)
  }

  # ファイル保存ダイアログボックスを表示してファイル保存
  [bool] SaveFileWithDialog() {
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    # $dialog.Filter = "画像ファイル（*$($this.CustomImage.Extension)）|*$($this.CustomImage.Extension)|すべてのファイル（*.*）|*.*"
    $dialog.Filter = "画像ファイル|*.bmp;*.jpg;*.jpeg;*.png;*.gif|すべてのファイル（*.*）|*.*"
    if ($this.CustomImage.Path) {
      $dialog.InitialDirectory = $this.CustomImage.Dir
      $dialog.FileName = $this.CustomImage.FileName
    }
    $result = $dialog.ShowDialog()
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
      $savePath = $dialog.FileName
      $this.CustomImage.Save($savePath)
      return $true
    }
    return $false
  }
}
