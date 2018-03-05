-- == Timer(Tmr)-Node Module ==
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
--    - *this* is the LuaNode version of tmr.lua
--    - lalarm module only provides POSIX alarm() interface with integer seconds delays, but we need milli- or microseconds
--    - socket.gettime() gives high precision time
--    - https://github.com/davisdude/Timer uses coroutines
--
-- History:
-- 2018/03/05: 0.0.1: based on tmr.lua (0.0.3) with LuaNode setInterval/Timeout() usage (not yet fully tested)

local socket = require("socket")
local bit = require('bit')

tmr = {
   _VERSION = '0.0.1',
   _start = socket.gettime(),

   ALARM_SINGLE = 0,
   ALARM_AUTO = 1,
   ALARM_SEMI = 2,

   _ACTIVE = 0,
   _INACTIVE = 1,
   _SUSPENDED = 2,            -- only formerly _ACTIVE instances can be _SUSPENDED
   
   _list = { },
   _last = 0
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

tmr.create = function()      -- Creates a dynamic timer object.
   local t = {
      _state = tmr._INACTIVE,

      alarm = function(self,t,m,func)   -- This is a convenience function combining tmr.
         self:register(t,m,func)
         self:start()
      end,

      interval = function(self,t)           -- Changes a registered timer's expiry interval.
         self._interval = t / 1000 
         self._timeout = tmr.uptime() + self._interval 
      end,

      register = function(self,t,m,func)    -- Configures a timer and registers the callback function to call on expiry.
         self:interval(t)
         self._mode = m
         self._func = func
      end,

      resume = function(self)              -- Resume an individual timer.
         self._state = tmr._ACTIVE
         self._timeout = tmr.uptime() + self._interval       -- recalculate _timeout
         _ = self._mode==tmr.ALARM_AUTO and self._ref:setInterval(self._func,self._interval*1000,self) or self._ref:setTimeout(self._func,self._interval*1000,self)
      end,

      start = function(self)               -- Starts or restarts a previously configured timer.
         self._state = tmr._ACTIVE
         if self._mode==tmr.ALARM_SINGLE then
            self._ref = setTimeout(self._func,self._interval*1000,self)
         elseif self._mode==tmr.ALARM_AUTO then
            self._ref = setInterval(self._func,self._interval*1000,self)
         end
      end,
      
      state = function(self)               -- Checks the state of a timer.
         return self._state == tmr._ACTIVE, self._mode
      end,
      
      stop = function(self)                -- Stops a running timer, but does not unregister it.
         self._state = tmr._INACTIVE
         _ = self._mode==tmr.ALARM_AUTO and clearInterval(self._ref) or clearTimeout(self._ref)
      end,
            
      suspend = function(self)             -- Suspend an armed timer.
         self._state = tmr._SUSPENDED
         _ = self._mode==tmr.ALARM_AUTO and clearInterval(self._ref) or clearTimeout(self._ref)
      end,

      unregister = function(self)          -- Stops the timer (if running) and unregisters the associated callback.
         self._state = tmr._INACTIVE
         _ = self._mode==tmr.ALARM_AUTO and clearInterval(self._ref) or clearTimeout(self._ref)
         table.remove(tmr._list,self._id)
      end
   }

   tmr._last = tmr._last + 1
   t._id = tmr._last
   
   table.insert(tmr._list,tmr._last,t)

   return t
end

tmr.delay = function()       -- Busyloops the processor for a specified number of microseconds.
   _syslog.print(_syslog.ERROR,"tmr.delay() no longer supported, change your code to adapt asynchronous programming style")
   return
end
      
tmr.resume_all = function()       -- Resume all timers.
   for i,tm in pairs(tmr._list) do
      if tm._state == tmr._SUSPENDED then
         tm:resume()
      end
   end
end

tmr.suspend_all = function() -- Suspend all currently armed timers.
   for i,tm in pairs(tmr._list) do
      if tm._state == tmr._ACTIVE then
         tm:suspend()
      end
   end
end

tmr.softwd = function()      -- Provides a simple software watchdog, which needs to be re-armed or disabled before it expires, or the system will be restarted.
   _syslog.print(_syslog.ERROR,"tmr.softwd() not yet implemented")
end

tmr.wdclr = function()       -- Feed the system watchdog.
   _syslog.print(_syslog.ERROR,"tmr.wdclr() not yet implemented")
end

table.insert(node.modules,'tmr')

return tmr;   

