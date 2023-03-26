<#
.SYNOPSIS
�摜�t�@�C����ҏW���܂��B

.DESCRIPTION
���̃X�N���v�g�́A�摜�t�@�C����ҏW���ʃt�@�C���ɕۑ����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́AVerbose �̂݃T�|�[�g���Ă��܂��B

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

# �w���v
if (!$path) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# �摜�ǂݍ���
$imageObj = New-Object CustomImage($path)
$imageObj.Load()

# �t�H�[��
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName

# �摜�{�b�N�X
$imageBox = New-Object Windows.Forms.PictureBox
$imageBox.Image = $imageObj.Image
$imageBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom
# �e�R���g���[���Ƃ̒���
$imageBox.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($imageBox)

# �{�^���p�l��
$buttonPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$buttonPanel.AutoSize = $true
$buttonPanel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
# �e�R���g���[���Ƃ̒���
$buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($buttonPanel)

# ���T�C�Y�{�^��
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
  #$resizeButton.Text = "���T�C�Y ${w}x${h} $comment"
  $resizeButton.Text = "���T�C�Y ${w}x${h}"
  $resizeButton.Tag = $i
  $resizeButton.Add_Click({
    $w, $h, $comment, $tmp = $sizeArr[$this.Tag]
    $imageObj.Resize($w, $h)
    $imageBox.Image = $imageObj.Image
  })
  # �e�R���g���[���Ƃ̒���
  $resizeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($resizeButton)
}

# �t���[���ǉ��{�^��
$frameArr = @(
  @([System.Drawing.Color]::Black, 1),
  @([System.Drawing.Color]::Gray, 1)
)
for ($i = 0; $i -lt $frameArr.Length; $i++) {
  $color, $size = $frameArr[$i]
  $frameButton = New-Object System.Windows.Forms.Button
  $frameButton.AutoSize = $true
  $frameButton.Text = "�t���[�� $($color.Name) ${size}px"
  $frameButton.Tag = $i
  $frameButton.Add_Click({
    $color, $size = $frameArr[$this.Tag]
    $imageObj.DrawFrame($color, $size)
    $imageBox.Image = $imageObj.Image
  })
  # �e�R���g���[���Ƃ̒���
  $frameButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($frameButton)
}

# ���Z�b�g�{�^��
$resetButton = New-Object System.Windows.Forms.Button
$resetButton.AutoSize = $true
$resetButton.Text = "���Z�b�g"
$resetButton.Add_Click({
  $imageObj.Load()
  $imageBox.Image = $imageObj.Image
})
# �e�R���g���[���Ƃ̒���
$resetButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($resetButton)

# �N���b�v�{�[�h�{�^��
$clipboardButton = New-Object System.Windows.Forms.Button
$clipboardButton.AutoSize = $true
$clipboardButton.Text = "�N���b�v�{�[�h��"
$clipboardButton.Add_Click({
  [System.Windows.Forms.Clipboard]::SetImage($imageObj.Image)
  Write-Verbose "�N���b�v�{�[�h�ɃR�s�[���܂����B"
})
# �e�R���g���[���Ƃ̒���
$clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($clipboardButton)

# �ۑ��{�^��
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.AutoSize = $true
$saveButton.Text = "�ۑ�"
$saveButton.Add_Click({
  $dialog = New-Object System.Windows.Forms.SaveFileDialog
  $dialog.Filter = "�摜�t�@�C���i*$($imageObj.Extension)�j|*$($imageObj.Extension)|���ׂẴt�@�C���i*.*�j|*.*"
  $dialog.InitialDirectory = $imageObj.Dir
  $dialog.FileName = $imageObj.FileName
  $result = $dialog.ShowDialog()
  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $savePath = $dialog.FileName
    $imageObj.Save($savePath)
  }
})
# �e�R���g���[���Ƃ̒���
$saveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($saveButton)

# ����{�^��
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.AutoSize = $true
$closeButton.Text = "����"
$closeButton.Add_Click({
  $form.Close()
})
# �e�R���g���[���Ƃ̒���
$closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($closeButton)

# �\��
$form.ShowDialog() | Out-Null

# ��Еt��
$form.Dispose()
$imageObj.Dispose()
