-- == I2C Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--
-- History:
-- 2018/02/26: 0.0.1: first version, no idea if it works, coded based on documentation

local I2C = require('periphery').I2C

i2c = {
   DEV_PREFIX = I2C_DEV_PREFIX or "/dev/i2c-",
   --HW0 = "/dev/i2c-0",   -- these will be autoset
   --HW1 = "/dev/i2c-1", 
   --...
   TRANSMITTER = 0,
   RECEIVER = 1
}

-- we probe the i2c devices and dynamically set i2c.HW[0..x] = i2c.DEV_PREFIX..d (e.g. i2c.HW0 = "/dev/i2c-0")
local i = 0
local o = ""
for d=0,7 do 
   if not file.exists(i2c.DEV_PREFIX..d) then
      break
   end
   o = o .. (i>0 and " " or "") .. i2c.DEV_PREFIX .. i
   i2c['HW'..i] = i2c.DEV_PREFIX .. i
   i = i+1
   i2c._count = i
end
if i>0 then
   _syslog.print(_syslog.INFO,"i2c: "..i.." interface(s) found: "..o)
else
   _syslog.print(_syslog.INFO,"i2c: no interface found")
end

i2c.setup = function(id,sda,scl,sp)   -- Initialize the IC module.
   i2c._i2c[id] = { }
   i2c._i2c[id].handle = I2C(id)
   _syslog.print(_syslog.INFO,"i2c "..id.." setup")
   -- sda and scl are ignored, we /dev/i2c-* is hardwired (for now)
end

i2c.address = function(id,adr,dir)    --  Setup IC address and read/write mode for the next transfer.
   i2c._i2c[id].adr = adr
   i2c._i2c[id].dir = dir
   _syslog.print(_syslog.INFO,"i2c "..id.." address "..adr.." "..dir)
end

i2c.start = function(id)              -- Send an IC start condition.
   -- ???
end

i2c.stop = function(id)               --  Send an IC stop condition.
   i2c._i2c[id].handle:transfer(id,{ 0x00, flags = I2C.I2C_M_STOP })
end

i2c.read = function(id,len)           --  Read data for variable number of bytes.
   local msg = { }
   for i=1, len do               -- fill place holder(s)
      table.insert(msg,0x00)
   end
   table.insert(msg,'flags',I2C.I2C_M_RD);
   i2c._i2c[id].handle:write({ i2c._i2c[id].adr }, tbl)
   return msg
end

i2c.write = function(...)             -- Write data to IC bus.
   local id = table.remove(arg,1)
   -- arg rest of the data
   table.foreach(arg,function(k,v) 
      i2c._ih[id].handle:write({ i2c_i2c[id].adr }, v)
   end)
end

table.insert(node.modules,"i2c")

return i2c

