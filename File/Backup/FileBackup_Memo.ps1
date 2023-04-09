# FileBackupコマンド開発メモ

mkdir .\File\Backup\work
Write-Output DUMMY > .\File\Backup\work\dummy.txt
Write-Output DUMMY > .\File\Backup\work\dummy.dat
Write-Output DUMMY > .\File\Backup\work\dummy
mkdir .\File\Backup\work\sub
Write-Output DUMMY > .\File\Backup\work\sub\dummy.txt

.\File\Backup\Backup.ps1
$DebugPreference = 'Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\dummy.txt
$DebugPreference = 'Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\dummy
$DebugPreference = 'Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\dummy\
$DebugPreference = 'Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\sub
$DebugPreference = 'Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\sub\

.\File\Backup\BackupForm.ps1
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\dummy.txt
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\dummy.txt .\File\Backup\work\dummy2.txt
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\dummy
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\dummy\
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\sub
$DebugPreference = 'Continue'; .\File\Backup\BackupForm.ps1 -Verbose .\File\Backup\work\sub\

Remove-Item ('.\File\Backup\work\*_bk*', '.\File\Backup\work_bk*', '.\File\Backup\work\sub_bk*') -Recurse -Force
Remove-Item ('.\File\Backup\work\backup', '.\File\Backup\work\bak', '.\File\Backup\work\bk') -Recurse -Force
Remove-Item ('.\File\Backup\work\BackupLog.txt') -Recurse -Force
