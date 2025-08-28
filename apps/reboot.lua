-- /personalOS/apps/reboot.lua
term.clear()
term.setCursorPos(1,1)
print("Are you sure you want to reboot?")

-- Draw buttons
local w, h = term.getSize()
local yesX, yesY = math.floor(w/4), math.floor(h/2)
local noX, noY = math.floor(3*w/4)-3, math.floor(h/2)

term.setCursorPos(yesX, yesY)
term.write("[ Yes ]")
term.setCursorPos(noX, noY)
term.write("[ No ]")

-- Wait for click
while true do
    local event, button, x, y = os.pullEvent("mouse_click")
    if y == yesY and x >= yesX and x <= yesX+6 then
        term.clear(); term.setCursorPos(1,1)
        print("Rebooting PersonalOS...")
        sleep(1)
        os.reboot()
    elseif y == noY and x >= noX and x <= noX+5 then
        return  -- exit app back to home screen
    end
end