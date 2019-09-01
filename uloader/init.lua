local invoke = component.invoke
local eeprom = component.proxy(component.list("eeprom")())
local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

uloader = {
    errors = {}
}

function uloader.error(message)
    table.insert(uloader.errors, message)
end

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

function uloader.waitForKey()
    while true do
        local signal = { computer.pullSignal() }
        if signal[1] == "key_down" then
            break
        end
    end
end

local function loadModules(path, isCustomModules)
    local fs = eeprom.getData()
    if not invoke(fs, "isDirectory", path) then
        if isCustomModules then
            uloader.error("Warning: customModulePath is not a directory.")
            return
        else
            -- TODO: Attempt to load init.lua instead of dying here.
            error("uloader: Failed to load core modules!")
        end
    end

    for k, filename in pairs(invoke(fs, "list", path)) do
        if k ~= "n" then
            local path = path .. "/" .. filename
            local module, err = load(readFile(fs, path), "=" .. filename)
            if module then
                module()
            else
                error(err)
            end
        end
    end
end

loadModules("/uloader/modules", false)

local config = uloader.config.loadConfig()
uloader.config.config = config
uloader.config.applyConfig(config)

local totalBootMethods = uloader.menu.createMenu()

if config.customModulePath then
    loadModules(config.customModulePath, true)
end

if totalBootMethods == 1 and not config.alwaysMenu then
    uloader.boot.boot(uloader.menu.menu[1])
end

local i = 1
uloader.menu.printMenu(i)
while true do
    local signal = { computer.pullSignal() }
    if signal[1] == "key_down" then
        local code = signal[4]
        if code == 200 then
            i = i - 1
        elseif code == 208 then
            i = i + 1
        elseif code == 28 then
            uloader.menu.menu[i].callback(uloader.menu.menu[i])
        end

        if i > #uloader.menu.menu then
            i = 1
        elseif i < 1 then
            i = #uloader.menu.menu
        end

        uloader.menu.printMenu(i)
    elseif signal[1] == "component_added" or signal[1] == "component_removed" then
        if signal[3] == "filesystem" then
            uloader.menu.createMenu()
            uloader.menu.printMenu(i)
        end
    end
end