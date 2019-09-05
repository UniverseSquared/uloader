local invoke = component.invoke
local eeprom = component.proxy(component.list("eeprom")())
local gpu = component.proxy(component.list("gpu")())

uloader.config = {}

local function serializeTable(table, indent)
	local buffer = "{\n"
	
	indent = indent or 4
	
	for k, v in pairs(table) do
		buffer = buffer .. string.rep(" ", indent)
		
		if type(k) == "string" then
			buffer = buffer .. k .. " = "
		else
			buffer = buffer
		end
		
		if type(v) == "table" then
			buffer = buffer .. serializeTable(v, indent + 4)
		elseif type(v) == "string" then
			buffer = buffer .. '"' .. v .. '"'
		elseif type(v) == "number" then
			buffer = buffer .. v
		elseif type(v) == "boolean" then
			buffer = buffer .. tostring(v)
		end
		
		buffer = buffer .. ",\n"
	end
	
	buffer = buffer:sub(0, -3) .. "\n" .. string.rep(" ", indent - 4) .. "}"
	
	return buffer
end

function uloader.config.loadConfig()
    local fs = eeprom.getData()
    
    local defaultConfig = {
        alwaysMenu = true,
        resolution = "max",
        customModulePath = nil,
        backgroundColor = 0x000000,
        foregroundColor = 0xFFFFFF,
        selectedBackgroundColor = 0xFFFFFF,
        selectedForegroundColor = 0x000000
    }

    if not invoke(fs, "exists", "/uloader/config.lua") then
        uloader.fs.writeFile(fs, "/uloader/config.lua", "return " .. serializeTable(defaultConfig))
        return defaultConfig
    end

    local configData, reason = uloader.fs.readFile(fs, "/uloader/config.lua")

    if not configData then
        return nil, reason
    end

    local config = load(configData, "=uloader_config")()

    for k, v in pairs(defaultConfig) do
        if config[k] == nil then
            config[k] = v
        end
    end

    uloader.config.config = config

    return config
end

function uloader.config.applyConfig(config)
    local resolution = config.resolution
    if resolution == "max" then
        resolution = { gpu.maxResolution() }
    end

    gpu.setResolution(resolution[1], resolution[2])
end

setmetatable(uloader.config, {
    __index = function(table, key, value)
        return uloader.config.config[key]
    end
})