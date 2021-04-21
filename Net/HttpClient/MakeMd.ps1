<#
.SYNOPSIS
PowerShell�X�N���v�g�̃e���v���[�g�ł��B�i�V���v���Łj

.DESCRIPTION
���̃X�N���v�g�́APowerShell�X�N���v�g�̃e���v���[�g�ł��B
�G���[�����́A�l�����Ă��܂���B
<CommonParameters> �́A�T�|�[�g���Ă��܂���B

.EXAMPLE
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir"
Template2a.ps1 "D:\tmp\indir" "D:\tmp\outdir" -Verbose
#>

[CmdletBinding()]
Param(
  # [string]$inPath,
  # [string]$outPath
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace ("\.ps1$", "")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# �w���v
# if (!$inPath -and !$outPath) {
#   Get-Help $MyInvocation.InvocationName -Detailed
#   return
# }

# �����J�n
Write-Verbose "$psName Start"

$outPath = Join-Path $psDir "All.md"
Get-ChildItem (Join-Path $psDir "[0-9][0-9]_*.ps1") | `
  %{
    $switch = 'PS'
    $count = 0
    $skipflag = $false
    Get-Content $_.FullName | `
      %{
        # PowerShell�̕����s�R�����g�����AMarkdown�̖{���֕ϊ�����B
        # PowerShell�̃X�N���v�g�������AMarkdown�̃R�[�h�u���b�N�֕ϊ�����B
        # "# MakeMd SKIP_START","# MakeMd SKIP_END"�ň͂܂ꂽ�s�͈͂́AMarkdown�֕ϊ����Ȃ��B
        if ($switch -eq 'MD') {
          if ($_ -eq '#>') {
            $switch = 'PS'
            $count = 0
          } else {
            $_
            $count++
          }
        } elseif ($switch -eq 'PS') {
          if ($_ -eq '<#') {
            if ($count -gt 0) {
              '```'
            }
            $switch = 'MD'
            $count = 0
          } elseif ($_ -eq '# MakeMd SKIP_START') {
            $skipflag = $true
          } elseif ($_ -eq '# MakeMd SKIP_END') {
            $skipflag = $false
          } else {
            if ($count -eq 0) {
              '```powershell'
            }
            if ($skipflag -eq $false) {
              $_
              $count++
            }
          }
        }
      }
    if ($switch -eq 'PS' -and $count -gt 0) {
      '```'
    }
  } | `
  %{ [Text.Encoding]::UTF8.GetBytes($_ + "`r`n") } | `
  Set-Content -Encoding Byte $outPath

Write-Verbose "$psName End"
