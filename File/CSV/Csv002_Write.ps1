# Windows PowerShell
# CSV�t�@�C�����������ރX�N���v�g

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"
$VerbosePreference = "Continue"
$DebugPreference = "Continue"

$baseDir = Convert-Path $(Split-Path $MyInvocation.InvocationName -Parent)
$psName = Split-Path $MyInvocation.InvocationName -Leaf
$psBaseName = $psName -replace "\.ps1$", ""
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

# �T���v���f�[�^
$arr = @(
    @("1", "2", "3"),
    @("��", "��", "��")
)

# �o��CSV�t�@�C��
$outCsvFile = "${baseDir}\TestResult\Csv002_Result.csv"

# CSV�t�@�C������������
# �����R�[�h��Shift-JIS
$arr | %{
    New-Object PSObject -Property @{
        A = $_[0]
        B = $_[1]
        C = $_[2]
    }
} | Export-Csv -Encoding Default $outCsvFile
