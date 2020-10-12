# activatewindow

<img alt="logo" src="./windows_7037.png" width="234px"/>

Window switcher for Windows inspired by [rofi](https://github.com/davatorium/rofi)

Icon by [dryicons](https://dryicons.com/icon/windows-7037)

## Installation

* Download the [latest release](https://github.com/mardukbp/activatewindow/releases/latest)

* Launch `activatewindow`, pin it to the taskbar and drag it to the first position. Now it can be summoned with `Windows + 1`.

## Notes 

* It works for me on Windows 10, YMMV.

* It is assumed that `powershell.exe` is in your `%PATH%`. 

## Building

1. Clone this repository.

2. Download the following programs to the `build` directory:

* [warp-packer](https://github.com/dgiagio/warp)
* [ResourceHacker](http://www.angusj.com/resourcehacker/)

3. Build [heatseeker](https://github.com/rschmitt/heatseeker) [using static linking](https://github.com/rschmitt/heatseeker/issues/45) and copy it to the `src` directory.

4. Execute the `build.bat` script.

## Acknowledgements

A big thank you to the authors of all the amazing programs mentioned in this README!
