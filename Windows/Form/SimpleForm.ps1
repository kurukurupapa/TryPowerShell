<#
.SYNOPSIS
�ȒP�ȃt�H�[����\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�ȒP�ȃt�H�[����\������PowerShell�X�N���v�g�ł��B
���̗�ł́A3�̃{�^�����c�ɕ��񂾃t�H�[����\�����A�{�^�����������ƁA�����ꂽ�{�^���̔ԍ��� $form.Tag �֕ۑ����A�t�H�[������܂��B
�Q�l
�E[Form �N���X (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.form)
�E[�R���g���[���̃��C�A�E�g �I�v�V���� - Windows Forms .NET | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/desktop/winforms/controls/layout)
�E[Button �N���X (System.Windows.Forms) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.forms.button)

�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
SimpleForm.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[���쐬
$form = New-Object System.Windows.Forms.Form
$form.AutoSize = $true
$form.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.Text = "�T���v���t�H�[��"

# ���C�A�E�g�p�l��
$layout = New-Object System.Windows.Forms.FlowLayoutPanel
$layout.AutoSize = $true
$layout.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$layout.FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
$form.Controls.Add($layout)

# �{�^��
$button = @()
for ($i = 0; $i -lt 3; $i++) {
  $button += New-Object System.Windows.Forms.Button
  $button[$i].AutoSize = $true
  $button[$i].AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
  $button[$i].Tag = $i
  $button[$i].Text = "�T���v���t�H�[���̃T���v���{�^�� $($i + 1)"
  $button[$i].Add_Click({
    # �����\�b�h�O����f�[�^�擾
    # ��1
    param($sender, $eventArgs)
    Write-Host "Add_Click ���\�b�h�O����f�[�^�擾 ��1: $($sender.Tag)"
    $dummy = "Click! $($sender.Tag) $(Get-Date)"
    $sender.Text = $dummy
    # ��2
    Write-Host "Add_Click ���\�b�h�O����f�[�^�擾 ��2: $($this.Tag)"

    # �t�H�[���Ăяo�����փf�[�^�ԋp
    # ��1
    $global:formResult = $sender.Tag
    # ��2
    $form.Tag = $sender.Tag

    # �t�H�[�������
    $form.Close()
  })
  $layout.Controls.Add($button[$i])
}

# �\��
$form.ShowDialog() | Out-Null

# �t�H�[������f�[�^�擾
Write-Output "�t�H�[������f�[�^�擾 ��1: $($global:formResult)"
Write-Output "�t�H�[������f�[�^�擾 ��2: $($form.Tag)"

# �Еt��
$form.Dispose()
