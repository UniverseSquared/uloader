local invoke = component.invoke

function readFile(fs, path)
    local handle, reason = invoke(fs, "open", path)
    if not handle then
        return nil, reason
    end

    local buffer = ""
    repeat
        local data = invoke(fs, "read", handle, math.huge)
        buffer = buffer .. (data or "")
    until data == nil

    invoke(fs, "close", handle)

    return buffer
end

function writeFile(fs, path, data)
    local handle, reason = invoke(fs, "open", path, "w")
    if not handle then
        return nil, reason
    end

    local success = invoke(fs, "write", handle, data)

    invoke(fs, "close", handle)

    return success
end