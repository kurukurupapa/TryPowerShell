<#
.SYNOPSIS
タブコントロールを少し使ってみるPowerShellスクリプトです。

.DESCRIPTION
タブコントロールを少し使ってみるPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

参考
・[コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)
・[TabControl クラス (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.tabcontrol?view=windowsdesktop-7.0)

.EXAMPLE
Layout01_Tab.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# フォーム
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "タブコントロールのサンプル"
$Form.Size = New-Object System.Drawing.Size(320, 240)
$Form.Padding = New-Object System.Windows.Forms.Padding(10)

# TabControl
$TabControl = New-Object System.Windows.Forms.TabControl
$TabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$Form.Controls.Add($TabControl)

# TabPage1
$TabPage1 = New-Object System.Windows.Forms.TabPage
$TabPage1.Text = "Tab 1"
$TabControl.Controls.Add($TabPage1)

# ダミー
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Label in Tab 1"
$Label1.Dock = [System.Windows.Forms.DockStyle]::Top
$TabPage1.Controls.Add($Label1)

# TabPage2
$TabPage2 = New-Object System.Windows.Forms.TabPage
$TabPage2.Text = "Tab 2"
$TabControl.Controls.Add($TabPage2)

# ダミー
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Label in Tab 2"
$Label2.Dock = [System.Windows.Forms.DockStyle]::Top
$TabPage2.Controls.Add($Label2)

# 表示
$Form.ShowDialog() | Out-Null

# 後処理
$Form.Dispose()
