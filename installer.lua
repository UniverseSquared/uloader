local computer = require("computer")
local component = require("component")
local invoke = component.invoke
local eeprom = component.proxy(component.list("eeprom")())
local filesystem = require("filesystem")

if not component.isAvailable("internet") then
    print("This installer requires an internet card.")
end

local internet = component.proxy(component.list("internet")())

function downloadFile(url)
    local handle = internet.request(url)
    handle.finishConnect()

    local buffer = ""
    repeat
        local data = handle.read(math.huge)
        buffer = buffer .. (data or "")
    until data == nil

    return buffer
end

local urlBase = "https://raw.githubusercontent.com/UniverseSquared/uloader/master"
local fileList = {
    "/uloader/config.lua",
    "/uloader/internet_boot.lua"
}

filesystem.makeDirectory("/uloader")

for _, path in pairs(fileList) do
    local url = urlBase .. path
    print("Downloading " .. url .. " to " .. path .. "...")

    local data = downloadFile(url, path)
    local fileHandle = io.open(path, "w")
    fileHandle:write(data)
    fileHandle:close()
end

print("Downloading init.lua...")
local data = downloadFile(urlBase .. "/init.lua", "/tmp/init.lua")

print("Flashing uloader. Do not power off or reboot.")
eeprom.set(data)
eeprom.setData(computer.getBootAddress())

print("Successfully installed uloader. It is now safe to reboot.")
