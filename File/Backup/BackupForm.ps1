<#
.SYNOPSIS
�t�@�C����t�H���_���o�b�N�A�b�v���܂��B

.DESCRIPTION
���̃X�N���v�g�́A�t�@�C����t�H���_���A�R�s�[���A���O�Ƀ^�C���X�^���v��t���܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
BackupForm.ps1 D:\tmp\dummy.txt
BackupForm.ps1 D:\tmp
#>

[CmdletBinding()]
param (
  [string]$path
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
Add-Type -AssemblyName System.Windows.Forms
. (Join-Path $psDir "BackupService.ps1")

# �w���v
if (!$path) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �t�H�[��
$form = New-Object System.Windows.Forms.Form -Property @{
  Text    = $psBaseName
  Width   = 480
  Height  = 320
  Padding = New-Object System.Windows.Forms.Padding(10)
}

# �e�L�X�g�{�b�N�X
# Fill�ݒ�ɂ���̂ŁA�ŏ��ɓo�^����B
$form.Controls.Add(($textBox = New-Object System.Windows.Forms.TextBox -Property @{
      AutoSize  = $false # �e�L�X�g�{�b�N�X���g�ɂ��T�C�Y������OFF
      Multiline = $true
      Dock      = [System.Windows.Forms.DockStyle]::Fill
    }))

# ���x��
# ��Top�ݒ�͌㏟���B�����x���͏ォ��2�Ԗڂɕ\���B
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = "�R�����g����"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Top
      Padding  = New-Object System.Windows.Forms.Padding(0, 5, 0, 0)
    }))

# ���x��
# ��Top�ݒ�͌㏟���B�����x���͏ォ��1�Ԗڂɕ\���B
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = $path
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Top
      # Padding  = New-Object System.Windows.Forms.Padding(5)
    }))

# �o�b�N�A�b�v��t�H���_�I�����x��
$form.Controls.Add((New-Object System.Windows.Forms.Label -Property @{
      Text     = "�o�b�N�A�b�v��t�H���_"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Bottom
      Padding  = New-Object System.Windows.Forms.Padding(0, 10, 0, 0)
    }))

# �o�b�N�A�b�v��t�H���_�I�����W�I�{�^��
$folderArr = @(
  @{Text = "����t�H���_"; Folder = "."; Checked = $true },
  @{Text = "backup�t�H���_"; Folder = "backup"; Checked = $false },
  @{Text = "bak�t�H���_"; Folder = "bak"; Checked = $false },
  @{Text = "bk�t�H���_"; Folder = "bk"; Checked = $false }
)
$folderArr | ForEach-Object {
  $_.RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
    Text     = $_.Text
    Checked  = $_.Checked
    AutoSize = $true
    Dock     = [System.Windows.Forms.DockStyle]::Bottom
  }
  if ($_.Text -eq $folderArr[-1].Text) {
    $_.RadioButton.Padding = New-Object System.Windows.Forms.Padding(0, 0, 0, 10)
  }
  $form.Controls.Add($_.RadioButton)
}

# �{�^��
$form.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
      Text     = "�o�b�N�A�b�v"
      AutoSize = $true
      Dock     = [System.Windows.Forms.DockStyle]::Bottom
      Padding  = New-Object System.Windows.Forms.Padding(5)
    }))
$button.Add_Click({
    # �o�b�N�A�b�v��t�H���_���擾
    $folder = $null
    $folderArr | ForEach-Object {
      if ($_.RadioButton.Checked) {
        $folder = $_.Folder
      }
    }

    # �o�b�N�A�b�v���{
    $service = New-Object BackupService($path)
    $service.MakeOutPath($folder)
    $service.Backup()
    $service.WriteLog($textBox.Text)

    # �t�H�[�������
    $form.Close()
  })

# �\��
$form.ShowDialog() | Out-Null

# �㏈��
$form.Dispose()
