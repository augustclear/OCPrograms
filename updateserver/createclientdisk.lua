--Loads the files for setting up an update client to a floppy disk

local component = require("component")
fsc = component.filesystem

args = (...)

local setup_files_folder = /usr/setup/
local disk_path = args[1]

local filelist = fsc.list(setup_files_folder)

for key, value in pairs(filelist) do
    filesystem.copy(setup_files_folder .. value,disk_path .. value)
end