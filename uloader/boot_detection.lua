local invoke = component.invoke

local function boot(initData)
    computer.getBootAddress = function() return initData.fs end
    computer.setBootAddress = function(addr) end

    local buffer = readFile(initData.fs, initData.path)
    local init = load(buffer)
    init()
end

return function(fs)
    local bootMethods = {}

    if invoke(fs, "isDirectory", "/boot/kernel") then
        for k, file in pairs(invoke(fs, "list", "/boot/kernel")) do
            local path = "/boot/kernel/" .. file
            if not invoke(fs, "isDirectory", path) and k ~= "n" then
                table.insert(bootMethods, {
                    fs = fs, path = path, callback = boot
                })
            end
        end
    end
    
    if invoke(fs, "exists", "/init.lua") then
        table.insert(bootMethods, {
            fs = fs, path = "/init.lua", callback = boot
        })
    end

    return bootMethods
end