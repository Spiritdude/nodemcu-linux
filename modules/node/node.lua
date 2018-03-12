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

if io.open("/usr/bin/cpufreq-info") then                 -- we don't have file.exists() yet
   io.close()
   -- probe available cpu frequencies (for node.setcpufreq())
   local f = io.popen("cpufreq-info")
   repeat
      local t = f:read("*line")
      if t and t:match("available frequency steps:") then
         for v,u in t:gmatch("([%d%.]+) ([MG]Hz)") do
            v = tonumber(v)
            if u=='GHz' then
               v = v * 1000
            end
            if not node._cpufreq then
               node._cpufreq = { }
            end
            --node._cpufreq[v] = v
            table.insert(node._cpufreq,v)
         end
         t = nil
      end
   until t==nil
   f:close()
end

local _getmac = function()
   if not node._mac then
      local f = io.popen('ifconfig')
      local t = f:read("*all")
      f:close()
      node._mac = t:match("HWaddr ([%:%x]*)") or t:match("ether ([%:%x]*)")
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
      if f then
      _ = f:read("*line")
      _ = f:read("*line")  -- get mount point
      f:close()
      local m = _:match("(%S+)")
      f = io.popen("lsblk --output UUID "..m)    -- lookup UUID of disk mounted at '.'
      if f then
         _ = f:read("*line")   -- 'UUID'
         _ = f:read("*line")
         f:close()
         return _:match("(%S+)")    -- pass disk UUID as flashid
      end
   end
   _syslog.print(_syslog.WARN,"cannot determine flash id of current directory")
   return nil
end

node.flashsize = function()      -- Returns the flash chip size in bytes.
   local remain, used, total = file.fsinfo()
   return total * 1024
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
         local cset = false
         for i,ff in pairs(node._cpufreq) do
            if ff==f then
               os.execute("cpufreq-set --freq "..f.."MHz")
               cset = true
               break
            end
         end
         if not cset then
            local o = "   "
            --table.sort(node._cpufreq)
            for i,f in pairs(node._cpufreq) do
               o = o .. f .. " "
            end
            if false then         -- being restrictive
               print("node.setcpufreq(): ERROR: only following frequencies [MHz] settings possible:")
               print(o)
            else 
               local ff           -- being generous: find a possible frequency 
               for i,ff in pairs(node._cpufreq) do
                  if ff >= tonumber(_sysinfo.cpu_min_mhz) and ff >= f then
                     os.execute("cpufreq-set --freq "..ff.."MHz")
                     _syslog.print(_syslog.INFO,"frequency "..f.." [MHz] isn't available, instead "..ff.." [MHz] used")
                     break
                  end
               end
            end
         end
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

