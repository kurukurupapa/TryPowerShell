<#
.SYNOPSIS
�t�H�[���Ń��C�A�E�g�֘A�̐ݒ�������Ă݂�PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���Ń��C�A�E�g�֘A�̐ݒ�������Ă݂�PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

�Q�l
�E[�R���g���[���̃��C�A�E�g �I�v�V���� - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)

.EXAMPLE
Layout01_Dock.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[��
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Size = New-Object System.Drawing.Size(320, 240)

# ����
$center = New-Object System.Windows.Forms.Button
$center.Text = "Center"
$center.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($center)

# ��
$top = New-Object System.Windows.Forms.Button
$top.Text = "Top"
$top.Dock = [System.Windows.Forms.DockStyle]::Top
$form.Controls.Add($top)

# ��
$bottom = New-Object System.Windows.Forms.Button
$bottom.Text = "Bottom"
$bottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
$form.Controls.Add($bottom)

# ��
$left = New-Object System.Windows.Forms.Button
$left.Text = "Left"
$left.Dock = [System.Windows.Forms.DockStyle]::Left
$form.Controls.Add($left)

# �E
$right = New-Object System.Windows.Forms.Button
$right.Text = "Right"
$right.Dock = [System.Windows.Forms.DockStyle]::Right
$form.Controls.Add($right)

# �\��
$form.ShowDialog() | Out-Null

# �㏈��
$form.Dispose()
