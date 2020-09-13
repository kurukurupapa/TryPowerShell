@echo off
set batdir=%~dp0
set basename=%~n0
set errflag=0
rem call :CreateSendto 160 120 "QQVGA (Quarter QVGA)"
call :CreateSendto 300 200 ""
call :CreateSendto 320 240 "QVGA (Quarter VGA)"
call :CreateSendto 640 480 "VGA"
rem call :CreateSendto 800 600 "SVGA (Super VGA)"; 
if %errflag% == 1 (
  pause
  exit /b 1
)
timeout 5
exit /b 0

:CreateSendto
set w=%1
set h=%2
set name=%3
powershell -ExecutionPolicy RemoteSigned -File "%batdir%CreateSendto.ps1" ResizeImage_%w%x%h% "%batdir%ResizeImage.bat" " -Width %w% -Height %h% -Path"
if errorlevel 1 (
  set errflag=1
)
exit /b 0
