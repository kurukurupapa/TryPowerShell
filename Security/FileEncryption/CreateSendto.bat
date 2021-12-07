@echo off
set batdir=%~dp0
set basename=%~n0
powershell -ExecutionPolicy RemoteSigned -File "%batdir%CreateSendto.ps1" FileEncryption "%batdir%FileEncryption.bat"
if errorlevel 1 (
  pause
  exit /b 1
)
powershell -ExecutionPolicy RemoteSigned -File "%batdir%CreateSendto.ps1" FileDecryption "%batdir%FileDecryption.bat"
if errorlevel 1 (
  pause
  exit /b 1
)
timeout 5
exit /b 0
