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
    local buffer = uloader.fs.readFile(initData.fs, initData.path)
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

uloader = {}

local fs = eeprom.getData()
for k, filename in pairs(invoke(fs, "list", "/uloader/modules")) do
    if k ~= "n" then
        local path = "/uloader/modules/" .. filename
        local module, err = load(readFile(fs, path), "=" .. filename)
        if module then
            module()
        else
            error(err)
        end
    end
end

local config = uloader.config.loadConfig()
uloader.config.config = config
uloader.config.applyConfig(config)

local menu = uloader.menu.createMenu()

if #menu == 0 then
    error("no bootable medium found")
end

if #menu == 1 and not config.alwaysMenu then
    boot(menu[1])
end

local i = 1
uloader.menu.printMenu(menu, i)
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

        uloader.menu.printMenu(menu, i)
    elseif signal[1] == "component_added" or signal[1] == "component_removed" then
        if signal[3] == "filesystem" then
            menu = uloader.menu.createMenu()
            uloader.menu.printMenu(menu, i)
        end
    end
end