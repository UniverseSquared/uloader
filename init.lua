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

local function waitForKey()
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

    gpu.setResolution(config.resolution[1], config.resolution[2])

    for moduleName, path in pairs(config.modules) do
        _G[moduleName] = load(readFile(fs, path), "=" .. path)()
    end

    return config
end

local config = loadConfig()

initFs()

local menu = {}

for fs in component.list("filesystem") do
    local bootMethods = detectBoot(fs)
    for _, method in pairs(bootMethods) do
        table.insert(menu, method)
    end
end

if #menu == 0 then
    error("no bootable medium found")
end

if #menu == 1 and not config.alwaysMenu then
    boot(menu[1])
end

table.insert(menu, {
    text = "Internet Boot", callback = function()
        internetBoot()
    end
})

table.insert(menu, {
    text = "Reboot", callback = function()
        computer.shutdown(true)
    end
})

table.insert(menu, {
    text = "Shutdown", callback = function()
        computer.shutdown()
    end
})

local function printMenu(i)
    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")

    for k, init in pairs(menu) do
        if k == i then
            gpu.setBackground(0xFFFFFF)
            gpu.setForeground(0x000000)
        else
            gpu.setBackground(0x000000)
            gpu.setForeground(0xFFFFFF)
        end

        if init.text ~= nil then
            gpu.set(1, k, init.text)
        else
            local label = invoke(init.fs, "getLabel")
            local str = init.path .. " (" .. init.fs:sub(1, 3)
            if label then
                str = str .. ", " .. label
            end
            str = str .. ")"

            gpu.set(1, k, str)
        end
    end
end

local i = 1
printMenu(i)
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

        printMenu(i)
    end
end