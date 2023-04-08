<#
.SYNOPSIS
各種コントロールを表示するPowerShellスクリプトです。

.DESCRIPTION
各種コントロールを表示するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
Control01.ps1
#>
Add-Type -AssemblyName System.Windows.Forms
$groupMargin = New-Object System.Windows.Forms.Padding(3, 20, 3, 0)

# フォーム作成
$form = New-Object System.Windows.Forms.Form
$form.Text = "各種コントロールを表示するサンプル"
$form.Size = New-Object System.Drawing.Size(640, 480)

# フローレイアウト
$layout = New-Object System.Windows.Forms.FlowLayoutPanel
$layout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$layout.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($layout)

# --------------------------------------------------
# Labelのコントロール
$labelBaseLabel = New-Object System.Windows.Forms.Label
$labelBaseLabel.Text = "Label系"
$labelBaseLabel.AutoSize = $true
$layout.Controls.Add($labelBaseLabel)

# Label
# ・AutoSizeサポートあり、デフォルト$false
$label = New-Object System.Windows.Forms.Label
$label.Text = "Label"
$label.AutoSize = $true
$layout.Controls.Add($label)

# LinkLabel
# ・AutoSizeサポートあり、デフォルト$false
$linkLabel = New-Object System.Windows.Forms.LinkLabel
$linkLabel.Text = "LinkLabel"
$linkLabel.AutoSize = $true
$layout.Controls.Add($linkLabel)

# --------------------------------------------------
# ButtonBaseのコントロール
$buttonBaseLabel = New-Object System.Windows.Forms.Label
$buttonBaseLabel.Text = "ButtonBase"
$buttonBaseLabel.Margin = $groupMargin
$buttonBaseLabel.AutoSize = $true
$layout.Controls.Add($buttonBaseLabel)

# ButtonBase / ボタン
# ・AutoSizeサポートあり
$button = New-Object System.Windows.Forms.Button
$button.Text = "Button"
$button.AutoSize = $true
$button.Add_Click({
    Write-Host "Button: Clicked"
  })
$layout.Controls.Add($button)

# ButtonBase / チェックボックス
# ・AutoSizeサポートあり、デフォルト$true
$checkBox = New-Object System.Windows.Forms.CheckBox
$checkBox.Text = "CheckBox"
$checkBox.AutoSize = $true
$checkBox.Add_CheckedChanged({
    Write-Host "CheckBox: $($this.Checked)"
  })
$layout.Controls.Add($checkBox)

# ButtonBase / ラジオボタン
# ・AutoSizeサポートあり、デフォルト$true
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
# TextBoxBaseのコントロール
$textBoxBaseLabel = New-Object System.Windows.Forms.Label
$textBoxBaseLabel.Text = "TextBoxBase"
$textBoxBaseLabel.Margin = $groupMargin
$textBoxBaseLabel.AutoSize = $true
$layout.Controls.Add($textBoxBaseLabel)

# TextBoxBase / TextBox
# ・AutoSizeサポートあり
$textBox = New-Object System.Windows.Forms.TextBox 
$textBox.Text = "TextBox"
$textBox.Add_TextChanged({
    Write-Host "TextBox: $($this.Text)"
  })
$layout.Controls.Add($textBox) 

# TextBoxBase / MaskedTextBox
# ・AutoSizeサポートあり
# ・ユーザー入力が適切か不適切かを区別するマスクを使用します。
$maskedTextBox = New-Object System.Windows.Forms.MaskedTextBox 
$maskedTextBox.Mask = "0000/00/00"
$layout.Controls.Add($maskedTextBox) 

# TextBoxBase / RichTextBox
# ・AutoSizeサポートなし
$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Size = New-Object System.Drawing.Size(150, 50)
$richTextBox.Text = "RichTextBox"
$richTextBox.Multiline = $true
$richTextBox.Scrollbars = "Vertical"
$layout.controls.add($richTextBox)

# --------------------------------------------------
# UpDownBaseのコントロール
$upDownBaseLabel = New-Object System.Windows.Forms.Label
$upDownBaseLabel.Text = "UpDownBase"
$upDownBaseLabel.Margin = $groupMargin
$upDownBaseLabel.AutoSize = $true
$layout.Controls.Add($upDownBaseLabel)

# UpDownBase / NumericUpDown
# ・AutoSizeサポートあり
$numericUpDown = New-Object System.Windows.Forms.NumericUpDown
$numericUpDown.Minimum = 0
$numericUpDown.Maximum = 100
$numericUpDown.Value = 5
$numericUpDown.Add_ValueChanged({
    Write-Host "NumericUpDown: $($this.Value)"
  })
$layout.Controls.Add($numericUpDown)

# UpDownBase / DomainUpDown
# ・AutoSizeサポートあり
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
# ListControlのコントロール
$listControlLabel = New-Object System.Windows.Forms.Label
$listControlLabel.Text = "ListControl"
$listControlLabel.Margin = $groupMargin
$listControlLabel.AutoSize = $true
$layout.Controls.Add($listControlLabel)

# ListControl / ComboBox
# ・AutoSizeサポートなし
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
# ・AutoSizeサポートなし
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
# ・AutoSizeサポートなし
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
# その他のコントロール
$otherLabel = New-Object System.Windows.Forms.Label
$otherLabel.Text = "その他"
$otherLabel.Margin = $groupMargin
$otherLabel.AutoSize = $true
$layout.Controls.Add($otherLabel)

# ProgressBar
# ・AutoSizeサポートなし
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(150, 20) 
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Step = 5
$progressBar.Value = 70
$layout.Controls.Add($progressBar)

# TrackBar
# ・AutoSizeサポートあり
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
# ・AutoSizeサポートなし
$dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker.Size = New-Object System.Drawing.Size(150, 20)
$layout.Controls.Add($dateTimePicker)

# MonthCalendar
# ・AutoSizeサポートなし
$monthCalendar = New-Object System.Windows.Forms.MonthCalendar
$layout.Controls.Add($monthCalendar)

# --------------------------------------------------
# おまけ
$omakeLabel = New-Object System.Windows.Forms.Label
$omakeLabel.Text = "おまけ"
$omakeLabel.Margin = $groupMargin
$omakeLabel.AutoSize = $true
$layout.Controls.Add($omakeLabel)

# 状態確認
$checkButton = New-Object System.Windows.Forms.Button
$checkButton.Text = "状態確認"
$checkButton.Add_Click({
    $layout.Controls | ForEach-Object {
      Write-Host "$($_.GetType().FullName), $($_.Text), Margin=$($_.Margin), Padding=$($_.Padding), AutoSize=$($_.AutoSize)"
      # BackColor=$($this.BackColor)
    }
  })
$layout.Controls.Add($checkButton)

# 各コントロールの境界を確認
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
$borderCheckBox.Text = "境界確認"
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

# 表示
$form.ShowDialog() | Out-Null

# 後処理
$form.Dispose()
