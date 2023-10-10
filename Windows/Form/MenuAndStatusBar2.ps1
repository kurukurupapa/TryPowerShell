<#
.SYNOPSIS
�t�H�[���ɃX�e�[�^�X�o�[��\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���ɃX�e�[�^�X�o�[��\������PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

�����ł́A���j���[�̎����� MenuStrip �N���X���g���Ă��܂��B
MenuStrip �́AMainMenu ��u��������ŏ�ʃ��x���̃R���e�i�[�ł��B
�Q�l
[MenuStrip �N���X (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.menustrip?view=netframework-4.5)

.EXAMPLE
MenuAndStatusBar2.ps1
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
$MainMenu = New-Object System.Windows.Forms.MenuStrip

# File���j���[���ڂ��쐬
$MenuItem1 = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuItem1.Text = "File"

# File���j���[�̃T�u���j���[���ڂ��쐬
$SubMenuItem11 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem11.Text = "Open"

$SubMenuItem12 = New-Object System.Windows.Forms.ToolStripMenuItem
$SubMenuItem12.Text = "Close"

# Edit���j���[���ڂ��쐬
$MenuItem2 = New-Object System.Windows.Forms.ToolStripMenuItem
$MenuItem2.Text = "Edit"

# Edit���j���[�̃T�u���j���[���ڂ��쐬
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

# ���j���[
# Dock=Top�ƂȂ�̂ŁA�Ō�ɒǉ�����K�v����B
$Form.Controls.Add($MainMenu)
Write-Host "MainMenu: $($MainMenu.Dock)"

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
