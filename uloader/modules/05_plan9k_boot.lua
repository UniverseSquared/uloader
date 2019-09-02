local invoke = component.invoke

table.insert(uloader.boot.methods, function(fs)
    local bootMethods = {}

    if invoke(fs, "isDirectory", "/boot/kernel") then
        for k, file in pairs(invoke(fs, "list", "/boot/kernel")) do
            local path = "/boot/kernel/" .. file
            if not invoke(fs, "isDirectory", path) and k ~= "n" then
                table.insert(bootMethods, {
                    fs = fs, path = path, callback = uloader.boot.boot
                })
            end
        end
    end

    return bootMethods
end)