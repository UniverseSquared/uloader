# uloader

uloader is a small bootloader for [OpenComputers](https://ocdoc.cil.li/) computers.

## Installation

If you want to update uloader when it is already installed, reboot to the uloader menu and select 'Update uloader'.

To install uloader from OpenOS, use the following commands:
```
# wget https://raw.githubusercontent.com/UniverseSquared/uloader/master/installer.lua
# installer
```

After the installation completes, you should be able to reboot to uloader.

Using the installer from an os other than OpenOS may work, but is not supported. If it does not run, download [installer.lua](https://raw.githubusercontent.com/UniverseSquared/uloader/master/installer.lua), flash it to the eeprom and reboot. You also must set the eeprom's data to the address of the hard drive uloader's files should be stored on. This can be done with the eeprom's `setData` method. **Before doing this, however, you should ensure you have an internet card.**

## Features

- OpenOS-style booting (/init.lua)
- Plan9k-style booting (files from /boot/kernel/)
- Internet booting

## Configuration

Some options can be configured in uloader, by modifying the configuration file at /uloader/config.lua. The options are as follows:

| Option | Description | Default value |
| ------ | ----------- | ------------- |
| `resolution` | The resolution that should be set on boot. Either a table of two numbers (width and height) or the string "max", which sets the resolution to the maximum the GPU can handle. | `"max"` |
| `alwaysMenu` | If this is true, the boot selection menu will always be shown. If this is false, the menu will be skipped if there is only one boot candidate. | `true` |
| `backgroundColor` | The background color in the menu. | `0x000000` |
| `foregroundColor` | The foreground (text) color in the menu. | `0xFFFFFF` |
| `selectedBackgroundColor` | The background color of the selected item in the menu. | `0xFFFFFF` |
| `selectedForegroundColor` | The foreground (text) color of the selected item in the menu. | `0x000000` |
