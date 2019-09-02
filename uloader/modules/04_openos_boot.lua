local invoke = component.invoke

table.insert(uloader.boot.methods, function(fs)
    if invoke(fs, "exists", "/init.lua") then
        return {
            {
                fs = fs, path = "/init.lua", callback = uloader.boot.boot
            }
        }
    end
end)