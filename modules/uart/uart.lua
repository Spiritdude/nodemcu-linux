-- == UART Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--
-- Notes:
--    - not yet sure which backend to use
--      - https://github.com/vsergeev/lua-periphery (already used for gpio and i2c)
--      - https://github.com/edartuz/lua-serial
--      - or luanode internals posix stream to properly support uart.on() callback (non-blocking is essential)
--
-- History:
-- 2018/03/10: 0.0.1: first version, just a skeleton, not yet functional

local Serial = require('periphery').Serial

uart = {
   _VERSION = '0.0.1',
   _devices = { },
   DEV_PREFIX = UART_DEV_PREFIX or "tty",
   PARITY_NONE = "none",
   PARITY_ODD = "odd",
   PARITY_EVENT = "even",
   STOP_BITS_1 = 1,
   STOP_BITS_1_5 = 1,
   STOP_BITS_2 = 2,
   FLOWCTRL_NONE = 0, 
   FLOWCTRL_CTS = 1,
   FLOWCTRL_RTS = 2,
}

-- we determine the uart devices and dynamically set uart.UART[0..x] = uart.DEV_PREFIX..d (e.g. uart.UART0 = "/dev/ttyUSB0")
for f in lfs.dir("/dev/") do
   if f:match("^"..uart.DEV_PREFIX) then 
      if not f:match(uart.DEV_PREFIX.."%d*$") then
         table.insert(uart._devices,"/dev/"..f)
      end
   end
end

table.sort(uart._devices)

local i = 0
local o = ""
for j,d in pairs(uart._devices) do
   local dev = d
   o = o .. (i>0 and " " or "") .. dev
   uart['UART'..i] = dev
   i = i+1
   uart._count = i
end
if i>0 then
   _syslog.print(_syslog.INFO,"uart: "..i.." interface(s) found: "..o)
else
   _syslog.print(_syslog.INFO,"uart: no interface found")
end

-- --------------------------------------------------------------------------------------------------------------------------

uart.alt = function(on)  -- Change UART pin assignment.
   _syslog.print(_syslog.WARN,"uart.alt() not supported, use uart.setup(id,datab,par,stopb,{tx=pintx,rx=pinrx,...})")
end

uart.on = function(id, method, sep, func, input)   -- Sets the callback function to handle UART events.
   if id=='data' then
      _syslog.print(_syslog.WARN,"uart.on(): please use as first argument the UART id, using id = uart.UART0")
      input = func
      func = sep
      sep = method
      method = id
      id = uart.UART0
   end
   if not (uart.config[id] and uart.config[id].on) then
      _syslog.print(_syslog.ERROR,"uart.on(): please first uart.setup() the device")
      os.exit(-1)
   end

   if func then               -- setup data receive callback
      uart.config[id].on[method] = { func = func, sep = sep, input = input }
   else
      uart.config[id].on[method] = { }
   end
end

uart.setup = function(id, baud, databits, parity, stopbits, echo)   -- (Re-)configures the communication parameters of the UART.
   if type(id)=='number' then
      _syslog.print(_syslog.WARN,"uart.setup(): please use as first argument the UART id, using id = uart.UART0")
      --   uart.setup(baud, databits, parity,   stopbits, echo)
      --   uart.setup(id,   baud,     databits, parity,   stopbits, echo)
      echo = stopbits
      stopbits = parity
      parity = databits
      databits = baud
      baud = id
      id = uart.UART0
   end
   if type(echo)=='table' then   -- configure new pins
      -- NOTE: if the board allows configure GPIO as UART interface, then it has to happen here:
      -- echo.tx int. TX pin. Required
      --      rx int. RX pin. Required
      --      cts in. CTS pin. Optional
      --      rts in. RTS pin. Optional
      --      tx_inverse boolean. Inverse TX pin. Default: false
      --      rx_inverse boolean. Inverse RX pin. Default: false
      --      cts_inverse boolean. Inverse CTS pin. Default: false
      --      rts_inverse boolean. Inverse RTS pin. Default: false
      --      flow_control int. Combination of uart.FLOWCTRL_NONE, uart.FLOWCTRL_CTS,  uart.FLOWCTRL_RTS. Default: uart.FLOWCTRL_NONE
      
      echo = nil
   end
   uart.config = uart.config or { }
   uart.config[id] = uart.config[id] or { }
   uart.config[id].baud = baud
   uart.config[id].databits = databits
   uart.config[id].stopbits = stopbits
   uart.config[id].parity = parity
   
   -- here insert hardware near setup the uart truly
   -- set uart.config[id].dev to support :write(s)
   
   uart.config[id].on = { }
end

uart.getconfig = function(id)  -- Returns the current configuration parameters of the UART.
   local c = uart.config[id]
   return c.baud, c.databits, c.parity, c.stopbits
end

uart.write = function(id, s)  -- Write string or byte to the UART.
   uart.config[id].dev:write(s)
end

table.insert(node.modules,"uart")

return uart

