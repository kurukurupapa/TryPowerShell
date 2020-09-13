<#
.SYNOPSIS
画像ファイルをリサイズします。

.DESCRIPTION
このスクリプトは、画像ファイルを、引数で指定されたサイズに収まるように拡大/縮小し、別ファイルに保存します。
エラー処理は、考慮していません。
<CommonParameters> は、Verbose のみサポートしています。

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

# ヘルプ
if (!$path -or !$width -or !$height) {
  Get-Help $MyInvocation.MyCommand.Path -Detailed
  return
}

# 画像取得・リサイズ
$srcbmp = [System.Drawing.Bitmap]::FromFile($path)
Write-Verbose "入力サイズ：$($srcbmp.Width), $($srcbmp.Height)"
$k = [Math]::Min($width / $srcbmp.Width, $height / $srcbmp.Height)
$w = [int][Math]::Round($srcbmp.Width * $k)
$h = [int][Math]::Round($srcbmp.Height * $k)
Write-Verbose "出力サイズ：${w}, ${h}"
$destbmp = [System.Drawing.Bitmap]::new($w, $h)
$g = [System.Drawing.Graphics]::FromImage($destbmp)
$g.DrawImage($srcbmp, 0, 0, $w, $h)

# 保存
$destpath = $path -replace "(.*)(\..*?)", "`$1_${w}x${h}`$2"
$destbmp.Save($destpath, $srcbmp.RawFormat.Guid)
Write-Output "保存しました。${destpath}"

# 後片付け
$g.Dispose()
$destbmp.Dispose()
$srcbmp.Dispose()
