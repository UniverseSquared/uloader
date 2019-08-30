local invoke = component.invoke
local gpu = component.proxy(component.list("gpu")())
local screen = component.list("screen")()
local eeprom = component.proxy(component.list("eeprom")())
local fs = eeprom.getData()

gpu.bind(screen)

local handle, reason = invoke(fs, "open", "/uloader/init.lua")
if not handle then
    error(reason)
end

local buffer = ""
repeat
    local data = invoke(fs, "read", handle, math.huge)
    buffer = buffer .. (data or "")
until data == nil

invoke(fs, "close", handle)

local init, err = load(buffer, "=init")
if init then
    init()
else
    error(err)
end