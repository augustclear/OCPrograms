--Update Server Main Program

local component = require("component")
local event = require("event")
local serv = require("serverlib")

local running = true

--Main Program

serv.open()

while running do
    local _,receiver,sender,_,_,header,message = event.pull("modem_message",nil,nil,serv.ftp_port,...)
    pull()
    if serv.is_registered(sender) then
    end
end

serv.close()

print("Update Server Loop Stopped. Reboot Now")