local botnav = require("robotnavlib")

local x,y,z = botnav.get_position()

botnav.move(x,y,z)