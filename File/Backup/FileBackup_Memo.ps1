# FileBackupコマンド開発メモ

mkdir .\File\Backup\work
Write-Output DUMMY > .\File\Backup\work\dummy.txt
Write-Output DUMMY > .\File\Backup\work\dummy.dat

.\File\Backup\Backup.ps1
$DebugPreference='Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work\dummy.txt
$DebugPreference='Continue'; .\File\Backup\Backup.ps1 -Verbose .\File\Backup\work

Remove-Item ('.\File\Backup\work\*_bk*.*', '.\File\Backup\work_bk*') -Recurse -Force
