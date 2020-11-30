local component = require("component")
local event = require("event")
local m = component.modem

local ftp_port = 20

--[[FILE SYSTEM FUNCTIONS]]

local function find_file(file)
    local serverpath,clientpath


end

--Checks if client manifest exists
local function is_registered(client)

end

--Delete client manifest
local function unregister(client)

end

--Create client manifest
local function create_client_manifest(client)

end

--Add file to client manifest
local function add_file_to_manifest(client,file)

end

--Read client manifest
local function read_manifest(client)

end

--[[INTERNET FUNCTIONS]]

--Update from OPPM
local function pull()
    return shell.execute("oppm update all") 
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
local function send_error(client,message)
    print("Sending error to client")
    m.send(client,ftp_port,"error",message)
end

--Send acknowledgement message
local function send_ack(client)
    print("Sending acknowledgement to client")
    m.send(client,ftp_port,"ack")    
end

--Waits for acknowledgement message
local function await_ack(client)
    print("Waiting for acknowledgement from client")
    event.pull("modem_message",nil,client,ftp_port,"ack",...)
end

--Send one file to client
local function send_file(client,file)
    local serverpath,clientpath = find_file(file)
    if serverpath == nil then
        return false
    end
    local rfile = assert(io.open(serverpath,"r"),"Failed to open existing file to send.")
    local contents = rfile:read("*a")
    m.send(client,ftp_port,"file",clientpath,contents)
    rfile:close() 
    return true
end

--Send all files in manifest to client
local function update_client(client)
    local list = read_manifest(client)
    for key, value in pairs(list) do
        send_file(client,file)
    end
end