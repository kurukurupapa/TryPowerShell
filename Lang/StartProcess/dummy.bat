echo on
echo dummy.bat
echo %DATE% %TIME%
echo カレントディレクトリ: %CD%
echo arg1: %1
echo error message >&2
exit /b %1
