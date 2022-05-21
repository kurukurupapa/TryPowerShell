<#
ScreenCapture�p�֐�
#>
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Main($areaStr, $outPath, $clipboard) {
  $rect = GetRectArea $areaStr
  if ($outPath) {
    $outPath = GetOutFilePath $outPath "ScreenCapture"
  }
  Capture $rect $outPath $clipboard
}

function GetRectArea($areaStr) {
  $rect = $null
  if (!$areaStr -or $areaStr.ToLower() -eq 'all') {
    # �S���j�^�[��Ώۂɂ���
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $top    = ($screens.Bounds.Top    | Measure-Object -Minimum).Minimum
    $left   = ($screens.Bounds.Left   | Measure-Object -Minimum).Minimum
    $right  = ($screens.Bounds.Right  | Measure-Object -Maximum).Maximum
    $bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
  } elseif ($areaStr.ToLower() -eq 'primary') {
    # �v���C�}�����j�^�[�̂�
    $rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  } elseif ($areaStr.ToLower() -match "^(\d+),(\d+),(\d+),(\d+)$") {
    # ��`�̈�
    $rect = New-Object System.Drawing.Rectangle($Matches[1], $Matches[2], $Matches[3], $Matches[4])
  } else {
    throw "����Area�̉�̓G���[ [$areaStr]"
  }
  Write-Verbose "�L���v�`���̈� $rect"
  return $rect
}

function Capture($rect, $outPath, $clipboard) {
  $bitmap = New-Object System.Drawing.Bitmap($rect.Width, $rect.Height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.CopyFromScreen($rect.Left, $rect.Top, 0, 0, $bitmap.Size)
  if ($outPath) {
    $bitmap.Save($outPath)
    Write-Verbose "�t�@�C���ۑ����܂����B $outPath"
  }
  if ($clipboard) {
    [Windows.Forms.Clipboard]::SetImage($bitmap)
    Write-Verbose "�N���b�v�{�[�h�փR�s�[���܂����B"
  }
  $graphics.Dispose()
  $bitmap.Dispose()
}

function GetOutFilePath($path, $defaultName) {
  # Bitmap.Save()���ɁA���΃p�X���ƃG���[�ɂȂ邱�Ƃ�����̂ŁA��΃p�X�ɕύX�B
  # �p�X�����݂��Ȃ����Ƃ��l������.Net�Ŏ����BResolve-Path���ƃG���[�ɂȂ�B
  $outPath = GetFullPath $path

  # �����̃p�X���f�B���N�g���̏ꍇ�A�t�@�C������t������B
  if (Test-Path $outPath -PathType Container) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $outPath = Join-Path $outPath "${defaultName}_${timestamp}.png"
  }
  return $outPath
}

function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
