local invoke = component.invoke
local gpu = component.proxy(component.list("gpu")())
local w, h = gpu.getResolution()

function createMenu()
    local menu = {}

    for fs in component.list("filesystem") do
        local bootMethods = detectBoot(fs)
        for _, method in pairs(bootMethods) do
            table.insert(menu, method)
        end
    end

    table.insert(menu, {
        text = "Internet Boot", callback = function()
            internetBoot()
        end
    })
    
    table.insert(menu, {
        text = "Update uloader", callback = selfUpdate
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

    return menu
end

function printMenu(menu, i)
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