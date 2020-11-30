--FTP Library

local component = require("component")
local io = require("io")
if not component.isAvailable("modem") then error("A network card is required for this program. Please install.") end
local modem = component.modem

local ftp = {}

ftp.port = 20 --port to use for transfer and getting

local fileinfo = {path,contents}

function ftp.open()
    modem.open(ftp.port)
end

function ftp.close()
    modem.close(port)
end

function ftp.send(file,installpath)
    local data
    local rfile = assert(io.open(file,"r"),"Failed to open existing file to send.")
    fileinfo.contents = rfile:read("*a") --reads the entire file into one gigantic string
    fileinfo.path = installpath
    data = serialization.serialize(fileinfo)
    modem.broadcast(port,) --broadcasts the string on the set port.
    rfile:close()    
end

function ftp.get(message)
    print("Got data from computer "..sender..".")
    fileinfo = serialization.unserialize(message)
    local wfile = assert(io.open(fileinfo.path,"w"),"Failed to open new file to receive into.")
    wfile:write(fileinfo.contents) --writes the receivedFileData to file.
    wfile:flush() --ensure all data is written and saved.
    wfile:close()
end

return ftp