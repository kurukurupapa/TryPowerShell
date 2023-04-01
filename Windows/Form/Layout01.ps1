<#
.SYNOPSIS
�t�H�[���Ń��C�A�E�g�֘A�̐ݒ�������Ă݂�PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���Ń��C�A�E�g�֘A�̐ݒ�������Ă݂�PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
Layout01.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[��
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Size = New-Object System.Drawing.Size(800, 650)

# DockStyle��ݒ肵�Ċe��R���g���[�����쐬
function CreateDockPanel($title) {
  # AutoSize=$true�ɂ���ƕ\������Ȃ��Ȃ�i�傫���������Ȃ�H�j�̂ŁA�T�C�Y���w�肵�Ă���B
  $panel = New-Object System.Windows.Forms.Panel
  $panel.MinimumSize = New-Object System.Drawing.Size(50, 50)
  $panel.Size = New-Object System.Drawing.Size(200, 250)

  # DockStyle=Top�̏ꍇ�A��ɒǉ�����قǁA����ɕ\�������̂ŁA
  # ���ɔz�u����R���g���[������ǉ�����B
  $controls = CreateControls $panel $title
  for ($i = $controls.Count - 1; $i -ge 0; $i--) {
    $control = $controls[$i]
    $control.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.AddRange($control)
  }

  return $panel
}

# FlowLayoutPanel���쐬���Ċe��R���g���[����z�u
function CreateFlowPanel($title) {
  $panel = New-Object System.Windows.Forms.FlowLayoutPanel
  $panel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
  $panel.AutoSize = $true
  $panel.MinimumSize = New-Object System.Drawing.Size(100, 100)

  $controls = CreateControls $panel $title
  $panel.Controls.AddRange($controls)

  return $panel
}

# �e��R���g���[�����쐬
# �E�}�[�W����p�f�B���O�A�w�i�F�𑀍�\
function CreateControls($parent, $title) {
  $controls = @()

  # �^�C�g�����x��
  $titleLabel = New-Object System.Windows.Forms.Label
  $titleLabel.Text = $title
  $titleLabel.AutoSize = $true
  $controls += $titleLabel

  # �T���v�����W�I�{�^��
  $radioButton1 = New-Object System.Windows.Forms.RadioButton
  $radioButton1.Text = "RadioButton 1"
  $radioButton1.AutoSize = $true
  $radioButton1.Add_CheckedChanged({
      PrintControlInfo "�T���v�����W�I�{�^��1�ύX: " $this
    })
  $controls += $radioButton1
  $radioButton2 = New-Object System.Windows.Forms.RadioButton
  $radioButton2.Text = "RadioButton 2"
  $radioButton2.AutoSize = $true
  $radioButton2.Add_CheckedChanged({
      PrintControlInfo "�T���v�����W�I�{�^��2�ύX: " $this
    })
  $controls += $radioButton2

  # AutoSize�p�`�F�b�N�{�b�N�X
  $autoSizeCheckBox = New-Object System.Windows.Forms.CheckBox
  $autoSizeCheckBox.Text = "�p�l����AutoSize"
  $autoSizeCheckBox.AutoSize = $true
  $autoSizeCheckBox.Tag = @{Parent = $parent }
  $autoSizeCheckBox.Add_CheckedChanged({
      $this.Tag.Parent.AutoSize = $this.Checked
    })
  $controls += $autoSizeCheckBox

  # �p�f�B���O���삷�邽�߂̃��x���ƃ��W�I�{�^��
  $paddingLabel = New-Object System.Windows.Forms.Label
  $paddingLabel.Text = "Padding:"
  $paddingLabel.AutoSize = $true
  $controls += $paddingLabel
  # 
  $paddingComboBox = New-Object System.Windows.Forms.ComboBox
  $paddingComboBox.AutoSize = $true
  $paddingComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
  $paddingComboBox.Items.Add("0") | Out-Null
  $paddingComboBox.Items.Add("5") | Out-Null
  $paddingComboBox.Items.Add("10") | Out-Null
  $paddingComboBox.Tag = @{Parent = $parent }
  $paddingComboBox.Add_SelectedIndexChanged({
      $this.Tag.Parent.Controls | ForEach-Object {
        $_.Padding = New-Object System.Windows.Forms.Padding($this.SelectedItem)
      }
    })
  $controls += $paddingComboBox

  # �}�[�W�����삷�邽�߂̃��x���ƃ��W�I�{�^��
  $marginLabel = New-Object System.Windows.Forms.Label
  $marginLabel.Text = "Margin (DockStyle�ł͕s��):"
  $marginLabel.AutoSize = $true
  $controls += $marginLabel
  # 
  $marginComboBox = New-Object System.Windows.Forms.ComboBox
  $marginComboBox.AutoSize = $true
  $marginComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
  $marginComboBox.Items.Add("0") | Out-Null
  $marginComboBox.Items.Add("5") | Out-Null
  $marginComboBox.Items.Add("10") | Out-Null
  $marginComboBox.Tag = @{Parent = $parent }
  $marginComboBox.Add_SelectedIndexChanged({
      $this.Tag.Parent.Controls | ForEach-Object {
        $_.Margin = New-Object System.Windows.Forms.Padding($this.SelectedItem)
      }
    })
  $controls += $marginComboBox

  # �p�l���w�i�F��I�����邽�߂̃��x���ƃR���{�{�b�N�Xs
  $panelColorLabel = New-Object System.Windows.Forms.Label
  $panelColorLabel.Text = "�p�l���w�i�F:"
  $panelColorLabel.AutoSize = $true
  $controls += $panelColorLabel
  # 
  $panelColorComboBox = New-Object System.Windows.Forms.ComboBox
  $panelColorComboBox.AutoSize = $true
  $panelColorComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
  [System.Enum]::GetNames([System.Drawing.KnownColor]) | ForEach-Object {
    $color = [System.Drawing.Color]::FromName($_)
    if (!$color.IsSystemColor) {
      $panelColorComboBox.Items.Add($_) | Out-Null
    }
  }
  $panelColorComboBox.Tag = @{Panel = $parent }
  $panelColorComboBox.Add_SelectedIndexChanged({
      $this.Tag.Panel.BackColor = [System.Drawing.Color]::FromName($this.SelectedItem)
    })
  $controls += $panelColorComboBox

  # �p�l�����R���g���[���̔w�i�F��I�����邽�߂̃��x���ƃR���{�{�b�N�X
  $controlColorLabel = New-Object System.Windows.Forms.Label
  $controlColorLabel.Text = "�e�R���g���[���w�i�F:"
  $controlColorLabel.AutoSize = $true
  $controls += $controlColorLabel
  # 
  $controlColorComboBox = New-Object System.Windows.Forms.ComboBox
  $controlColorComboBox.AutoSize = $true
  $controlColorComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
  [System.Enum]::GetNames([System.Drawing.KnownColor]) | ForEach-Object {
    $color = [System.Drawing.Color]::FromName($_)
    if (!$color.IsSystemColor) {
      $controlColorComboBox.Items.Add($_) | Out-Null
    }
  }
  $controlColorComboBox.Tag = @{Panel = $parent }
  $controlColorComboBox.Add_SelectedIndexChanged({
      $this.Tag.Panel.Controls | ForEach-Object {
        $_.BackColor = [System.Drawing.Color]::FromName($this.SelectedItem)
      }
    })
  $controls += $controlColorComboBox

  # �{�^�����z�u���Ă݂�
  $button = New-Object System.Windows.Forms.Button
  $button.Text = "OK"
  $button.AutoSize = $true
  $button.Tag = @{Parent = $parent }
  $button.Add_Click({
      $this.Tag.Parent.Controls | ForEach-Object {
        PrintControlInfo "�{�^���N���b�N: " $_
      }
    })
  $controls += $button

  return $controls
}

function PrintControlInfo($prefix, $control) {
  if ($control -is [System.Windows.Forms.CheckBox] -or $control -is [System.Windows.Forms.RadioButton]) {
    Write-Host "${prefix}$($control.GetType().FullName), [$($control.Text)], $($control.Checked)"
  }
  elseif ($control -is [System.Windows.Forms.ComboBox]) {
    Write-Host "${prefix}$($control.GetType().FullName), [$($control.Text)], [$($control.SelectedItem)]"
  }
  else {
    Write-Host "${prefix}$($control.GetType().FullName), [$($control.Text)]"
  }
}

$centerPanel = CreateDockPanel "1,Center,Dock"
$centerPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($centerPanel)

$topPanel = CreateDockPanel "2,Top,Dock"
$topPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$form.Controls.Add($topPanel)

$bottomPanel = CreateFlowPanel "3,Bottom,Flow"
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($bottomPanel)

$leftPanel = CreateDockPanel "4,Left,Dock"
$leftPanel.Dock = [System.Windows.Forms.DockStyle]::Left
$form.Controls.Add($leftPanel)

$rightPanel = CreateFlowPanel "5,Right,Flow"
$rightPanel.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($rightPanel)

$form.ShowDialog() | Out-Null

$form.Dispose()
