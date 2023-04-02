<#
.SYNOPSIS
�t�H�[���Ƀ��W�I�{�^����\������PowerShell�X�N���v�g�ł��B

.DESCRIPTION
�t�H�[���Ƀ��W�I�{�^����\������PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
RadioButton.ps1
#>
Add-Type -AssemblyName System.Windows.Forms

# �t�H�[���쐬
$form = New-Object System.Windows.Forms.Form -Property @{
  Text     = "�T���v���t�H�[��"
  Width    = 300
  Height   = 200
  AutoSize = $true
  Padding  = New-Object System.Windows.Forms.Padding(10)
}
$layout = New-Object System.Windows.Forms.FlowLayoutPanel -Property @{
  FlowDirection = [System.Windows.Forms.FlowDirection]::TopDown
  AutoSize      = $true
  Dock          = [System.Windows.Forms.DockStyle]::Fill
  # BackColor     = [System.Drawing.Color]::SkyBlue
}
$form.Controls.Add($layout)

# ���W�I�{�^��
$radioButton1 = New-Object System.Windows.Forms.RadioButton
$radioButton1.Text = "���W�I�{�^��1"
$radioButton1.AutoSize = $true
$layout.Controls.Add($radioButton1)
$radioButton2 = New-Object System.Windows.Forms.RadioButton
$radioButton2.Text = "���W�I�{�^��2"
$radioButton2.AutoSize = $true
$layout.Controls.Add($radioButton2)
$radioButton3 = New-Object System.Windows.Forms.RadioButton
$radioButton3.Text = "���W�I�{�^��3"
$radioButton3.AutoSize = $true
$layout.Controls.Add($radioButton3)

# ���W�I�{�^���i�O���[�v�{�b�N�X����j
# �O���[�v�{�b�N�X�̃T�C�Y�����ɂ���
# �EAutoSize=$true, Anchor�ݒ�������Ă݂����ǎ����I�ɒ������邱�Ƃ��ł��Ȃ������B
# �ESize(Width,Height)�𖾎��I�ɐݒ肵���B
$layout.Controls.Add(($groupBox = New-Object System.Windows.Forms.GroupBox -Property @{
      Text = "�������̃O���[�v"
      # AutoSize = $true
      # Size     = New-Object System.Drawing.Size(500, 50)
      # Anchor   = [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
      # Anchor   = @('Left', 'Right')
    }))
$radioButtons2 = @(
  @{Text = "AppleAppleApple"; Checked = $false },
  @{Text = "Banana"; Checked = $true },
  @{Text = "Cherry"; Checked = $false }
)
$radioButtons2 | ForEach-Object {
  $groupBox.Controls.Add(($_.RadioButton = New-Object System.Windows.Forms.RadioButton -Property @{
        Text     = $_.Text
        Checked  = $_.Checked
        AutoSize = $true
        # ��ɓo�^�������̂��A����ɂȂ�B
        Dock     = [System.Windows.Forms.DockStyle]::Top
      }))
}
$groupBox.Width = $radioButtons2[0].RadioButton.Width
$groupBox.Height = $radioButtons2[0].RadioButton.Height * ($radioButtons2.Count + 1)

# �{�^��
$layout.Controls.Add(($button = New-Object System.Windows.Forms.Button -Property @{
      Text = "��Ԋm�F"
    }))
$button.Add_Click({
    Write-Host "���W�I�{�^��1-1 $($radioButton1.Checked)"
    Write-Host "���W�I�{�^��1-2 $($radioButton2.Checked)"
    Write-Host "���W�I�{�^��1-3 $($radioButton3.Checked)"
    for ($i = 0; $i -lt $radioButtons2.Length; $i++) {
      Write-Host "���W�I�{�^��2-$($i+1) $($radioButtons2[$i].RadioButton.Checked)"
    }
  })

# �\��
$form.ShowDialog() | Out-Null

# �㏈��
$form.Dispose()
