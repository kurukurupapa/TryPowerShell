<#
.SYNOPSIS
スクロールバーを少し使ってみるPowerShellスクリプトです。

.DESCRIPTION
スクロールバーを少し使ってみるPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

参考
・[コントロールのレイアウト オプション - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)
・[Form クラス (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.form?view=windowsdesktop-7.0)

.EXAMPLE
Layout01_Scroll.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# フォーム
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "スクロールバーのサンプル"
$Form.AutoScroll = $true
$Form.Size = New-Object System.Drawing.Size(320, 240)
$Form.Padding = New-Object System.Windows.Forms.Padding(10)

# ダミー
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = ("ダミーテキストです。" * 10 + "`n") * 100
$Label1.Location = New-Object System.Drawing.Point(0, 0)
$Label1.Size = New-Object System.Drawing.Size(640, 480)
$Form.Controls.Add($Label1)

# 表示
$Form.ShowDialog() | Out-Null

# 後処理
$Form.Dispose()
