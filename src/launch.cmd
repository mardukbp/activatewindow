@echo off

set CWD=%~dp0

powershell -ExecutionPolicy Bypass -File %CWD%\activatewindow.ps1
exit
