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
$form.Width = 800
$form.Height = 600

# ���j���[
$menu = New-Object System.Windows.Forms.MenuStrip
$fileMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$fileMenu.text = "�t�@�C��"
# �t�@�C�����J��
$loadMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$loadMenu.Text = "�t�@�C�����J��"
$loadMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::O)
$loadMenu.Add_Click({
    $ImageService.LoadFileWithDialog()
  })
# �t�@�C���֕ۑ�
$saveMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$saveMenu.Text = "�t�@�C���֕ۑ�"
$saveMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::S)
$saveMenu.Add_Click({
    $ImageService.SaveFileWithDialog()
  })
# �N���b�v�{�[�h����\��t��
$loadClipboardMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$loadClipboardMenu.Text = "�N���b�v�{�[�h����\��t��"
$loadClipboardMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::V)
$loadClipboardMenu.Add_Click({
    $ImageService.LoadClipboard()
  })
# �N���b�v�{�[�h�փR�s�[
$saveClipboardMenu = New-Object System.Windows.Forms.ToolStripMenuItem
$saveClipboardMenu.Text = "�N���b�v�{�[�h�փR�s�["
$saveClipboardMenu.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::C)
$saveClipboardMenu.Add_Click({
    $ImageService.SaveClipboard()
  })
# ���j���[���ڂ̊֘A�t��
$fileMenu.DropDownItems.AddRange(@($loadMenu, $saveMenu, $loadClipboardMenu, $saveClipboardMenu))
$menu.Items.AddRange(@($fileMenu))
# $form.Controls.Add($menu)

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
# �����j���[�ֈړ�
# $loadFileButton = New-Object System.Windows.Forms.Button
# $loadFileButton.AutoSize = $true
# $loadFileButton.Text = "�t�@�C���ǂݍ���"
# $loadFileButton.Add_Click({
#     $ImageService.LoadFileWithDialog()
#   })
# # �e�R���g���[���Ƃ̒���
# $loadFileButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($loadFileButton)

# �N���b�v�{�[�h�ǂݍ��݃{�^��
# �����j���[�ֈړ�
# $loadClipboardButton = New-Object System.Windows.Forms.Button
# $loadClipboardButton.AutoSize = $true
# $loadClipboardButton.Text = "�N���b�v�{�[�h�ǂݍ���"
# $loadClipboardButton.Add_Click({
#     $ImageService.LoadClipboard()
#   })
# # �e�R���g���[���Ƃ̒���
# $loadClipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($loadClipboardButton)

# �N���b�v�{�^��
$clipLabel = New-Object System.Windows.Forms.Label
$clipLabel.Text = "�N���b�v"
$clipLabel.AutoSize = $true
$clipLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($clipLabel)

# �N���b�v�����͗p�e�L�X�g�{�b�N�X
$clipSizeTextBox = New-Object System.Windows.Forms.TextBox
$clipSizeTextBox.Text = "10"  # �f�t�H���g�l
$clipSizeTextBox.AutoSize = $true
$buttonPanel.Controls.Add($clipSizeTextBox)

$clipArr = @(
  @("��", 0, 1, 0, 0),
  @("��", 0, 0, 0, 1),
  @("��", 1, 0, 0, 0),
  @("�E", 0, 0, 1, 0)
)

for ($i = 0; $i -lt $clipArr.Length; $i++) {
  $label, $left, $top, $right, $bottom = $clipArr[$i]
  $clipButton = New-Object System.Windows.Forms.Button
  $clipButton.AutoSize = $true
  $clipButton.Text = "$label"
  $clipButton.Tag = $i
  $clipButton.Add_Click({
      $label, $left, $top, $right, $bottom = $clipArr[$this.Tag]
      $size = [int]$clipSizeTextBox.Text
      $ImageService.ClipWithOffset($left * $size, $top * $size, $right * $size, $bottom * $size)
    })
  # �e�R���g���[���Ƃ̒���
  $clipButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($clipButton)
}

# ���T�C�Y�{�^��
$resizeLabel = New-Object System.Windows.Forms.Label
$resizeLabel.Text = "���T�C�Y"
$resizeLabel.AutoSize = $true
$resizeLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($resizeLabel)
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
  #$resizeButton.Text = "���T�C�Y ${w}x${h}"
  $resizeButton.Text = "${w}x${h} ${comment}"
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
$frameLabel = New-Object System.Windows.Forms.Label
$frameLabel.Text = "�t���[��"
$frameLabel.AutoSize = $true
$frameLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($frameLabel)
$frameArr = @(
  @([System.Drawing.Color]::Black, 1),
  @([System.Drawing.Color]::Gray, 1)
)
for ($i = 0; $i -lt $frameArr.Length; $i++) {
  $color, $size = $frameArr[$i]
  $frameButton = New-Object System.Windows.Forms.Button
  $frameButton.AutoSize = $true
  # $frameButton.Text = "�t���[�� $($color.Name) ${size}px"
  $frameButton.Text = "$($color.Name) ${size}px"
  $frameButton.Tag = $i
  $frameButton.Add_Click({
      $color, $size = $frameArr[$this.Tag]
      $ImageService.DrawFrame($color, $size)
    })
  # �e�R���g���[���Ƃ̒���
  $frameButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
  $buttonPanel.Controls.Add($frameButton)
}

# �O���[�X�P�[���{�^��
$grayLabel = New-Object System.Windows.Forms.Label
$grayLabel.Text = "�O���[�X�P�[��"
$grayLabel.AutoSize = $true
$grayLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($grayLabel)

# �O���[�X�P�[���{�^���i�F�����̕��ϒl���v�Z������@�j
$grayButton = New-Object System.Windows.Forms.Button
$grayButton.AutoSize = $true
# $grayButton.Text = "�O���[�X�P�[���ϊ��i���ϒl�j"
$grayButton.Text = "���ϒl ����"
$grayButton.Add_Click({
    $ImageService.ConvertToGrayByAverage()
  })
# �e�R���g���[���Ƃ̒���
$grayButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton)

# �O���[�X�P�[���{�^���iColorMatrix�N���X���g�p������@�j
$grayButton2 = New-Object System.Windows.Forms.Button
$grayButton2.AutoSize = $true
# $grayButton2.Text = "�O���[�X�P�[���ϊ��iMatrix�j"
$grayButton2.Text = "Matrix ����"
$grayButton2.Add_Click({
    $ImageService.ConvertToGrayByMatrix()
  })
# �e�R���g���[���Ƃ̒���
$grayButton2.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$buttonPanel.Controls.Add($grayButton2)

# ���Z�b�g�{�^��
$otherLabel = New-Object System.Windows.Forms.Label
$otherLabel.Text = "���̑�"
$otherLabel.AutoSize = $true
$otherLabel.TextAlign = [System.Drawing.ContentAlignment]::BottomLeft
$buttonPanel.Controls.Add($otherLabel)
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
# �����j���[�ֈړ�
# $clipboardButton = New-Object System.Windows.Forms.Button
# $clipboardButton.AutoSize = $true
# $clipboardButton.Text = "�N���b�v�{�[�h��"
# $clipboardButton.Add_Click({
#     $ImageService.SaveClipboard()
#   })
# # �e�R���g���[���Ƃ̒���
# $clipboardButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($clipboardButton)

# �ۑ��{�^��
# �����j���[�ֈړ�
# $saveButton = New-Object System.Windows.Forms.Button
# $saveButton.AutoSize = $true
# $saveButton.Text = "�ۑ�"
# $saveButton.Add_Click({
#     $ImageService.SaveFileWithDialog()
#   })
# # �e�R���g���[���Ƃ̒���
# $saveButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($saveButton)

# ����{�^��
# ���E�C���h�E�̕���{�^���������΂����̂ŃR�����g�A�E�g
# $closeButton = New-Object System.Windows.Forms.Button
# $closeButton.AutoSize = $true
# $closeButton.Text = "����"
# $closeButton.Add_Click({
#     $form.Close()
#   })
# # �e�R���g���[���Ƃ̒���
# $closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
# $buttonPanel.Controls.Add($closeButton)

# �\��
# ���j���[��Dock=Top�ƂȂ�̂ŁA�Ō�ɒǉ�����K�v����B
$ImageService = New-Object ImageService($imageBox, $Path)
$form.Controls.Add($menu)
$form.ShowDialog() | Out-Null

# ��Еt��
$form.Dispose()
$ImageService.Dispose()
