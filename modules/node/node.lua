-- == Node Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--
-- Notes:
--    - _sysinfo.cpu_max_mhz and _sysinfo.cpu_max_mhz contain range for /usr/bin/cpufreq-set (Armbian)
--    - cpufreq-info outputs detailed possible setttings for cpufreq-set
--
-- History:
-- 2018/02/23: 0.0.1: first version

node = { 
   _VERSION = '0.0.2',
   _output = print,
   modules = { }
}

local _getmac = function()
   if not node._mac then
      local f = io.popen('ifconfig')
      local t = f:read("*all")
      f:close()
      node._mac = t:match("HWaddr ([%:%x]*)")
   end
   return node._mac
end

node.bootreason = function()     -- Returns the boot reason and extended reset info.
   return 0,0
end

node.chipid = function()         --  Returns the chip ID (based on last three bytes of MAC address)
   local m = _getmac()
   local id0,id1,id2 = m:match("(%x%x):(%x%x):(%x%x)$")
   return tonumber(id0..id1..id2,16)
end

node.compile = function(fn)      -- Compiles a Lua text file into Lua bytecode, and saves it as .
   if file.exists(fn) then
      local f = file.open(fn,"r")
      local chunk = loadstring(f:read("*all"))
      f:close()
      local fnn = fn:gsub(".lua$",".lc")
      if fnn ~= fn then
         f = file.open(fnn,"w")
         f:write(string.dump(chunk))
         f:close()
      end
   end
end

node.dsleep = function()         --  Enters deep sleep mode, wakes up when timed out.
   _syslog.print(_syslog.ERROR,"node.dsleep() not yet implemented")
end

node.flashid = function()        -- Returns the flash chip ID.
   -- check /dev/disk/by-uuid and blkid <dev> to lookup UUID of disk
   local f = io.popen("df -k .")
   _ = f:read("*line")
   _ = f:read("*line")  -- get mount point
   f:close()
   local m = _:match("(%S+)")
   f = io.popen("lsblk --output UUID "..m)    -- lookup UUID of disk mounted at '.'
   _ = f:read("*line")   -- 'UUID'
   _ = f:read("*line")
   f:close()
   return _:match("(%S+)")
end

node.flashsize = function()      -- Returns the flash chip size in bytes.
   local remain, used, total = file.fsinfo()
   return total
end

node.heap = function()           -- Returns the current available heap size in bytes.
   local f = io.open('/proc/meminfo')
   local t = f:read("*all")
   f:close()
   local h = t:match("MemFree: +(%d+)")
   return h and tonumber(h)*1024 or 0
end

node.info = function()           -- Returns majorVer, minorVer, devVer, chipid, flashid, flashsize, flashmode, flashspeed and architecture
   local mav,miv,devv = node._VERSION:match("(%d+).(%d+).(%d)")
   return mav, miv, devv, node.chipid(), node.flashid(), 0, 0, 0, 'linux'
end

node.input = function(s)         -- Submits a string to the Lua interpreter.
   loadstring(s)
end

node.output = function(f)        -- Redirects the Lua interpreter output to a callback function.
   node._output = f
end

node.restart = function()        -- Restarts the system (reboot)
   os.execute("reboot")          -- likely will fail as we aren't root (very unlikely that we are)
end

node.restore = function()        -- Restore defaults
   _syslog.print(_syslog.ERROR,"node.restore() is not implemented yet")
end

node.setcpufreq = function(f)     -- Change the working CPU Frequency.
   if file.exists("/usr/bin/cpufreq-set") then
      f = tonumber(f)
      local mi = tonumber(_sysinfo.cpu_min_mhz)
      local mx = tonumber(_sysinfo.cpu_max_mhz)
      if f >= mi and f <= mx then
         -- we need to check valid settings (within the range)
         os.execute("/usr/bin/cpufreq-set "..f.."MHz")
      else 
         _syslog.print(_syslog.ERROR,"node.setcpufreq(): range of "..mi.."-"..mx.." is supported: "..f.." out of range")
      end
   else 
      _syslog.print(_syslog.ERROR,"this platform does not support node.setcpufreq(), check /usr/bin/cpufreq-set")
   end
end

node.sleep = function()          -- Put NodeMCU in light sleep mode to reduce current consumption.
   _syslog.print(_syslog.ERROR,"node.dsleep() not yet implemented")
end

node.stripdebug = function()     -- Controls the amount of debug information kept during node.
   _syslog.print(_syslog.ERROR,"node.stripdebug() not yet implemented")
end

node.osprint = function()        -- Controls whether the debugging output from the Espressif SDK is printed.
   _syslog.print(_syslog.ERROR,"node.osprint() not yet implemented")
end 

node.random = function()         -- This behaves like math.
   return math.random()
end

node.egc = { }
node.egc.setmode = function()    -- Sets the Emergency Garbage Collector mode.
   _syslog.print(_syslog.ERROR,"node.egc.setmode() not yet implemented")
end

node.task = { }
node.task.post = function()       --  Enable a Lua callback or task to post another task request.
   _syslog.print(_syslog.ERROR,"node.task.post() not yet implemented")
end

table.insert(node.modules,'node')

return node;

