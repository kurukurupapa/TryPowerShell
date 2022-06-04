<#
.SYNOPSIS
��ʃL���v�`�����B��PowerShell�X�N���v�g�ł��B

.DESCRIPTION
��ʃL���v�`�����B��PowerShell�X�N���v�g�ł��B
�G���[�������l�����Ă��܂���B
<CommonParameters>���T�|�[�g���Ă��܂���B

.EXAMPLE
ScreenCapture.ps1 "0,0,1024,768" "D:\tmp\capture.png"
#>

[CmdletBinding()]
Param(
  <#
    �L���v�`������̈�B
    ��`�̈�̏ꍇ�A"left,top,width,height"�Ŏw�肷��i��F"0,0,1024,768"�j�B
    �v���C�}�����j�^�[�̏ꍇ�A"Primary"���w�肷��B
    �S���j�^�[�̏ꍇ�A"All"���w�肷��B
    �}�E�X�h���b�O�Ŕ͈͎w�肷��ꍇ�A"Drag"���w�肷��B
  #>
  [string]$Area,
  <# �ۑ���t�@�C�� #>
  [string]$OutPath,
  <# �N���b�v�{�[�h�փR�s�[����ꍇ�Ɏw�肷��B #>
  [switch]$Clipboard,
  <# �L���v�`���Ԋu�i�b�j #>
  [int]$Interval,
  <# �J��Ԃ��� #>
  [int]$Repetition
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$psDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
. "$psDir\Func.ps1"

# �w���v
if (!$Area -or (!$OutPath -and !$Clipboard)) {
  Get-Help $MyInvocation.InvocationName -Detailed
  return
}

# �����J�n
Write-Verbose "$psName Start"
Main $Area $OutPath $Clipboard $Interval $Repetition
Write-Verbose "$psName End"
