-- /personalOS/init.lua — PersonalOS core (touchscreen version)

-- Load config
local cfg = dofile("/personalOS/config.lua")
local theme = cfg.theme

-- Set terminal theme
local function setTheme()
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.fg)
    term.clear()
    term.setCursorPos(1,1)
end

-- Fill the screen with a simple background pattern
local function drawBackground()
    local w, h = term.getSize()
    for y = 1, h do
        term.setCursorPos(1, y)
        for x = 1, w do
            -- Example: alternating colors for a simple pattern
            if (x + y) % 2 == 0 then
                term.setBackgroundColor(colors.lightGray)
            else
                term.setBackgroundColor(colors.gray)
            end
            term.write(" ") -- write a space with background color
        end
    end
    -- Reset text color
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.fg)
end


-- Draw a simple box
local function box(x, y, w, h, title)
    local oldTx, oldBg = term.getTextColor(), term.getBackgroundColor()
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.fg)
    for j=0,h-1 do
        term.setCursorPos(x, y+j)
        term.clearLine()
        term.setCursorPos(x, y+j)
        term.write(string.rep(" ", w))
    end
    if title then
        term.setCursorPos(x+2, y)
        term.setTextColor(theme.acc)
        term.write(title)
        term.setTextColor(theme.fg)
    end
    term.setBackgroundColor(oldBg)
    term.setTextColor(oldTx)
end

-- Center text
local function center(y, s)
    local w,_ = term.getSize()
    local x = math.floor((w-#s)/2)+1
    term.setCursorPos(x, y)
    term.write(s)
end

-- Define apps
local apps = {
    { name = "Files", id = "files" },
    { name = "Clock", id = "clock" },
    { name = "Notes", id = "notes" }
    { name = "Restart", id = "reboot"}
    { name = "Shutdown", id = "shutdown"}
}

-- Run app
local function runApp(app)
    local path = "/personalOS/apps/"..app.id..".lua"
    if fs.exists(path) then
        term.setBackgroundColor(theme.bg)
        term.setTextColor(theme.fg)
        term.clear()
        term.setCursorPos(1,1)
        local ok, err = pcall(dofile, path)
        if not ok then
            print("App crashed: "..app.id)
            print(err)
            print("\nPress any key to return...")
            os.pullEvent("key")
        end
    else
        print("App file not found: "..app.id)
        sleep(1.5)
    end
end

-- Get app positions for clickable menu
local function drawApps()
    local startY = 6
    local positions = {}
    for i, app in ipairs(apps) do
        local y = startY + i
        term.setCursorPos(4, y)
        term.setTextColor(theme.fg)
        term.write("  "..app.name.."  ")
        positions[i] = { x1 = 4, x2 = 4 + #app.name + 2, y1 = y, y2 = y }
    end
    return positions
end

-- Home screen / clickable menu
local function home()
    local w, h = term.getSize()
    while true do
        drawBackground() -- <- draw the background first
        center(1, "Start Menu")
        center(3, "Tap an app to open, or Q to quit")

        local appPos = drawApps()

        while true do
            local event, param1, param2 = os.pullEvent()
            if event == "mouse_click" then
                local x, y = param2, select(3, param1, param2)
                for i, pos in ipairs(appPos) do
                    if x >= pos.x1 and x <= pos.x2 and y >= pos.y1 and y <= pos.y2 then
                        runApp(apps[i])
                        break
                    end
                end
            elseif event == "key" and param1 == keys.q then
                return
            end
        end
    end
end


-- Boot
setTheme()
home()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Exited PersonalOS. Reboot to start again.")
