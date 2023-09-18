# �摜����N���X
# ����
# �E���O�Ɏ���Add-Type�����Ă����B
#   Add-Type -AssemblyName System.Windows.Forms
# �E���N���X��`�Ɠ����X�N���v�g����Add-Type����ƁAAdd-Type���N���X��`���D�悵�ēǂݍ��܂��B
# �E�N���X��`���ǂݍ��܂��Ƃ��A�A�Z���u�������[�h����Ă��Ȃ��ƃG���[�ɂȂ�B
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

  # �t���[���`��
  [void] DrawFrame($Color, $Size) {
    $this.CustomImage.DrawFrame($color, $size)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # �N���b�v�{�[�h����摜�ǂݍ���
  [bool] LoadClipboard() {
    $image = [System.Windows.Forms.Clipboard]::GetImage()
    if ($image) {
      $this.CustomImage = New-Object CustomImage($image)
      $this.ImageBox.Image = $image
      # Write-Verbose "�N���b�v�{�[�h����ǂݍ��݂܂����B"
      return $true
    }
    return $false
  }

  # �摜�t�@�C���ǂݍ���
  [void] LoadFile($FilePath) {
    $this.CustomImage = New-Object CustomImage($FilePath)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # �t�@�C���ǂݍ��݃_�C�A���O�{�b�N�X��\�����ăt�@�C���ǂݍ���
  [bool] LoadFileWithDialog() {
    # �t�@�C���p�X�擾
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = "�t�@�C�����J��"
    $openFileDialog.Filter = "�摜�t�@�C��|*.bmp;*.jpg;*.jpeg;*.png;*.gif|���ׂẴt�@�C���i*.*�j|*.*"
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
      # �摜�t�@�C���ǂݍ���
      $this.LoadFile($openFileDialog.FileName)
      return $true
    }
    return $false
  }

  # ���Z�b�g
  [void] Reset() {
    $this.CustomImage.Reset()
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # ���T�C�Y
  [void] Resize($width, $Height) {
    $this.CustomImage.Resize($Width, $Height)
    $this.ImageBox.Image = $this.CustomImage.Image
  }

  # �N���b�v�{�[�h�֕ۑ�
  [void] SaveClipboard() {
    [System.Windows.Forms.Clipboard]::SetImage($this.CustomImage.Image)
    Write-Verbose "�N���b�v�{�[�h�ɃR�s�[���܂����B"
  }

  # �摜�t�@�C���ۑ�
  [void] SaveFile($FilePath) {
    $this.CustomImage.Save($FilePath)
  }

  # �t�@�C���ۑ��_�C�A���O�{�b�N�X��\�����ăt�@�C���ۑ�
  [bool] SaveFileWithDialog() {
    $dialog = New-Object System.Windows.Forms.SaveFileDialog
    # $dialog.Filter = "�摜�t�@�C���i*$($this.CustomImage.Extension)�j|*$($this.CustomImage.Extension)|���ׂẴt�@�C���i*.*�j|*.*"
    $dialog.Filter = "�摜�t�@�C��|*.bmp;*.jpg;*.jpeg;*.png;*.gif|���ׂẴt�@�C���i*.*�j|*.*"
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
