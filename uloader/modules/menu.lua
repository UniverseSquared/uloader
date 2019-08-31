local invoke = component.invoke
local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

uloader.menu = {}

function uloader.menu.createMenu()
    local menu = {}
    local totalBootMethods = 0

    for fs in component.list("filesystem") do
        local bootMethods = uloader.boot.detectBoot(fs)
        for _, method in pairs(bootMethods) do
            table.insert(menu, method)
        end

        totalBootMethods = totalBootMethods + #bootMethods
    end

    table.insert(menu, {
        text = "Internet Boot", callback = uloader.internet.internetBoot
    })
    
    table.insert(menu, {
        text = "Update uloader", callback = uloader.updater.selfUpdate
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

    uloader.menu.menu = menu

    return totalBootMethods
end

function uloader.menu.printMenu(i)
    gpu.setBackground(uloader.config.backgroundColor)
    gpu.setForeground(uloader.config.foregroundColor)
    gpu.fill(1, 1, w, h, " ")

    for k, init in pairs(uloader.menu.menu) do
        if k == i then
            gpu.setBackground(uloader.config.selectedBackgroundColor)
            gpu.setForeground(uloader.config.selectedForegroundColor)
        else
            gpu.setBackground(uloader.config.backgroundColor)
            gpu.setForeground(uloader.config.foregroundColor)
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