<#
.SYNOPSIS
�X�N���[���o�[�������g���Ă݂�PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�X�N���[���o�[�������g���Ă݂�PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

�Q�l
�E[�R���g���[���̃��C�A�E�g �I�v�V���� - Windows Forms .NET | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout?view=netdesktop-7.0)
�E[Form �N���X (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.windows.forms.form?view=windowsdesktop-7.0)

.EXAMPLE
Layout01_Scroll.ps1
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[��
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "�X�N���[���o�[�̃T���v��"
$Form.AutoScroll = $true
$Form.Size = New-Object System.Drawing.Size(320, 240)
$Form.Padding = New-Object System.Windows.Forms.Padding(10)

# �_�~�[
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Text = ("�_�~�[�e�L�X�g�ł��B" * 10 + "`n") * 100
$Label1.Location = New-Object System.Drawing.Point(0, 0)
$Label1.Size = New-Object System.Drawing.Size(640, 480)
$Form.Controls.Add($Label1)

# �\��
$Form.ShowDialog() | Out-Null

# �㏈��
$Form.Dispose()
