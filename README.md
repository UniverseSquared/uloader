# uloader

uloader is a small bootloader for [OpenComputers](https://ocdoc.cil.li/) computers.

## Installation

To install uloader from OpenOS, use the following commands:
```
# wget https://raw.githubusercontent.com/UniverseSquared/uloader/master/installer.lua
# installer
```

After the installation completes, you should be able to reboot to uloader.

If your computer does not run OpenOS, the installer likely will not work. In this case, download the uloader folder to the root of your computer's drive and then download and flash init.lua to the eeprom.

## Features

- OpenOS-style booting (/init.lua)
- Plan9k-style booting (files from /boot/kernel/)
- Internet booting
