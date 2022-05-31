<#
ScreenCapture�p�֐�
#>
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Main($areaStr, $outPath, $clipboard, $interval, $repetition) {
  $rect = GetRectArea $areaStr
  $outPath2 = $null
  if (!$interval) {
    if ($outPath) {
      $outPath2 = GetOutFilePath $outPath "ScreenCapture"
    }
    Capture $rect $outPath2 $clipboard
  }
  else {
    Write-Verbose "�J��Ԃ� �Ԋu:$interval ��:$repetition"
    $i = 0
    while ($true) {
      $i++
      if ($outPath) {
        $outPath2 = GetOutFilePath $outPath "ScreenCapture" $i
      }
      Capture $rect $outPath2 $clipboard
      if ($repetition -and $i -ge $repetition) {
        break
      }
      Start-Sleep $interval
    }
  }
}

function GetRectArea($areaStr) {
  $rect = $null
  if (!$areaStr -or $areaStr.ToLower() -eq 'all') {
    # �S���j�^�[��Ώۂɂ���
    $screens = [System.Windows.Forms.Screen]::AllScreens
    $top = ($screens.Bounds.Top | Measure-Object -Minimum).Minimum
    $left = ($screens.Bounds.Left | Measure-Object -Minimum).Minimum
    $right = ($screens.Bounds.Right | Measure-Object -Maximum).Maximum
    $bottom = ($screens.Bounds.Bottom | Measure-Object -Maximum).Maximum
    $rect = [System.Drawing.Rectangle]::FromLTRB($left, $top, $right, $bottom)
  }
  elseif ($areaStr.ToLower() -eq 'primary') {
    # �v���C�}�����j�^�[�̂�
    $rect = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
  }
  elseif ($areaStr.ToLower() -match "^(\d+),(\d+),(\d+),(\d+)$") {
    # ��`�̈�
    $rect = New-Object System.Drawing.Rectangle($Matches[1], $Matches[2], $Matches[3], $Matches[4])
  }
  elseif ($areaStr.ToLower() -eq 'drag') {
    $rect = GetDragRect
  }
  else {
    throw "����Area�̉�̓G���[ [$areaStr]"
  }
  Write-Verbose "�L���v�`���̈� X,Y,W,H:$($rect.X),$($rect.Y),$($rect.Width),$($rect.Height)"
  return $rect
}

function GetDragRect() {
  Write-Host "�}�E�X���h���b�O���ċ�`�̈��I�����Ă��������B"
  while ([System.Windows.Forms.Control]::MouseButtons -eq 'None') { Start-Sleep 0.5 }
  $p1 = [System.Windows.Forms.Control]::MousePosition
  while ([System.Windows.Forms.Control]::MouseButtons -ne 'None') { Start-Sleep 0.5 }
  $p2 = [System.Windows.Forms.Control]::MousePosition
  $rect = [System.Drawing.Rectangle]::FromLTRB(
    [Math]::Min($p1.X, $p2.X),
    [Math]::Min($p1.Y, $p2.Y),
    [Math]::Max($p1.X, $p2.X),
    [Math]::Max($p1.Y, $p2.Y)
  )
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

function GetOutFilePath($path, $defaultName, $index) {
  # Bitmap.Save()���ɁA���΃p�X���ƃG���[�ɂȂ邱�Ƃ�����̂ŁA��΃p�X�ɕύX�B
  # �p�X�����݂��Ȃ����Ƃ��l������.Net�Ŏ����BResolve-Path���ƃG���[�ɂȂ�B
  $outPath = GetFullPath $path

  $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
  if (Test-Path $outPath -PathType Container) {
    # �����̃p�X���f�B���N�g���̏ꍇ�A�t�@�C������t������B
    $outPath = Join-Path $outPath "${defaultName}_${timestamp}.png"
  }
  elseif ($index) {
    # �J��Ԃ��L���v�`���̏ꍇ�A�t�@�C�����Ƀ^�C���X�^���v��t�^����B
    $dir = Split-Path $outPath -Parent
    $name = [System.IO.Path]::GetFileNameWithoutExtension($outPath) + "_$timestamp" + [System.IO.Path]::GetExtension($outPath)
    $outPath = Join-Path $dir $name
  }
  return $outPath
}

function GetFullPath($path) {
  [System.IO.Directory]::SetCurrentDirectory((Get-Location))
  return [System.IO.Path]::GetFullPath($path)
}
