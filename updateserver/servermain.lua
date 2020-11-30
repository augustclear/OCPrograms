--Update Server Main Program

local event = require("event")

local running = true

--Update from OPPM

if shell.execute("oppm update all") 

while running do
    event.pull()
end

print("Update Server Loop Stopped. Reboot Now")