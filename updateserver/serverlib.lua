local component = require("component")
local event = require("event")
local m = component.modem

local ftp_port = 20
local manifest_folder = "/usr/manifests/"
local feed_folder = "/usr/feed/"
local client_lib_folder = "/usr/lib/"
local client_cfg_folder = "/usr/lib/"
local client_ex_folder =

--[[FILE SYSTEM FUNCTIONS]]

local function find_file(filename)
    local serverpath, clientpath
    serverpath = manifest_folder..filename
    if not filesystem.exists(serverpath) then
        return
    end
    if string.find(filename,"lib") ~= nil then
        clientpath = client_lib_folder..filename
    elseif string.find(filename,".cfg") ~= nil then
        clientpath = client_cfg_folder..filename
    else
        clientpath = client_ex_folder..filename
    end
    return serverpath,clientpath
end

--Checks if client manifest exists
local function is_registered(client)
    return filesystem.exists(manifest_folder..client..".lua")
end

--Delete client manifest
local function rmv_file_from_manifest(client,filename)
    --TODO:Implement remove
end

--Read client manifest
local function read_manifest(client)
    local rfile = assert(io.open(manifest_folder..client..".lua","r"),"Failed to create manifest file.")
    local contents = rfile:read("*a") --reads the entire file into one gigantic string
    rfile:close()
    return serialization.unserialize(contents)
end

local function write_manifest(client,manifest_table)
    local data = serialization.serialize(manifest_table)
    local wfile = assert(io.open(manifest_folder..client..".lua","w"),"Failed to write to manifest file.")
    wfile:write(data) --writes the receivedFileData to file.
    wfile:flush() --ensure all data is written and saved. 
    wfile:close()    
end

--Create client manifest
local function create_manifest(client)
    write_manifest(client,{})
end

--Add file to client manifest
local function add_file_to_manifest(client,filename)
    local manifest = read_manifest(client)
    table.insert(manifest,filename)
    write_manifest(client,filename)
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
    local _,_,_,_,header,message = event.pull("modem_message",nil,client,ftp_port,...)
    if header == "ack" then
        return true
    elseif header == "error" then
        print(message)
    else
        print("Unknown message instead of ack")
    end
    return false
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