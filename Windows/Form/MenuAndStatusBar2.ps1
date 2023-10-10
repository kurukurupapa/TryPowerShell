<#
.SYNOPSIS
フォームにステータスバーを表示するPowerShellスクリプトです。

.DESCRIPTION
フォームにステータスバーを表示するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

ここでは、メニューの実装に MenuStrip クラスを使っています。
MenuStrip は、MainMenu を置き換える最上位レベルのコンテナーです。
参考
[MenuStrip クラス (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.menustrip?view=netframework-4.5)

.EXAMPLE
MenuAndStatusBar2.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PsName = Split-Path $MyInvocation.InvocationName -Leaf
$PsBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# フォーム作成
$Form = New-Object System.Windows.Forms.Form
$Form.Text = $PsBaseName
$Form.Size = New-Object System.Drawing.Size(320, 240)

# メニューを作成
$MainMenu = New-Object System.Windows.Forms.MenuStrip

# Fileメニュー項目を作成
$MenuItem1 = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuItem1.Text = "File"

# Fileメニューのサブメニュー項目を作成
$SubMenuItem11 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem11.Text = "Open"

$SubMenuItem12 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem12.Text = "Close"

# Editメニュー項目を作成
$MenuItem2 = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuItem2.Text = "Edit"

# Editメニューのサブメニュー項目を作成
$SubMenuItem21 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem21.Text = "Cut"
$SubMenuItem21.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::X)
$SubMenuItem21.Add_Click({
    Write-Host "Cut Menu"
  })

$SubMenuItem22 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem22.Text = "Copy"
$SubMenuItem22.ShortcutKeys = @([System.Windows.Forms.Keys]::Control, [System.Windows.Forms.Keys]::C)
$SubMenuItem22.Add_Click({
    Write-Host "Copy Menu"
  })

$MenuItem1.DropDownItems.AddRange(@($SubMenuItem11, $SubMenuItem12))
$MenuItem2.DropDownItems.AddRange(@($SubMenuItem21, $SubMenuItem22))
$MainMenu.Items.AddRange(@($MenuItem1, $MenuItem2))

# ダミー
$CenterButton = New-Object System.Windows.Forms.Button
$CenterButton.Text = "Center"
$CenterButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$CenterButton.Add_Click({
    $StatusBar.Text = (Get-Date -Format u)
  })
$Form.Controls.Add($CenterButton)

# ダミー
$TopButton = New-Object System.Windows.Forms.Button
$TopButton.Text = "Top"
$TopButton.Dock = [System.Windows.Forms.DockStyle]::Top
$Form.Controls.Add($TopButton)

# ダミー
$BottomButton = New-Object System.Windows.Forms.Button
$BottomButton.Text = "Bottom"
$BottomButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Form.Controls.Add($BottomButton)

# メニュー
# Dock=Topとなるので、最後に追加する必要あり。
$Form.Controls.Add($MainMenu)
Write-Host "MainMenu: $($MainMenu.Dock)"

# ステータスバー
# Dock=Botomとなるので、最後に追加する必要あり。
$StatusBar = New-Object System.Windows.Forms.StatusBar
$StatusBar.Text = "ステータスバー"
$Form.Controls.Add($StatusBar)
Write-Host "StatusBar: $($StatusBar.Dock)"

# 表示
$Form.ShowDialog() | Out-Null

# 後処理
$Form.Dispose()
