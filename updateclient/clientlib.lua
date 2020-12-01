local component = require("component")
local event = require("event")
local m = component.modem

local ftp_port = 20

--[[FILESYSTEM FUNCTIONS]]

local function write_file(fpath,fcontents)
    local wfile = assert(io.open(fpath,"w"),"Failed to open new file to receive into.")
    wfile:write(fcontents) --writes the receivedFileData to file.
    wfile:flush() --ensure all data is written and saved.
    wfile:close()
end

--[[MODEM FUNCTIONS]]

--Open FTP port
local function open()
    m.open(ftp_port)
end

--Close FTP port
local function close()
    m.close(ftp_port)
end

--Send error message
local function send_error(server,message)
    print("Sending error to server")
    m.send(server,ftp_port,"error",message)
end

--Send acknowledgement message
local function send_ack(server)
    print("Sending acknowledgement to server")
    m.send(server,ftp_port,"ack")
end

--Waits for acknowledgement message
local function await_ack(server)
    print("Waiting for acknowledgement from client")
    local _,_,_,_,header,message = event.pull("modem_message",nil,server,ftp_port,...)
    if header == "ack" then
        return true
    elseif header == "error" then
        print(message)
    else
        print("Unknown message instead of ack")
    end
    return false
end

--Broadcast file register request
local function request_file(file)
    m.broadcast(ftp_port,"request",file)
end

--Broadcast file unregister request
local function unrequest_file(file)
    m.broadcast(ftp_port,"unrequest",file)
end

--Waits for files to be sent from server
local function await_files(server)
    local header,path,contents
    while header ~= "ack" and header ~= "error" do
        _, _, _, _, _, header,path,contents = event.pull("modem_message",nil,server,ftp_port,...)
        if header == "file" then
            print("Writing " .. path .. " to disk")
            write_file(path,contents)
        end
    end
end

--Broadcast file update request
local function request_update()
    m.broadcast(ftp_port,"update")
end

