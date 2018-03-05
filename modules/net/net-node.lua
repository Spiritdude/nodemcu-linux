-- == Net Node Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--
-- Notes:
--   - see https://github.com/nodemcu/nodemcu-firmware/blob/master/app/modules/net.c as reference
--
-- History:
-- 2018/03/05: 0.0.1: first version, just a skeleton

print("net-node.lua")

Net = require('luanode.net')

net = {
   TCP = 0,
   UDP = 1
}

net.createConnection = function()    -- Creates a client.
   return {
      _event = { },
      connect = function(self,port,host)
         local me = self
         
         self._sck = Net.createConnection(port,host)

         self._sck.send = function(self,s)         -- wrap c:write() to c:send()
            --print('dedicated send()',s)
            self:write(s)
         end

         self._sck:on("connect",function()
            --print("on:connect",self)
            _ = self._event.connection and self._event.connection(self._sck) or 0

            local me = self

            self._sck:on("data",function(self,data) 
               --print("on:receive",self,data)
               _ = me._event.receive and me._event.receive(me._sck,data) or 0
            end)

            self._sck:on("close",function() 
               --print("on:close")
               _ = me._event.close and me._event.close(me._sck) or 0
            end)

            self._sck:on("drain",function() 
               _ = me._event.sent and me._event.sent(me._sck) or 0
            end)
         end)
         return self
      end,
      on = function(self,event,func)
         self._event[event] = func
         --print("==on:",event,func)
      end
   }
end

net.createServer = function()        -- Creates a server.
   return {
      _event = { },
      _srv = Net.createServer(function(self,conn)
         conn:setEncoding('binary')
         local me = self._me
         conn:addListener('connect',function(self) 
            _ = me._event.connection and me._event.connection(conn)
         end)
         conn:addListener('data',function(self,chunk) 
            _ = me._event.receive and me._event.receive(conn,chunk)
         end)
         conn:addListener('close',function(self) 
            _ = me._event.close and me._event.close(conn)
            conn:finish()
         end)
         conn:addListener('drain',function(self,conn)
            _ = me._event.sent and me._event.sent(self)
         end)
         conn.on = function(self,event,func)
            me._event[event] = func
         end
         conn.send = function(self,s)
            self:write(s)
         end
         conn.close = function(self)
            self:finish()
         end
         me._func(conn)
         return me
      end),
      listen = function(self,port,func) 
         self._port = port
         self._func = func
         self._srv._me = self       -- point upward
         self._srv:listen(port)
      end,
      close = function(self)
         self._srv:close()          -- untested
      end
   }
end

_ = [[
net.createUDPSocket = function()    -- Creates an UDP socket.
end

net.multicastJoin = function()    -- Join multicast group.
end

net.multicastLeave = function()   -- Leave multicast group.
end

net.server = { }
net.server:close = function()    --  Closes the server.
end

net.server:listen = function()    -- Listen on port from IP address.
end

net.server:getaddr = function()   -- Returns server local address/port.
end

net.socket = { }
net.socket:close = function()    -- Closes socket.
end

net.socket:connect = function()   -- Connect to a remote server.
end

net.socket:dns = function()    -- Provides DNS resolution for a hostname.
end

net.socket:getpeer = function()    -- Retrieve port and ip of remote peer.
end

net.socket:getaddr = function()    -- Retrieve local port and ip of socket.
end

net.socket:hold = function()    -- Throttle data reception by placing a request to block the TCP receive function.
end

net.socket:on = function()    -- Register callback functions for specific events.
end

net.socket:send = function()   -- Sends data to remote peer.
end

net.socket:ttl = function()    -- Changes or retrieves Time-To-Live value on socket.
end

net.socket:unhold = function()    -- Unblock TCP receiving data by revocation of a preceding hold().
end

net.udpsocket = { }
net.udpsocket:close = function()    -- Closes UDP socket.
end

net.udpsocket:listen = function()    -- Listen on port from IP address.
end

net.udpsocket:on = function()    -- Register callback functions for specific events.
end

net.udpsocket:send = function()    -- Sends data to specific remote peer.
end

net.udpsocket:dns = function()    -- Provides DNS resolution for a hostname.
end

net.udpsocket:getaddr = function()    -- Retrieve local port and ip of socket.
end

net.udpsocket:ttl = function()    -- Changes or retrieves Time-To-Live value on socket.
end

net.dns.getdnsserver = function()    -- Gets the IP address of the DNS server used to resolve hostnames.
end

net.dns.resolve = function()    -- Resolve a hostname to an IP address.
end

net.dns.setdnsserver = function()    -- Sets the IP of the DNS server used to resolve hostnames.
end
]]

socket = { 
   new = function(port)
      self = { }
      self._socket = Socket.bind("*",port)
      return self
   end,
   connect = function(ip)
   end,
   on = function(event,conn)
   end,
   send = function(str)
      self._socket:send(str)
   end,
   close = function(str)
      self._socket:close()
   end
}

table.insert(node.modules,"net")

return net

