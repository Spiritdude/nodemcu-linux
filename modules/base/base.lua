-- == Base Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--    Common NodeMCU functions (re-)defined.
--
-- History:
-- 2018/03/04: 0.0.2: slowly ramping up functionality: _tasker skeleton of internal scheduler of non-blocking tasks
-- 2018/02/24: 0.0.1: first version: int(), dofile(), print() and basic syslog.* facility

int = function(i) 
   return math.floor(i)
end

-- internal tasker
_tasker = {             -- NOTE: not yet useable, needs to be tested
   ACTIVE = 0,          -- state
   INACTIVE = 1,

   LOW = 0,             -- prio
   MEDIUM = 1,
   HIGH = 2,

   _list = { },         -- list of tasks

   run = function()
      for p in pairs({_tasker.HIGH,_tasker.MEDIUM,_tasker.LOW}) do
         for i,t in pairs(_list) do
            local t = _list[i]
            if t.prio == p and t.state == _tasker.ACTIVE then 
               coroutine.resume(t.cf)
            end
         end
      end
   end,
   new = function(f,p,opts) 
      p = p or _tasker.MEDIUM
      table.insert(_list,{ 
         prio = p, 
         state = _tasker.ACTIVE, 
         --cf = coroutine.create(function() local res = f() coroutine.yield(res) end) 
         cf = coroutine.create(f) 
      })
      return #_list
   end,
   suspend = function(id)
      _tasker._list[id].state = _tasker.INACTIVE
   end,
   resume = function(id)
      _tasker._list[id].state = _tasker.ACTIVE
   end,
   suspend_all = function()
      for i,t in pairs(_list) do
         _tasker.suspend(i)
      end
   end,
   resume_all = function()
      for i,t in pairs(_list) do
         _tasker.resume(i)
      end
   end
}

_syslog = {                -- internal syslog facility
   INFO  = "INFO",
   WARN  = "WARN",
   ERROR = "ERROR",
   FATAL = "FATAL",
   _verbose = 0,
   print = function(...)
      local t = {...}
      local i = table.remove(t,1)
      if _syslog._verbose == 0 and i == _syslog.INFO then
         return
      elseif _syslog._verbose <= 1 and (i == _syslog.INFO or i == _syslog.WARN) then
         return
      else
         print(i:match("(%w)"),string.format("[%.3f]",tmr.uptime()),unpack(t))
      end
   end,
   verbose = function(l)
      _syslog._verbose = tonumber(l)
   end
}

print = function(...)
   local o = ""
   for i,v in pairs({...}) do
      --io.write(": "..tostring(i)..tostring(v).."\n")
      o = o .. (i > 1 and " " or "")
      o = o .. tostring(v)
   end
   io.write(o.."\n")
end


