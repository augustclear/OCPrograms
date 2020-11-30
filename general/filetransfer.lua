robotcomms.lua
modem.open(port)

local args = {...} --{send/receive,filename}
if args[1] == nil then error("Provide function of program in first arg, send or receive.") end

if args[1] == "send" then
  if args[2] == nil then error("Provide filesystem path to file to send.") end
  print("Preparing to send file "..args[2])
  local fileSendInitial = assert(io.open(args[2],"r"),"Failed to open existing file to send.")
  local sendString = fileSendInitial:read("*a") --reads the entire file into one gigantic string
  modem.broadcast(port,tostring(sendString)) --broadcasts the string on the set port.
  print("File sent. Ensure that another computer is running gft receive. Resend if necessary.")
  fileSendInitial:close()
end

if args[1] == "receive" then
  if args[2] == nil then error("Provide filesystem path to file to create on receive.") end
  print("Preparing to receive file over network into "..args[2])
  local _,_,sender,_,_,receivedFileData = require("event").pull("modem")
  print("Got data from computer "..sender..".")
  local fileReceiveFinal = assert(io.open(args[2],"w"),"Failed to open new file to receive into.")
  fileReceiveFinal:write(receivedFileData) --writes the receivedFileData to file.
  fileReceiveFinal:flush() --ensure all data is written and saved.
  fileReceiveFinal:close()
  print("Done.")
end

modem.close(port)