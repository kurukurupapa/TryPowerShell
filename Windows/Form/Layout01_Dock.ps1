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
Layout01_Dock.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# フォーム
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Size = New-Object System.Drawing.Size(320, 240)

# 中央
$center = New-Object System.Windows.Forms.Button
$center.Text = "Center"
$center.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($center)

# 上
$top = New-Object System.Windows.Forms.Button
$top.Text = "Top"
$top.Dock = [System.Windows.Forms.DockStyle]::Top
$form.Controls.Add($top)

# 下
$bottom = New-Object System.Windows.Forms.Button
$bottom.Text = "Bottom"
$bottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($bottom)

# 左
$left = New-Object System.Windows.Forms.Button
$left.Text = "Left"
$left.Dock = [System.Windows.Forms.DockStyle]::Left
$form.Controls.Add($left)

# 右
$right = New-Object System.Windows.Forms.Button
$right.Text = "Right"
$right.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($right)

# 表示
$form.ShowDialog() | Out-Null

# 後処理
$form.Dispose()
