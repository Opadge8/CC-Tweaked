-- /personalOS/init.lua — PersonalOS core

local cfg = dofile("/personalOS/config.lua")
local theme = cfg.theme or { bg=colors.black, fg=colors.white, acc=colors.lightBlue, warn=colors.red }

-- Theme setup
local function setTheme()
    if term.isColor() then
        term.setBackgroundColor(theme.bg)
        term.setTextColor(theme.fg)
    else
        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
    end
    term.clear()
    term.setCursorPos(1,1)
end

-- Draw a box
local function box(x,y,w,h,title)
    local oldTx, oldBg = term.getTextColor(), term.getBackgroundColor()
    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.fg)
    for j=0,h-1 do
        term.setCursorPos(x,y+j)
        term.clearLine()
        term.setCursorPos(x,y+j)
        term.write(string.rep(" ", w))
    end
    if title then
        term.setCursorPos(x+2,y)
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
    term.setCursorPos(x,y)
    term.write(s)
end

-- Run an app safely using dofile
local function runApp(id)
    if id=="__shutdown" then os.shutdown(); return end
    if id=="__reboot" then os.reboot(); return end

    local path = "/personalOS/apps/"..id..".lua"
    if not fs.exists(path) then
        term.setTextColor(colors.red)
        print("App not found: "..id)
        print("\nPress any key to return...")
        os.pullEvent("key")
        return
    end

    term.setBackgroundColor(theme.bg)
    term.setTextColor(theme.fg)
    term.clear()
    term.setCursorPos(1,1)

    local ok, err = pcall(dofile, path)
    if not ok then
        term.setTextColor(colors.red)
        print("App crashed: "..id)
        print(err)
        print("\nPress any key to return...")
        os.pullEvent("key")
    end
end

-- Menu apps
local apps = {
    { name="Factory Tracker", id="factory" },
    { name="Files",   id="files"   },
    { name="Notes",   id="notes"   },
    { name="Clock",   id="clock"   },
    { name="Run",     id="run"     },
    { name="Settings",id="settings"},
    { name="Shutdown",id="__shutdown" },
    { name="Reboot",  id="__reboot" },
}

-- Home menu
local function home()
    setTheme()
    local w,h = term.getSize()
    local sel = 1
    while true do
        setTheme()
        box(1,1,w,h,"PersonalOS — "..(cfg.user or "player"))
        center(3, "Use ↑/↓, Enter to open, Q to quit to shell")
        for i,app in ipairs(apps) do
            term.setCursorPos(4, 5+i)
            if i==sel then term.setTextColor(theme.acc) else term.setTextColor(theme.fg) end
            term.write((i==sel and "> " or "  ")..app.name)
        end
        local e,k = os.pullEvent("key")
        if k==keys.up then sel = math.max(1, sel-1)
        elseif k==keys.down then sel = math.min(#apps, sel+1)
        elseif k==keys.enter then runApp(apps[sel].id)
        elseif k==keys.q then break
        end
    end
end

-- Boot sequence
setTheme()
home()
term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()
term.setCursorPos(1,1)
print("Exited PersonalOS. Type `reboot` to boot OS again or `shell.run('/personalOS/init.lua')`.")
