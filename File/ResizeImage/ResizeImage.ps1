<#
.SYNOPSIS
�摜�t�@�C�������T�C�Y���܂��B

.DESCRIPTION
���̃X�N���v�g�́A�摜�t�@�C�����A�����Ŏw�肳�ꂽ�T�C�Y�Ɏ��܂�悤�Ɋg��/�k�����A�ʃt�@�C���ɕۑ����܂��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́AVerbose �̂݃T�|�[�g���Ă��܂��B

.EXAMPLE
ResizeImage.ps1 D:\tmp\srcimage.jpg 300 200
#>

[CmdletBinding()]
param(
  [String]$path,
  [int]$width,
  [int]$height
)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

# �w���v
if (!$path -or !$width -or !$height) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# �摜�擾�E���T�C�Y
$srcbmp = [System.Drawing.Bitmap]::FromFile($path)
Write-Verbose "���̓T�C�Y�F$($srcbmp.Width), $($srcbmp.Height)"
$k = [Math]::Min($width / $srcbmp.Width, $height / $srcbmp.Height)
$w = [int][Math]::Round($srcbmp.Width * $k)
$h = [int][Math]::Round($srcbmp.Height * $k)
Write-Verbose "�o�̓T�C�Y�F${w}, ${h}"
$destbmp = [System.Drawing.Bitmap]::new($w, $h)
$g = [System.Drawing.Graphics]::FromImage($destbmp)
$g.DrawImage($srcbmp, 0, 0, $w, $h)

# �ۑ�
$destpath = $path -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
$destbmp.Save($destpath, $srcbmp.RawFormat.Guid)
Write-Output "�ۑ����܂����B${destpath}"

# ��Еt��
$g.Dispose()
$destbmp.Dispose()
$srcbmp.Dispose()
