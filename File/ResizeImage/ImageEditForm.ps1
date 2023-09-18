<#
.SYNOPSIS
�摜�t�@�C����ҏW���܂��B

.DESCRIPTION
���̃X�N���v�g�́A�摜�t�@�C����ҏW���ʃt�@�C���ɕۑ����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́AVerbose �̂݃T�|�[�g���Ă��܂��B

.EXAMPLE
ImageEditForm.ps1 D:\tmp\srcimage.jpg
#>

[CmdletBinding()]
param(
  [String]$Path,
  [switch]$Help = $false
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $psDir "CustomImage.ps1")
. (Join-Path $psDir "ImageService.ps1")

# �w���v
if ($Help) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# �t�H�[��
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName

# �摜�{�b�N�X
$imageBox = New-Object Windows.Forms.PictureBox
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

# �t�@�C���ǂݍ��݃{�^��
$loadFileButton = New-Object System.Windows.Forms.Button
$loadFileButton.AutoSize = $true
$loadFileButton.Text = "�t�@�C���ǂݍ���"
$loadFileButton.Add_Click({
    $ImageService.LoadFileWithDialog()
  })
# �e�R���g���[���Ƃ̒���
$loadFileButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($loadFileButton)

# �N���b�v�{�[�h�ǂݍ��݃{�^��
$loadClipboardButton = New-Object System.Windows.Forms.Button
$loadClipboardButton.AutoSize = $true
$loadClipboardButton.Text = "�N���b�v�{�[�h�ǂݍ���"
$loadClipboardButton.Add_Click({
    $ImageService.LoadClipboard()
  })
# �e�R���g���[���Ƃ̒���
$loadClipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($loadClipboardButton)

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
      $ImageService.Resize($w, $h)
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
      $ImageService.DrawFrame($color, $size)
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
    $ImageService.Reset()
  })
# �e�R���g���[���Ƃ̒���
$resetButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($resetButton)

# �N���b�v�{�[�h�{�^��
$clipboardButton = New-Object System.Windows.Forms.Button
$clipboardButton.AutoSize = $true
$clipboardButton.Text = "�N���b�v�{�[�h��"
$clipboardButton.Add_Click({
    $ImageService.SaveClipboard()
  })
# �e�R���g���[���Ƃ̒���
$clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($clipboardButton)

# �ۑ��{�^��
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.AutoSize = $true
$saveButton.Text = "�ۑ�"
$saveButton.Add_Click({
    $ImageService.SaveFileWithDialog()
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
$ImageService = New-Object ImageService($imageBox, $Path)
$form.ShowDialog() | Out-Null

# ��Еt��
$form.Dispose()
$ImageService.Dispose()
