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
# 操作系のコントロール

# ボタン
$button = New-Object System.Windows.Forms.Button
$button.Text = "Button"
$button.Add_Click({
    Write-Host "Button: Clicked"
  })
$layout.Controls.Add($button)

# チェックボックス
$checkBox = New-Object System.Windows.Forms.CheckBox
$checkBox.Text = "CheckBox"
$checkBox.Add_CheckedChanged({
    Write-Host "CheckBox: $($this.Checked)"
  })
$layout.Controls.Add($checkBox)

# ラジオボタン
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Text = "RadioButton1"
$radioButton1.Add_CheckedChanged({
    Write-Host "RadioButton1: $($this.Checked)"
  })
$layout.Controls.Add($radioButton1)

$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Text = "RadioButton2"
$layout.Controls.Add($radioButton2)

# DomainUpDown
$domainUpDown = New-Object System.Windows.Forms.DomainUpDown
$domainUpDown.Items.Add("Item 1") | Out-Null
$domainUpDown.Items.Add("Item 2") | Out-Null
$domainUpDown.Items.Add("Item 3") | Out-Null
$domainUpDown.SelectedIndex = 0
$domainUpDown.Add_TextChanged({
    Write-Host "DomainUpDown: $($this.SelectedIndex), $($this.SelectedItem)"
  })
$layout.Controls.Add($domainUpDown)

# MaskedTextBox
# ユーザー入力が適切か不適切かを区別するマスクを使用します。
$maskedTextBox = New-Object System.Windows.Forms.MaskedTextBox 
$maskedTextBox.Mask = "0000/00/00"
$layout.Controls.Add($maskedTextBox) 

# NumericUpDown
$numericUpDown = New-Object System.Windows.Forms.NumericUpDown
$numericUpDown.Minimum = 0
$numericUpDown.Maximum = 100
$numericUpDown.Value = 5
$numericUpDown.Add_ValueChanged({
    Write-Host "NumericUpDown: $($this.Value)"
  })
$layout.Controls.Add($numericUpDown)

# TextBox
$textBox = New-Object System.Windows.Forms.TextBox 
$textBox.Text = "TextBox"
$textBox.Add_TextChanged({
    Write-Host "TextBox: $($this.Text)"
  })
$layout.Controls.Add($textBox) 

# TrackBar
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

# CheckedListBox
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

# ComboBox
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

# DateTimePicker
# ・AutoSizeサポートなし
$dateTimePicker = New-Object System.Windows.Forms.DateTimePicker
$dateTimePicker.Size = New-Object System.Drawing.Size(150, 20)
$layout.Controls.Add($dateTimePicker)

# ListBox
# ・AutoSizeサポートなし
$listBox = New-Object System.Windows.Forms.ListBox 
$listBox.Size = New-Object System.Drawing.Size(150, 50) 
$listBox.Items.Add("Item 1") | Out-Null
$listBox.Items.Add("Item 2") | Out-Null
$layout.Controls.Add($listBox) 

# MonthCalendar
# ・AutoSizeサポートなし
$monthCalendar = New-Object System.Windows.Forms.MonthCalendar
$layout.Controls.Add($monthCalendar)

# RichTextBox
# ・AutoSizeサポートなし
$richTextBox = New-Object System.Windows.Forms.RichTextBox
$richTextBox.Size = New-Object System.Drawing.Size(150, 50)
$richTextBox.Text = "RichTextBox"
$richTextBox.Multiline = $true
$richTextBox.Scrollbars = "Vertical"
$layout.controls.add($richTextBox)

# --------------------------------------------------
# 表示系のコントロール

# Label
$label = New-Object System.Windows.Forms.Label
$label.Text = "Label"
$layout.Controls.Add($label)

# LinkLabel
$linkLabel = New-Object System.Windows.Forms.LinkLabel
$linkLabel.Text = "LinkLabel"
$layout.Controls.Add($linkLabel)

# ProgressBar
# ・AutoSizeサポートなし
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(150, 20) 
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Step = 5
$progressBar.Value = 70
$layout.Controls.Add($progressBar)

# --------------------------------------------------

# 表示
$form.ShowDialog() | Out-Null

# 後処理
$form.Dispose()
