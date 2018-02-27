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
-- 2018/02/24: 0.0.1: first version: int(), dofile(), print() and basic syslog.* facility

int = function(i) 
   return math.floor(i)
end

_syslog = {                -- internal syslog facility
   INFO  = "INFO",
   WARN  = "WARN",
   ERROR = "ERROR",
   FATAL = "FATAL",
   print = function(...)
      local t = {...}
      local i = table.remove(t,1)
      print(i:match("(%w)"),string.format("[%.3f]",tmr.uptime()),unpack(t))
   end
}

print = function(...)
   local o = ""
   for i,v in ipairs({...}) do
      --io.write(": "..tostring(i)..tostring(v).."\n")
      o = o .. (i > 1 and " " or "")
      o = o .. tostring(v)
   end
   io.write(o.."\n")
end


