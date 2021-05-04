$psDir = Split-Path $MyInvocation.InvocationName -Parent
$baseDir = $psDir -replace "(TryPowerShell).*$", "`$1"
$dummyPath = Join-Path $psDir "dummy.bat"

"--- Start ---"
$proc = Start-Process $dummyPath -WorkingDirectory $baseDir -NoNewWindow -PassThru -Wait
"--- End ---"
$proc.ExitCode
