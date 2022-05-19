# ��ʃL���v�`�����B��PowerShell�X�N���v�g�̊J������

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

# ��ʃL���v�`��
Add-Type -AssemblyName System.Drawing
function CaptureToFile($rect, $outPath) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  $bitmap.Save($outPath)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "�L���v�`�����܂����B $($rect.Location) $($rect.Size) $outPath"
}
$rect = [System.Drawing.Rectangle]::FromLTRB(0, 0, 500, 500)
$outPath = "work\a.png"
CaptureToFile $rect $outPath

function CaptureToClipboard($rect) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  # Set-Clipboard -Value $bitmap
  # Set-Clipboard -Value $graphics -Format Image
  [Windows.Forms.Clipboard]::SetImage($bitmap)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "�L���v�`�����܂����B $($rect.Location) $($rect.Size)"
}
CaptureToClipboard $rect
Get-Clipboard -Format Image

# �摜���N���b�v�{�[�h�ɃR�s�[
$bitmap = New-Object System.Drawing.Bitmap($outPath)
# ��1
$data = New-Object System.Windows.Forms.DataObject
$data.SetImage($bitmap)
[Windows.Forms.Clipboard]::SetDataObject($data, $true)
# ��2
[Windows.Forms.Clipboard]::SetImage($bitmap)
# 
Get-Clipboard -Format Image
$bitmap.Dispose()

# �}�E�X�̍��W
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Cursor]::Position
[System.Windows.Forms.Control]::MouseButtons
[System.Windows.Forms.Control]::MousePosition

function GetUserRect() {
  Write-Host "�}�E�X���h���b�O���ċ�`�̈��I�����Ă��������B"
  while ([System.Windows.Forms.Control]::MouseButtons -eq 'None') { Start-Sleep 0.5 }; Write-Host "Pressed"
  $p1 = [System.Windows.Forms.Control]::MousePosition
  while ([System.Windows.Forms.Control]::MouseButtons -ne 'None') { Start-Sleep 0.5 }; Write-Host "Released"
  $p2 = [System.Windows.Forms.Control]::MousePosition
  $rect = [System.Drawing.Rectangle]::FromLTRB([Math]::Min($p1.X, $p2.X), [Math]::Min($p1.Y, $p2.Y), [Math]::Max($p1.X, $p2.X), [Math]::Max($p1.Y, $p2.Y))
  Write-Host $rect
  return $rect
}
$rect = GetUserRect

# �Q�l�T�C�g
# [PowerShell ���W���[�� �u���E�U�[ - PowerShell | Microsoft Docs](https://docs.microsoft.com/ja-jp/powershell/module/?view=powershell-5.1)
# [.NET API �u���E�U�[ | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/?view=netframework-4.5)
# [Bitmap �N���X (System.Drawing) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.drawing.bitmap?view=netframework-4.5)
# [Clipboard �N���X (System.Windows) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.windows.clipboard?view=netframework-4.5)
# [Graphics �N���X (System.Drawing) | Microsoft Docs](https://docs.microsoft.com/ja-jp/dotnet/api/system.drawing.graphics?view=netframework-4.5)
# [�ȒP�IPowerShell�ō쐬�ł����ʘ^��c�[���̏Љ�ƍ���[No18] - BookALittle](https://bookalittle.com/howtocheck-operation-byrecording-pstool/)
# [�C���^�[�l�b�g��̉摜���N���b�v�{�[�h�ɃR�s�[����R�[�h(PowerShell��)](https://gist.github.com/bu762/6e0f3668e59d4a932821)

# ����m�F��
$PSVersionTable
# PSVersion                      5.1.19041.1682
# PSEdition                      Desktop
Get-Item "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
# Version       : 4.8.04084
