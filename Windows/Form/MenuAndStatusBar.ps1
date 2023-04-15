<#
.SYNOPSIS
フォームにステータスバーを表示するPowerShellスクリプトです。

.DESCRIPTION
フォームにステータスバーを表示するPowerShellスクリプトです。
エラー処理を考慮していません。
<CommonParameters>をサポートしていません。

.EXAMPLE
MenuAndStatusBar.ps1
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
$MainMenu = New-Object System.Windows.Forms.MainMenu
$Form.Menu = $MainMenu

# Fileメニュー項目を作成
$MenuItem1 = New-Object System.Windows.Forms.MenuItem
$MenuItem1.Text = "File"
$MainMenu.MenuItems.Add($MenuItem1)

# Fileメニューのサブメニュー項目を作成
$SubMenuItem11 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem11.Text = "Open"
$MenuItem1.MenuItems.Add($SubMenuItem11)

$SubMenuItem12 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem12.Text = "Close"
$MenuItem1.MenuItems.Add($SubMenuItem12)

# Editメニュー項目を作成
$MenuItem2 = New-Object System.Windows.Forms.MenuItem
$MenuItem2.Text = "Edit"
$MainMenu.MenuItems.Add($MenuItem2)

# Editメニューのサブメニュー項目を作成
$SubMenuItem21 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem21.Text = "Cut"
$MenuItem2.MenuItems.Add($SubMenuItem21)

$SubMenuItem22 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem22.Text = "Copy"
$MenuItem2.MenuItems.Add($SubMenuItem22)

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
