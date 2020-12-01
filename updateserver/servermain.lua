--Update Server Main Program

local component = require("component")
local event = require("event")
local serv = require("serverlib")

local running = true

--Main Program

serv.open()

while running do
    local _,receiver,sender,_,_,header,message = event.pull("modem_message",nil,nil,serv.ftp_port,...)
    serv.pull()
    if header == "request" then
        if not serv.is_registered(sender) then
            serv.create_manifest(sender)
        end
        if not serv.send_file(sender,message) then
            serv.send_error(sender,"File does not exist")
        else
            if serv.await_ack() then 
                serv.add_file_to_manifest(sender,message)
                print("Added "..message.." to client manifest "..sender)
            end
        end
    elseif header == "update" then

    end
end

serv.close()

print("Update Server Loop Stopped. Reboot Now")