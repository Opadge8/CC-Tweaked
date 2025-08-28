-- Factory Tracker for Advanced Pocket Computer
-- Listens for Rednet broadcasts from the factory

local monitorWidth, monitorHeight = term.getSize()
local factoryFrequency = 123 -- change this to your factory broadcast frequency
local refreshRate = 0.5 -- seconds

-- Table to store current resource levels
local resources = {}

-- Helper: draw a progress bar
local function drawBar(x, y, w, pct)
    local filled = math.floor(pct * w)
    term.setCursorPos(x, y)
    term.write("[")
    term.setBackgroundColor(colors.green)
    term.write(string.rep(" ", filled))
    term.setBackgroundColor(colors.gray)
    term.write(string.rep(" ", w - filled))
    term.setBackgroundColor(colors.black)
    term.write("]")
end

-- Draw header
local function drawHeader()
    term.setCursorPos(1,1)
    term.setTextColor(colors.yellow)
    term.clearLine()
    term.write("Factory Tracker — Press Q to exit")
end

-- Draw all resources
local function drawResources()
    local y = 3
    for name, pct in pairs(resources) do
        term.setCursorPos(1, y)
        term.setTextColor(colors.white)
        term.clearLine()
        term.write(name..": ")
        drawBar(20, y, monitorWidth-25, pct)
        y = y + 1
        if y > monitorHeight then break end -- don't overflow screen
    end
end

-- Open built-in wireless modem
rednet.open("back") -- built-in modem works automatically on pocket computers

-- Main loop
term.clear()
drawHeader()
drawResources()

while true do
    local timer = os.startTimer(refreshRate)
    local event, param1, param2, param3 = os.pullEvent()
    
    if event == "key" and param1 == keys.q then
        break
    elseif event == "rednet_message" then
        local senderID, message, protocol = param1, param2, param3
        if protocol == factoryFrequency then
            -- Expecting {name="Iron Plates", level=0.0-1.0}
            if type(message) == "table" and message.name and message.level then
                resources[message.name] = message.level
                drawResources()
            end
        end
    elseif event == "timer" and param1 == timer then
        -- Just refresh the display
        drawResources()
    end
end

-- Cleanup
term.clear()