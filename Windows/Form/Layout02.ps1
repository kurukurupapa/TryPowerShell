<#
.SYNOPSIS
フォームでレイアウト関連の設定を試してみるPowerShellスクリプトです。

.DESCRIPTION
フォームでレイアウト関連の設定を試してみるPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

参考
・[コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)

.EXAMPLE
Layout01.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# フォーム
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Size = New-Object System.Drawing.Size(800, 650)

# DockStyleを設定して各種コントロールを作成
function CreateDockPanel($title, $dummy = $false) {
  # AutoSize=$trueにすると表示されなくなる（大きさが無くなる？）ので、サイズを指定している。
  $panel = New-Object System.Windows.Forms.Panel
  $panel.MinimumSize = New-Object System.Drawing.Size(50, 50)
  $panel.Size = New-Object System.Drawing.Size(200, 200)

  # DockStyle=Topの場合、後に追加するほど、より上に表示されるので、
  # 下に配置するコントロールから追加する。
  $controls = CreateControls $panel $title $dummy
  for ($i = $controls.Count - 1; $i -ge 0; $i--) {
    $control = $controls[$i]
    $control.Dock = [System.Windows.Forms.DockStyle]::Top
    $panel.Controls.AddRange($control)
  }

  return $panel
}

# FlowLayoutPanelを作成して各種コントロールを配置
function CreateFlowPanel($title, $dummy = $false) {
  $panel = New-Object System.Windows.Forms.FlowLayoutPanel
  $panel.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
  $panel.AutoSize = $true
  $panel.MinimumSize = New-Object System.Drawing.Size(100, 100)

  $controls = CreateControls $panel $title $dummy
  $panel.Controls.AddRange($controls)

  return $panel
}

# 各種コントロールを作成
# ・マージンやパディング、背景色を操作可能
function CreateControls($parent, $title, $dummy) {
  $controls = @()

  # タイトルラベル
  $titleLabel = New-Object System.Windows.Forms.Label
  $titleLabel.Text = $title
  $titleLabel.AutoSize = $true
  $controls += $titleLabel

  # AutoSize用チェックボックス
  $autoSizeCheckBox = New-Object System.Windows.Forms.CheckBox
  $autoSizeCheckBox.Text = "パネルのAutoSize"
  $autoSizeCheckBox.AutoSize = $true
  $autoSizeCheckBox.Tag = @{Parent = $parent }
  $autoSizeCheckBox.Add_CheckedChanged({
      $this.Tag.Parent.AutoSize = $this.Checked
    })
  $controls += $autoSizeCheckBox

  # パディング操作するためのラベルとラジオボタン
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

  # マージン操作するためのラベルとラジオボタン
  $marginLabel = New-Object System.Windows.Forms.Label
  $marginLabel.Text = "Margin (DockStyleでは不可):"
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

  # パネル背景色を選択するためのラベルとコンボボックスs
  $panelColorLabel = New-Object System.Windows.Forms.Label
  $panelColorLabel.Text = "パネル背景色:"
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

  # パネル内コントロールの背景色を選択するためのラベルとコンボボックス
  $controlColorLabel = New-Object System.Windows.Forms.Label
  $controlColorLabel.Text = "各コントロール背景色:"
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

  if ($dummy) {
    # サンプルラジオボタン
    $radioButton1 = New-Object System.Windows.Forms.RadioButton
    $radioButton1.Text = "RadioButton 1"
    $radioButton1.AutoSize = $true
    $radioButton1.Add_CheckedChanged({
        PrintControlInfo "サンプルラジオボタン1変更: " $this
      })
    $controls += $radioButton1
    $radioButton2 = New-Object System.Windows.Forms.RadioButton
    $radioButton2.Text = "RadioButton 2"
    $radioButton2.AutoSize = $true
    $radioButton2.Add_CheckedChanged({
        PrintControlInfo "サンプルラジオボタン2変更: " $this
      })
    $controls += $radioButton2

    # サンプルラジオボタン（グループボックスあり）
    # グループボックスのサイズ調整について
    # ※ここでは縦に並べる前提
    # 案1 AutoSize=$true
    # ・幅が非常に小さく、子コントロールを追加しても幅が調整されない。
    # ・高さは、子コントロールに合わせて調節してくれる模様。
    # 案2 AutoSize=$false＆Size(Width,Height)設定
    # ・事前に大きさが決まっていれば設定できそう。
    # ・親コントロールに合わせて動的にサイズ調整できなかった。
    # ・いまいち上手く設定できない（動作が不安定に感じてしまう）
    # 案3 AutoSize=$true＆Anchor設定
    # ・AutoSizeで高さを調整可能
    # ・Anchorで幅を調節可能
    # ・と思ったけど、ちょっと怪しい。
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Text = "サンプルグループボックス"
    # $groupBox.AutoSize = $true #案1
    $controls += $groupBox
    # 
    $groupRadioButton1 = New-Object System.Windows.Forms.RadioButton
    $groupRadioButton1.Text = "RadioButton 2-1"
    $groupRadioButton1.AutoSize = $true
    $groupRadioButton1.Add_CheckedChanged({
        PrintControlInfo "サンプルラジオボタン2-1変更: " $this
      })
    # 
    $groupRadioButton2 = New-Object System.Windows.Forms.RadioButton
    $groupRadioButton2.Text = "RadioButton 2-2"
    $groupRadioButton2.AutoSize = $true
    $groupRadioButton2.Add_CheckedChanged({
        PrintControlInfo "サンプルラジオボタン2-2変更: " $this
      })
    # 
    $groupRadioButton2.Dock = [System.Windows.Forms.DockStyle]::Top
    $groupBox.Controls.Add($groupRadioButton2)
    $groupRadioButton1.Dock = [System.Windows.Forms.DockStyle]::Top
    $groupBox.Controls.Add($groupRadioButton1)
    # 案2a
    # $groupBox.Width = $parent.Width
    # $groupBox.Width = $groupRadioButton1.Width
    # $groupBox.Height = $groupRadioButton1.Height * 3.5
    # 案2b
    # $parent.Add_SizeChanged({
    #     $this.Controls | ForEach-Object {
    #       if ($_ -is [System.Windows.Forms.GroupBox]) {
    #         $_.Width = $this.Width
    #       }
    #     }
    #   })
    # 案3
    # Anchorの書き方はどちらでもOK
    $groupBox.Anchor = @('Left', 'Right')
    $groupBox.Anchor = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $groupBox.AutoSize = $true
    
    # ボタンも配置してみる
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "OK"
    $button.AutoSize = $true
    $button.Tag = @{Parent = $parent }
    $button.Add_Click({
        $this.Tag.Parent.Controls | ForEach-Object {
          PrintControlInfo "ボタンクリック: " $_
        }
      })
    $controls += $button
  }

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

$centerPanel = CreateDockPanel "1,Center,Dock" -dummy $true
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

$rightPanel = CreateFlowPanel "5,Right,Flow" -dummy $true
$rightPanel.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($rightPanel)

$form.ShowDialog() | Out-Null

$form.Dispose()
