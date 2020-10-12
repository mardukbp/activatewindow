@echo off

set CWD=%~dp0
set PATH=%PATH%;%CWD%

powershell -ExecutionPolicy Bypass -File %CWD%\activatewindow.ps1
exit
