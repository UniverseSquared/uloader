local invoke = component.invoke
local eeprom = component.proxy(component.list("eeprom")())
local gpu = component.proxy(component.list("gpu")())
local screen = component.list("screen")()
local w, h = gpu.getResolution()

gpu.bind(screen)

local function readFile(fs, path)
    local handle, reason = invoke(fs, "open", path)
    if not handle then
        return nil, reason
    end

    local buffer = ""
    repeat
        local data = invoke(fs, "read", handle, math.huge)
        buffer = buffer .. (data or "")
    until data == nil

    return buffer
end

local function boot(initData)
    local buffer = readFile(initData.fs, initData.path)
    local init = load(buffer)
    init()
end

function waitForKey()
    while true do
        local signal = { computer.pullSignal() }
        if signal[1] == "key_down" then
            break
        end
    end
end

local function loadConfig()
    local fs = eeprom.getData()
    
    if not invoke(fs, "exists", "/uloader/config.lua") then
        gpu.set(1, 1, "No config file (/uloader/config.lua) exists! Press any key to shutdown.")
        waitForKey()
        computer.shutdown()
    end

    local configData, reason = readFile(fs, "/uloader/config.lua")

    if not configData then
        return nil, reason
    end

    local config = load(configData, "=uloader_config")()

    local resolution = config.resolution
    if resolution == "max" then
        resolution = { gpu.maxResolution() }
    end

    gpu.setResolution(resolution[1], resolution[2])

    return config
end

local config = loadConfig()

local fs = eeprom.getData()
for k, module in pairs(invoke(fs, "list", "/uloader/modules")) do
    if k ~= "n" then
        local path = "/uloader/modules/" .. module
        load(readFile(fs, path))()
    end
end

local menu = createMenu()

if #menu == 0 then
    error("no bootable medium found")
end

if #menu == 1 and not config.alwaysMenu then
    boot(menu[1])
end

local i = 1
printMenu(menu, i)
while true do
    local signal = { computer.pullSignal() }
    if signal[1] == "key_down" then
        local code = signal[4]
        if code == 200 then
            i = i - 1
        elseif code == 208 then
            i = i + 1
        elseif code == 28 then
            menu[i].callback(menu[i])
        end

        if i > #menu then
            i = 1
        elseif i < 1 then
            i = #menu
        end

        printMenu(menu, i)
    elseif signal[1] == "component_added" or signal[1] == "component_removed" then
        if signal[3] == "filesystem" then
            menu = createMenu()
            printMenu(menu, i)
        end
    end
end