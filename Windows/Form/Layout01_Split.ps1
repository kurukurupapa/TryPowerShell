<#
.SYNOPSIS
分割コンテナーを少し使ってみるPowerShellスクリプトです。

.DESCRIPTION
分割コンテナーを少し使ってみるPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

参考
・[コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)
・[SplitContainer クラス (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.splitcontainer?view=windowsdesktop-7.0)

.EXAMPLE
Layout01_Tab.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# フォーム
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "分割コンテナーのサンプル"
$Form.Size = New-Object System.Drawing.Size(320, 240)
$Form.Padding = New-Object System.Windows.Forms.Padding(10)

# SplitContainer1
$SplitContainer1 = New-Object System.Windows.Forms.SplitContainer
$SplitContainer1.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$SplitContainer1.Dock = [System.Windows.Forms.DockStyle]::Fill
$Form.Controls.Add($SplitContainer1)

# ダミー
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = "Label 1"
$Label1.Dock = [System.Windows.Forms.DockStyle]::Top
$SplitContainer1.Panel1.Controls.Add($Label1)

# SplitContainer2
$SplitContainer2 = New-Object System.Windows.Forms.SplitContainer
$SplitContainer2.Orientation = [System.Windows.Forms.Orientation]::Horizontal
$SplitContainer2.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$SplitContainer2.Dock = [System.Windows.Forms.DockStyle]::Fill
$SplitContainer1.Panel2.Controls.Add($SplitContainer2)

# ダミー
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Text = "Label 2"
$Label2.Dock = [System.Windows.Forms.DockStyle]::Top
$SplitContainer2.Panel1.Controls.Add($Label2)

# ダミー
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Text = "Label 3"
$Label3.Dock = [System.Windows.Forms.DockStyle]::Top
$SplitContainer2.Panel2.Controls.Add($Label3)

# 表示
$Form.ShowDialog() | Out-Null

# 後処理
$Form.Dispose()
