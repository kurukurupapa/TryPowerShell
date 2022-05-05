# PowerShell�X�N���v�g�̃e���v���[�g�ł��B�i���[�e�B���e�B�j

# �ݒ�t�@�C���ǂݍ���
$iniPath = Join-Path $psDir "${baseName}.ini"
if (Test-Path -PathType Leaf $iniPath) {
  Write-Debug "�ݒ�t�@�C���ǂݍ��� $iniPath"
  $ini = @{}
  Get-Content $iniPath | ForEach-Object { $ini += ConvertFrom-StringData $_ }
}

# ���O�o��
$logPath = Join-Path $psDir "${baseName}.log"
Write-Debug "���O�t�@�C�� $logPath"
if (Test-Path $logPath) {
  Remove-Item $logPath
}
function Log($level, $msg) {
  $timestamp = Get-Date -Format "yyyy/MM/dd HH:mm:ss"
  "${timestamp} [${level}] ${msg}" | ForEach-Object {
    Add-Content $logPath -Value $_
    if ($level -match "INFO|WARN|ERROR") {
      Write-Host $_
    }
  }
}
function DebugLog($msg) {
  Log "DEBUG" $msg
}
function TraceLog($msg) {
  Log "TRACE" $msg
}
function InfoLog($msg) {
  Log "INFO " $msg
}
function WarnLog($msg) {
  Log "WARN " $msg
}
function ErrLog($msg) {
  Log "ERROR" $msg
}
