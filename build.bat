@echo off

warp-packer --arch windows-x64 --input_dir .\src\ --exec launch.cmd --output activatewindow.exe

ResourceHacker -open activatewindow.exe -save activatewindow.exe -action addskip -res src\Dryicons-Aesthetica-2-Windows.ico -mask ICONGROUP,MAIN,
