local invoke = component.invoke

uloader.boot = {
    methods = {}
}

function uloader.boot.boot(initData)
    computer.getBootAddress = function() return initData.fs end
    computer.setBootAddress = function(addr) end

    local buffer = uloader.fs.readFile(initData.fs, initData.path)
    local init = load(buffer)
    init()
end

function uloader.boot.detectBoot(fs)
    local bootMethods = {}

    for _, getBootMethods in pairs(uloader.boot.methods) do
        local methods = getBootMethods(fs)
        if methods ~= nil then
            for _, method in pairs(methods) do
                table.insert(bootMethods, method)
            end
        end
    end

    return bootMethods
end