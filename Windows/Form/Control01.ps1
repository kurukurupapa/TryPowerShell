<#
.SYNOPSIS
�e��R���g���[����\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�e��R���g���[����\������PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
Control01.ps1
#>
Add-Type -AssemblyName System.Windows.Forms
$groupMargin = New-Object System.Windows.Forms.Padding(3, 20, 3, 0)

# �t�H�[���쐬
$form = New-Object System.Windows.Forms.Form
$form.Text = "�e��R���g���[����\������T���v��"
$form.Size = New-Object System.Drawing.Size(640, 480)

# �t���[���C�A�E�g
$layout = New-Object System.Windows.Forms.FlowLayoutPanel
$layout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$layout.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($layout)

# --------------------------------------------------
# Label�̃R���g���[��
$labelBaseLabel = New-Object System.Windows.Forms.Label
$labelBaseLabel.Text = "Label�n"
$labelBaseLabel.AutoSize = $true
$layout.Controls.Add($labelBaseLabel)

# Label
# �EAutoSize�T�|�[�g����A�f�t�H���g$false
$label = New-Object System.Windows.Forms.Label
$label.Text = "Label"
$label.AutoSize = $true
$layout.Controls.Add($label)

# LinkLabel
# �EAutoSize�T�|�[�g����A�f�t�H���g$false
$linkLabel = New-Object System.Windows.Forms.LinkLabel
$linkLabel.Text = "LinkLabel"
$linkLabel.AutoSize = $true
$layout.Controls.Add($linkLabel)

# --------------------------------------------------
# ButtonBase�̃R���g���[��
$buttonBaseLabel = New-Object System.Windows.Forms.Label
$buttonBaseLabel.Text = "ButtonBase"
$buttonBaseLabel.Margin = $groupMargin
$buttonBaseLabel.AutoSize = $true
$layout.Controls.Add($buttonBaseLabel)

# ButtonBase / �{�^��
# �EAutoSize�T�|�[�g����
$button = New-Object System.Windows.Forms.Button
$button.Text = "Button"
$button.AutoSize = $true
$button.Add_Click({
    Write-Host "Button: Clicked"
  })
$layout.Controls.Add($button)

# ButtonBase / �`�F�b�N�{�b�N�X
# �EAutoSize�T�|�[�g����A�f�t�H���g$true
$checkBox = New-Object System.Windows.Forms.CheckBox
$checkBox.Text = "CheckBox"
$checkBox.AutoSize = $true
$checkBox.Add_CheckedChanged({
    Write-Host "CheckBox: $($this.Checked)"
  })
$layout.Controls.Add($checkBox)

# ButtonBase / ���W�I�{�^��
# �EAutoSize�T�|�[�g����A�f�t�H���g$true
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Text = "RadioButton1"
$radioButton1.AutoSize = $true
$radioButton1.Add_CheckedChanged({
    Write-Host "RadioButton1: $($this.Checked)"
  })
$layout.Controls.Add($radioButton1)

$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Text = "RadioButton2"
$radioButton2.AutoSize = $true
$layout.Controls.Add($radioButton2)

# --------------------------------------------------
# TextBoxBase�̃R���g���[��
$textBoxBaseLabel = New-Object System.Windows.Forms.Label
$textBoxBaseLabel.Text = "TextBoxBase"
$textBoxBaseLabel.Margin = $groupMargin
$textBoxBaseLabel.AutoSize = $true
$layout.Controls.Add($textBoxBaseLabel)

# TextBoxBase / TextBox
# �EAutoSize�T�|�[�g����
$textBox = New-Object System.Windows.Forms.TextBox 
$textBox.Text = "TextBox"
$textBox.Add_TextChanged({
    Write-Host "TextBox: $($this.Text)"
  })
$layout.Controls.Add($textBox) 

# TextBoxBase / MaskedTextBox
# �EAutoSize�T�|�[�g����
# �E���[�U�[���͂��K�؂��s�K�؂�����ʂ���}�X�N���g�p���܂��B
$maskedTextBox = New-Object System.Windows.Forms.MaskedTextBox 
$maskedTextBox.Mask = "0000/00/00"
$layout.Controls.Add($maskedTextBox) 

# TextBoxBase / RichTextBox
# �EAutoSize�T�|�[�g�Ȃ�
$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Size = New-Object System.Drawing.Size(150, 50)
$richTextBox.Text = "RichTextBox"
$richTextBox.Multiline = $true
$richTextBox.Scrollbars = "Vertical"
$layout.controls.add($richTextBox)

# --------------------------------------------------
# UpDownBase�̃R���g���[��
$upDownBaseLabel = New-Object System.Windows.Forms.Label
$upDownBaseLabel.Text = "UpDownBase"
$upDownBaseLabel.Margin = $groupMargin
$upDownBaseLabel.AutoSize = $true
$layout.Controls.Add($upDownBaseLabel)

# UpDownBase / NumericUpDown
# �EAutoSize�T�|�[�g����
$numericUpDown = New-Object System.Windows.Forms.NumericUpDown
$numericUpDown.Minimum = 0
$numericUpDown.Maximum = 100
$numericUpDown.Value = 5
$numericUpDown.Add_ValueChanged({
    Write-Host "NumericUpDown: $($this.Value)"
  })
$layout.Controls.Add($numericUpDown)

# UpDownBase / DomainUpDown
# �EAutoSize�T�|�[�g����
$domainUpDown = New-Object System.Windows.Forms.DomainUpDown
$domainUpDown.Items.Add("Item 1") | Out-Null
$domainUpDown.Items.Add("Item 2") | Out-Null
$domainUpDown.Items.Add("Item 3") | Out-Null
$domainUpDown.SelectedIndex = 0
$domainUpDown.Add_TextChanged({
    Write-Host "DomainUpDown: $($this.SelectedIndex), $($this.SelectedItem)"
  })
$layout.Controls.Add($domainUpDown)

# --------------------------------------------------
# ListControl�̃R���g���[��
$listControlLabel = New-Object System.Windows.Forms.Label
$listControlLabel.Text = "ListControl"
$listControlLabel.Margin = $groupMargin
$listControlLabel.AutoSize = $true
$layout.Controls.Add($listControlLabel)

# ListControl / ComboBox
# �EAutoSize�T�|�[�g�Ȃ�
$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$comboBox.Items.Add("item1") | Out-Null
$comboBox.Items.Add("item2") | Out-Null
$comboBox.Items.Add("item3") | Out-Null
$comboBox.Add_SelectedIndexChanged({
    Write-Host "ComboBox: $($this.SelectedItem)"
  })
$layout.Controls.Add($comboBox)

# ListControl / ListBox
# �EAutoSize�T�|�[�g�Ȃ�
$listBox = New-Object System.Windows.Forms.ListBox 
$listBox.Size = New-Object System.Drawing.Size(150, 50) 
$listBox.Items.Add("Item 1") | Out-Null
$listBox.Items.Add("Item 2") | Out-Null
$listBox.Items.Add("Item 3") | Out-Null
$listBox.Add_SelectedIndexChanged({
    Write-Host "ListBox, SelectedIndexChanged: $($this.CheckedIndices), $($this.CheckedItems), $($this.SelectedIndices), $($this.SelectedItems)"
  })
$listBox.Add_SelectedValueChanged({
    Write-Host "ListBox, SelectedValueChanged: $($this.CheckedIndices), $($this.CheckedItems), $($this.SelectedIndices), $($this.SelectedItems)"
  })
$layout.Controls.Add($listBox) 

# ListControl / CheckedListBox
# �EAutoSize�T�|�[�g�Ȃ�
$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Size = New-Object System.Drawing.Size(150, 50)
$checkedListBox.Items.Add("Item 1") | Out-Null
$checkedListBox.Items.Add("Item 2") | Out-Null
$checkedListBox.Add_SelectedIndexChanged({
    Write-Host "CheckedListBox, SelectedIndexChanged: $($this.CheckedIndices), $($this.CheckedItems), $($this.SelectedIndices), $($this.SelectedItems)"
  })
$checkedListBox.Add_SelectedValueChanged({
    Write-Host "CheckedListBox, SelectedValueChanged: $($this.CheckedIndices), $($this.CheckedItems), $($this.SelectedIndices), $($this.SelectedItems)"
  })
$layout.Controls.Add($checkedListBox)

# --------------------------------------------------
# ���̑��̃R���g���[��
$otherLabel = New-Object System.Windows.Forms.Label
$otherLabel.Text = "���̑�"
$otherLabel.Margin = $groupMargin
$otherLabel.AutoSize = $true
$layout.Controls.Add($otherLabel)

# ProgressBar
# �EAutoSize�T�|�[�g�Ȃ�
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(150, 20) 
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Step = 5
$progressBar.Value = 70
$layout.Controls.Add($progressBar)

# TrackBar
# �EAutoSize�T�|�[�g����
$trackBar = New-Object System.Windows.Forms.TrackBar
$trackBar.Minimum = 0
$trackBar.Maximum = 100
$trackBar.TickFrequency = 10
$trackBar.LargeChange = 10
$trackBar.SmallChange = 1
$trackBar.Value = 70
$trackBar.Add_ValueChanged({
    Write-Host "TrackBar: $($this.Value)"
  })
$layout.Controls.Add($trackBar)

# DateTimePicker
# �EAutoSize�T�|�[�g�Ȃ�
$dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker.Size = New-Object System.Drawing.Size(150, 20)
$layout.Controls.Add($dateTimePicker)

# MonthCalendar
# �EAutoSize�T�|�[�g�Ȃ�
$monthCalendar = New-Object System.Windows.Forms.MonthCalendar
$layout.Controls.Add($monthCalendar)

# --------------------------------------------------
# ���܂�
$omakeLabel = New-Object System.Windows.Forms.Label
$omakeLabel.Text = "���܂�"
$omakeLabel.Margin = $groupMargin
$omakeLabel.AutoSize = $true
$layout.Controls.Add($omakeLabel)

# ��Ԋm�F
$checkButton = New-Object System.Windows.Forms.Button
$checkButton.Text = "��Ԋm�F"
$checkButton.Add_Click({
    $layout.Controls | ForEach-Object {
      Write-Host "$($_.GetType().FullName), $($_.Text), Margin=$($_.Margin), Padding=$($_.Padding), AutoSize=$($_.AutoSize)"
      # BackColor=$($this.BackColor)
    }
  })
$layout.Controls.Add($checkButton)

# �e�R���g���[���̋��E���m�F
$borderControls = $layout.Controls | ForEach-Object {
  if ($_.BorderStyle -eq 'None') {
    $_
  }
}
$colorControls = $layout.Controls | ForEach-Object {
  if ($_.BackColor -eq 'Control') {
    $_
  }
}
$borderCheckBox = New-Object System.Windows.Forms.CheckBox
$borderCheckBox.Text = "���E�m�F"
$borderCheckBox.Add_CheckedChanged({
    $style = 'None'
    $color = 'Control'
    if ($this.Checked) {
      $color = [System.Drawing.Color]::SkyBlue
      $style = 'FixedSingle'
    }
    $borderControls | ForEach-Object {
      $_.BorderStyle = $style
    }
    $colorControls | ForEach-Object {
      $_.BackColor = $color
    }
  })
$layout.Controls.Add($borderCheckBox)

# AutoSize
$autoSizeCheckBox = New-Object System.Windows.Forms.CheckBox
$autoSizeCheckBox.Text = "AutoSize"
$autoSizeCheckBox.Add_CheckedChanged({
    $layout.Controls | ForEach-Object {
      $_.AutoSize = $this.Checked
    }
  })
$layout.Controls.Add($autoSizeCheckBox)

# --------------------------------------------------

# �\��
$form.ShowDialog() | Out-Null

# �㏈��
$form.Dispose()
