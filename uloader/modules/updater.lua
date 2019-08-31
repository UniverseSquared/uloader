local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()
local eeprom = component.proxy(component.list("eeprom")())
local internet = component.list("internet")()

uloader.updater = {}

local function downloadFile(url)
    local handle = internet.request(url)
    handle.finishConnect()

    local buffer = ""
    repeat
        local data = handle.read(math.huge)
        buffer = buffer .. (data or "")
    until data == nil

    return buffer
end

function uloader.updater.selfUpdate()
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")

    if not internet then
        gpu.set(1, 1, "Updating requires an Internet Card.")
        gpu.set(1, 2, "Press any key to continue.")
        uloader.waitForKey()
        return
    end

    internet = component.proxy(internet)

    if not internet.isHttpEnabled() then
        gpu.set(1, 1, "Updating requires HTTP to be enabled.")
        gpu.set(1, 2, "To continue, enable it in your OpenComputers config.")
        gpu.set(1, 3, "Press any key to continue.")
        uloader.waitForKey()
        return
    end

    gpu.set(1, 1, "Downloading installer...")
    local data = downloadFile("https://raw.githubusercontent.com/UniverseSquared/uloader/master/installer.lua")

    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")

    load(data)()
end