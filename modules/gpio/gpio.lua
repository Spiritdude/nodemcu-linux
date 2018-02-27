-- == GPIO Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--   configure GPIO and write to or read from them
--
-- History:
-- 2018/02/24: 0.0.1: first version, gpio.mode(), read() and write() implemented but untested

local GPIO = require('periphery').GPIO

gpio = {
   _pin = { },
   OUTPUT = "out", 
   INPUT = "in",
   OPENDRAIN = nil, 
   INT = 4,
   
   FLOAT = 0,
   PULLUP = 1
}

gpio.mode = function(pin, mode, pullup)    -- Initialize pin to GPIO mode, set the pin in/out direction, and optional internal weak pull-up.
   if mode then
      _pin[pin] = GPIO(pin,mode)
   else 
      _pin[pin] = GPIO(pin)
   end
end

gpio.config = function(tb) 
   _syslog.print(_syslog.ERROR,"gpio.config(): not yet implemented")
   -- gpio.config({
   --  gpio=x || {x, y, z},
   --  dir=gpio.IN || gpio.OUT || gpio.IN_OUT,
   --  opendrain= 0 || 1 -- only applicable to output modes
   --  pull= gpio.FLOATING || gpio.PULL_UP || gpio.PULL_DOWN || gpio.PULL_UP_DOWN
   --}, ...)
end

gpio.read = function(pin)    -- Read digital GPIO pin value.
   if gpio._pin[pin] then
      return gpio._pin[pin]:read()
   else
      _syslog.print(_syslog.ERROR,"gpio.read(): pin "..pin.." not yet configured")
   end
end

gpio.write = function(pin,v)    --   Set digital GPIO pin value.
   if gpio._pin[pin] then
      return gpio._pin[pin]:write(pin,v==1 or false)
   else
      _syslog.print(_syslog.ERROR,"gpio.write(): pin "..pin.." not yet configured")
   end
end

gpio.serout = function()    --  Serialize output based on a sequence of delay-times in s.
   _syslog.print(_syslog.ERROR,"gpio.serout(): not yet implemented")
end

gpio.trig = function()    -- Establish or clear a callback function to run on interrupt for a pin.
   _syslog.print(_syslog.ERROR,"gpio.trig(): not yet implemented")
end

table.insert(node.modules,'gpio')

return gpio;

