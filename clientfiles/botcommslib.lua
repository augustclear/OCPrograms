--Robot Wireless Communication

local ftp = require("ftplib")

local function handle_modem_message(port,message)
    if port == ftp.port then
        ftp.get(message)
    end
end