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
Layout01_Anchor.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms
Write-Host $psName

# �t�H�[��
$form = New-Object System.Windows.Forms.Form
$form.Text = $psBaseName
$form.Size = New-Object System.Drawing.Size(320, 240)

$width = 90
$height = 20
$space = 10
$leftX = $space
$centerX = $form.ClientSize.Width / 2 - $width / 2
$rightX = $form.ClientSize.Width - $width - $space
$topY = $space
$centerY = ($form.ClientSize.Height / 2 - $height / 2)
$bottomY = ($form.ClientSize.Height - $height - $space)

# ����
$topLeft = New-Object System.Windows.Forms.Button
$topLeft.Location = New-Object System.Drawing.Point($leftX, $topY)
$topLeft.Size = New-Object System.Drawing.Size($width, $height)
$topLeft.Text = "Top Left"
$topLeft.Anchor = "Top, Left"
$form.Controls.Add($topLeft)

# ��
$left = New-Object System.Windows.Forms.Button
$left.Location = New-Object System.Drawing.Point($leftX, $centerY)
$left.Size = New-Object System.Drawing.Size($width, $height)
$left.Text = "Left"
$left.Anchor = "Left"
$form.Controls.Add($left)

# ����
$bottomLeft = New-Object System.Windows.Forms.Button
$bottomLeft.Location = New-Object System.Drawing.Point($leftX, $bottomY)
$bottomLeft.Size = New-Object System.Drawing.Size($width, $height)
$bottomLeft.Text = "Bottom Left"
$bottomLeft.Anchor = "Bottom, Left"
$form.Controls.Add($bottomLeft)

# ��
$top = New-Object System.Windows.Forms.Button
$top.Location = New-Object System.Drawing.Point($centerX, $topY)
$top.Size = New-Object System.Drawing.Size($width, $height)
$top.Text = "Top"
$top.Anchor = "Top"
$form.Controls.Add($top)

# ����
$center = New-Object System.Windows.Forms.Button
$center.Location = New-Object System.Drawing.Point($centerX, $centerY)
$center.Size = New-Object System.Drawing.Size($width, $height)
$center.Text = "Center"
$center.Anchor = "Top, Bottom, Left, Right"
$form.Controls.Add($center)

# ��
$bottom = New-Object System.Windows.Forms.Button
$bottom.Location = New-Object System.Drawing.Point($centerX, $bottomY)
$bottom.Size = New-Object System.Drawing.Size($width, $height)
$bottom.Text = "Bottom"
$bottom.Anchor = "Bottom"
$form.Controls.Add($bottom)

# �E��
$topRight = New-Object System.Windows.Forms.Button
$topRight.Location = New-Object System.Drawing.Point($rightX, $topY)
$topRight.Size = New-Object System.Drawing.Size($width, $height)
$topRight.Text = "Top Right"
$topRight.Anchor = "Top, Right"
$form.Controls.Add($topRight)

# �E
$right = New-Object System.Windows.Forms.Button
$right.Location = New-Object System.Drawing.Point($rightX, $centerY)
$right.Size = New-Object System.Drawing.Size($width, $height)
$right.Text = "Right"
$right.Anchor = "Right"
$form.Controls.Add($right)

# �E��
$bottomRight = New-Object System.Windows.Forms.Button
$bottomRight.Location = New-Object System.Drawing.Point($rightX, $bottomY)
$bottomRight.Size = New-Object System.Drawing.Size($width, $height)
$bottomRight.Text = "Bottom Right"
$bottomRight.Anchor = "Bottom, Right"
$form.Controls.Add($bottomRight)

# �\��
$form.ShowDialog() | Out-Null

# �㏈��
$form.Dispose()
