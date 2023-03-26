<#
.SYNOPSIS
�t�H�[���Ƀe�L�X�g�{�b�N�X�ƃ{�^����\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���Ƀe�L�X�g�{�b�N�X�ƃ{�^����\������PowerShell�X�N���v�g�ł��B
�Ȃ��ANew-Object�ł́A-Propertye�ŁA��������I�u�W�F�N�g�̃v���p�e�B�ɑ΂��ď����l��^������Ƃ������ƂȂ̂ŁA�g���Ă݂܂����B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
TextBox.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[���쐬
$form = New-Object System.Windows.Forms.Form -Property @{
  Text = "�T���v���t�H�[��"
  Width = 300
  Height = 200
}
$form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
  AutoSize = $false # �e�L�X�g�{�b�N�X���g�ɂ��T�C�Y������OFF
  Multiline = $true
  Dock = [System.Windows.Forms.DockStyle]::Fill
}))
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
  Text = "���D���ȕ��������͂��Ă��������B"
  Dock = [System.Windows.Forms.DockStyle]::Top
}))
$form.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
  Text = "OK"
  Dock = [System.Windows.Forms.DockStyle]::Bottom
}))
$button.Add_Click({
  $form.Tag = $textBox.Text
  $form.Close()
})

# �\��
$form.ShowDialog() | Out-Null
Write-Output $form.Tag

# �㏈��
$form.Dispose()
