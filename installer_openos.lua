local computer = require("computer")
local component = require("component")
local filesystem = require("filesystem")
local event = require("event")
local eeprom = component.eeprom
local internet = component.internet

if not component.isAvailable("internet") then
    print("This installer requires an Internet Card.")
    return
end

print("Please insert the eeprom you wish to install uloader to, and then press a key.")
event.pull(nil, "key_down")

print("Downloading installer...")
--local handle = internet.request("https://raw.githubusercontent.com/UniverseSquared/uloader/master/installer.lua")
local handle = internet.request("https://pastebin.com/raw/XA2rfrB6")
handle.finishConnect()

local buffer = ""
repeat
    local data = handle.read(math.huge)
    buffer = buffer .. (data or "")
until data == nil

print("Flashing installer to eeprom. Do not reboot or shutdown.")
eeprom.set(buffer)

print("Setting eeprom data...")
eeprom.setData(filesystem.get("/").address)

print("Finished flashing installer. The system will reboot in 3 seconds.")
event.timer(3, function() computer.shutdown(true) end)

while true do event.pull() end