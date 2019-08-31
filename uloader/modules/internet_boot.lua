uloader.internet = {}

function uloader.internet.internetBoot()
    local gpu = component.proxy(component.list("gpu")())
    local w, h = gpu.getResolution()
    local internet = component.list("internet")()

    gpu.setBackground(0x000000)
    gpu.setForeground(0xFFFFFF)
    gpu.fill(1, 1, w, h, " ")

    if not internet then
        gpu.set(1, 1, "Internet booting requires an Internet Card.")
        gpu.set(1, 2, "Press any key to continue.")
        uloader.waitForKey()
        return
    end

    internet = component.proxy(internet)

    gpu.set(1, 1, "Paste (Shift+Insert) the URL to boot from.")

    local url = nil
    while url == nil do
        local signal = { computer.pullSignal() }
        if signal[1] == "clipboard" then
            url = signal[3]
        end
    end

    local handle = internet.request(url)
    handle.finishConnect()

    local buffer = ""
    repeat
        local data = handle.read(math.huge)
        buffer = buffer .. (data or "")
    until data == nil

    local init = load(buffer, "=internet_init")
    init()
end