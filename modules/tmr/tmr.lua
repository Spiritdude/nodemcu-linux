-- == Timer(Tmr) Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--    - tmr.now() is only a 31 bit microsecond counter (compatible with NodeMCU/ESP8266)
--    - tmr.time() is integer only
--    - tmr.uptime() is high precision uptime (not backward compatible with NodeMCU/ESP8266)
--
-- Notes:
--    - lalarm module only provides POSIX alarm() interface with integer seconds delays, but we need milli- or microseconds
--    - socket.gettime() gives high precision time
--    - https://github.com/davisdude/Timer uses coroutines
--
-- History:
-- 2018/02/25: 0.0.2: tmr.now(), time() and uptime() working
-- 2018/02/21: 0.0.1: first version, just a skeleton

local socket = require("socket")
local bit = require('bit')
--local timer = loadfile("modules/tmr/timer.lua")()      -- sample code doesn't work .. after wait(1) never reaches next statement

tmr = {
   _VERSION = '0.0.2',
   _start = socket.gettime(),
   ALARM_SINGLE = 0,
   ALARM_AUTO = 1,
   ALARM_SEMI = 2
}

tmr.now = function()         -- Returns the system counter, which counts in microseconds.
   local t = socket.gettime() - tmr._start
   return bit.band(int((t - int(t)) * 1000000) + int(t) * 1000000,0x7ffffff)   -- only 31 bits are good
end

tmr.time = function()        -- Returns the system uptime, in seconds.
   return int(tmr.uptime())
end

tmr.uptime = function()      -- Returns the system uptime, in seconds with microseconds precision
   return socket.gettime() - tmr._start
end

_ = [[
tmr.create = function()      -- Creates a dynamic timer object.
   return {
      alarm = function(self,t,m,func)   -- This is a convenience function combining tmr.
         -- first test: https://github.com/davisdude/Timer
         --    - wait(t) never comes back
         self._timer = timer.new(function() 
            print("t",t,"m",m)
            if m==tmr.ALARM_SINGLE then
               wait(t)
               func(self)
            elseif m==tmr.ALARM_AUTO then
               --while true do 
                  print("1a",t);
                  func()
                  print("1b",t);
                  wait(t)
                  print("1c",t);       -- never reaches here (seems not to work)
               --end
            elseif m==tmr.ALARM_SEMI then
               --
            end
         end)
         self._timer:update(1)   
         --_syslog.print(_syslog.ERROR,"tmr.alarm() not yet implemented")
      end,

      interval = function(self)    -- Changes a registered timer's expiry interval.
         _syslog.print(_syslog.ERROR,"tmr.interval() not yet implemented")
      end,

      register = function(self)    -- Configures a timer and registers the callback function to call on expiry.
         _syslog.print(_syslog.ERROR,"tmr.register() not yet implemented")
      end,

      resume = function(self)      -- Resume an individual timer.
         _syslog.print(_syslog.ERROR,"tmr.resume() not yet implemented")
      end,

      start = function(self)       -- Starts or restarts a previously configured timer.
         _syslog.print(_syslog.ERROR,"tmr.start() not yet implemented")
      end,
      
      state = function(self)       -- Checks the state of a timer.
         _syslog.print(_syslog.ERROR,"tmr.state() not yet implemented")
      end,
      
      stop = function(self)        -- Stops a running timer, but does not unregister it.
         _syslog.print(_syslog.ERROR,"tmr.stop() not yet implemented")
      end,
            
      suspend = function(self)     -- Suspend an armed timer.
         _syslog.print(_syslog.ERROR,"tmr.suspend() not yet implemented")
      end,

      unregister = function(self)  -- Stops the timer (if running) and unregisters the associated callback.
         _syslog.print(_syslog.ERROR,"tmr.unregister() not yet implemented")
      end
   }
end

tmr.delay = function()       -- Busyloops the processor for a specified number of microseconds.
   _syslog.print(_syslog.ERROR,"tmr.delay() no longer supported, change your code to adapt asynchronous programming style")
   return
end
      
tmr.resume_all = function()       -- Resume all timers.
end

tmr.softwd = function()      -- Provides a simple software watchdog, which needs to be re-armed or disabled before it expires, or the system will be restarted.
end

tmr.suspend_all = function() -- Suspend all currently armed timers.
end

tmr.wdclr = function()       -- Feed the system watchdog.
end
]]

table.insert(node.modules,'tmr')

return tmr;   
