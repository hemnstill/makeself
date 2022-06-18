@echo off
set THISDIR=%~dp0
set /p VERSION= < %~dp0../VERSION

cd /d "%THISDIR%"

echo Test run on artifact 'makeself-%VERSION%.run.bat'
"../build-windows/makeself-%VERSION%.run.bat" --target ./tmp/makeself-windows-cmd
