local computer = computer or require("computer")
local component = component or require("component")
local eeprom = component.proxy(component.list("eeprom")())
local fs = component.proxy(eeprom.getData())
local internet = component.proxy(component.list("internet")())
local gpu = component.proxy(component.list("gpu")())

local y = 1
local status = print or function(str)
    gpu.set(1, y, str)
    y = y + 1
end

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
    "/uloader/init.lua",
    "/uloader/config.lua",
    "/uloader/modules/internet_boot.lua",
    "/uloader/modules/boot_detection.lua",
    "/uloader/modules/fs.lua",
    "/uloader/modules/updater.lua",
    "/uloader/modules/menu.lua",
    "/uloader/modules/config.lua"
}

fs.makeDirectory("/uloader")
fs.makeDirectory("/uloader/modules")

for _, path in pairs(fileList) do
    status("Downloading file " .. path .. "...")

    if path == "/uloader/config.lua" and fs.exists(path) then
        status("Config not overwritten. You may want to refer to the documentation on GitHub to manually update your config if necessary.")
    else
        local url = urlBase .. path
        local data = downloadFile(url)

        if fs.exists(path) then
            fs.remove(path)
        end

        local handle = fs.open(path, "w")
        fs.write(handle, data)
        fs.close(handle)
    end
end

status("Downloading init.lua...")
local init = downloadFile(urlBase .. "/init.lua")

status("Flashing uloader. Do not power off or reboot.")
eeprom.set(init)

status("Completed installation! Press any key to reboot.")

while true do
    local signal = { computer.pullSignal() }
    if signal[1] == "key_down" then
        computer.shutdown(true)
    end
end