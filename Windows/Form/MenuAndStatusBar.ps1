<#
.SYNOPSIS
�t�H�[���ɃX�e�[�^�X�o�[��\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���ɃX�e�[�^�X�o�[��\������PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
MenuAndStatusBar.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PsName = Split-Path $MyInvocation.InvocationName -Leaf
$PsBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[���쐬
$Form = New-Object System.Windows.Forms.Form
$Form.Text = $PsBaseName
$Form.Size = New-Object System.Drawing.Size(320, 240)

# ���j���[���쐬
$MainMenu = New-Object System.Windows.Forms.MainMenu
$Form.Menu = $MainMenu

# File���j���[���ڂ��쐬
$MenuItem1 = New-Object System.Windows.Forms.MenuItem
$MenuItem1.Text = "File"
$MainMenu.MenuItems.Add($MenuItem1)

# File���j���[�̃T�u���j���[���ڂ��쐬
$SubMenuItem11 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem11.Text = "Open"
$MenuItem1.MenuItems.Add($SubMenuItem11)

$SubMenuItem12 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem12.Text = "Close"
$MenuItem1.MenuItems.Add($SubMenuItem12)

# Edit���j���[���ڂ��쐬
$MenuItem2 = New-Object System.Windows.Forms.MenuItem
$MenuItem2.Text = "Edit"
$MainMenu.MenuItems.Add($MenuItem2)

# Edit���j���[�̃T�u���j���[���ڂ��쐬
$SubMenuItem21 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem21.Text = "Cut"
$MenuItem2.MenuItems.Add($SubMenuItem21)

$SubMenuItem22 = New-Object System.Windows.Forms.MenuItem
$SubMenuItem22.Text = "Copy"
$MenuItem2.MenuItems.Add($SubMenuItem22)

# �_�~�[
$CenterButton = New-Object System.Windows.Forms.Button
$CenterButton.Text = "Center"
$CenterButton.Dock = [System.Windows.Forms.DockStyle]::Fill
$CenterButton.Add_Click({
    $StatusBar.Text = (Get-Date -Format u)
  })
$Form.Controls.Add($CenterButton)

# �_�~�[
$TopButton = New-Object System.Windows.Forms.Button
$TopButton.Text = "Top"
$TopButton.Dock = [System.Windows.Forms.DockStyle]::Top
$Form.Controls.Add($TopButton)

# �_�~�[
$BottomButton = New-Object System.Windows.Forms.Button
$BottomButton.Text = "Bottom"
$BottomButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
$Form.Controls.Add($BottomButton)

# �X�e�[�^�X�o�[
# Dock=Botom�ƂȂ�̂ŁA�Ō�ɒǉ�����K�v����B
$StatusBar = New-Object System.Windows.Forms.StatusBar
$StatusBar.Text = "�X�e�[�^�X�o�["
$Form.Controls.Add($StatusBar)
Write-Host "StatusBar: $($StatusBar.Dock)"

# �\��
$Form.ShowDialog() | Out-Null

# �㏈��
$Form.Dispose()
