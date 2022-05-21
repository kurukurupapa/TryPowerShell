# ��ʃL���v�`�����B��PowerShell�X�N���v�g�̊J������

# ����m�F
# Visual Studio Code �Ȃ�A���s�������s��I�����āAF8�L�[�Ŏ��s�ł���B

# ��ʃL���v�`���i�t�@�C���o�́j
Add-Type -AssemblyName System.Drawing
function CaptureToFile($rect, $outPath) {
  # Save���ɁA���΃p�X���ƃG���[�ɂȂ邱�Ƃ�����̂ŁA��΃p�X�ɕύX�B
  # �p�X�����݂��Ȃ����Ƃ��l������.Net�Ŏ����BResolve-Path���ƃG���[�ɂȂ�B
  $outPath = GetFullPath $outPath
  # �L���v�`��
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  $bitmap.Save($outPath)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "�L���v�`�����܂����B $($rect.Location) $($rect.Size) $outPath"
}
function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
$rect = [System.Drawing.Rectangle]::FromLTRB(0, 0, 500, 500)
CaptureToFile $rect "work\capture.png"

# ��ʃL���v�`���i�N���b�v�{�[�h�ցj
function CaptureToClipboard($rect) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  [Windows.Forms.Clipboard]::SetImage($bitmap)
  $graphics.Dispose()
  $bitmap.Dispose()
  Write-Host "�L���v�`�����܂����B $($rect.Location) $($rect.Size)"
}
CaptureToClipboard $rect
Get-Clipboard -Format Image

# �}���`���j�^�[�l��
# �S���j�^�[��1�̉摜�t�@�C���ɕۑ�
$screens = [System.Windows.Forms.Screen]::AllScreens
$top    = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
$left   = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
$right  = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
$bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
$rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
CaptureToFile $rect "work\capture.png"
# �v���C�}�����j�^�[�̂�
$rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
CaptureToFile $rect "work\capture.png"
# �A�N�e�B�u���j�^�[�̂� ��C#/.NET�֐������삷��K�v�����肻���Ȃ̂ŏȗ��B

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
# [Windows�̃R�}���h���C������X�N���[���V���b�g���B��(PowerShell) | Misohena Blog](https://misohena.jp/blog/2021-08-08-take-screenshot-on-windows-power-shell.html)

# ����m�F��
$PSVersionTable
# PSVersion                      5.1.19041.1682
# PSEdition                      Desktop
Get-Item "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
# Version       : 4.8.04084
