-- == Net Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--   This is the non-functional skeleton for `socket`-based net module, it would require
--   non-blocking/callback implementation - which LuaNode supports out of the box, see net-node.lua
--
-- Notes:
--   - see https://github.com/nodemcu/nodemcu-firmware/blob/master/app/modules/net.c as reference
--
-- History:
-- 2018/02/24: 0.0.1: first version, just a skeleton

local Socket = require('socket')

net = {
}

net.createConnection = function()    -- Creates a client.
end

net.createServer = function()        -- Creates a server.
   return {
      newClients = function() 
         local c = self._server:accept()
         if c then
            c:timeout(1)
            self._server:on("connection",c)
            table.insert(self._clients,c)
         end
      end,
      
      listen = function(port,func)
         self._server = socket.new(port)
         self._server:timeout(0.1)
         self._port = port
         self._clients = { }
         self._sendClients = { }
         while true do
            self:newClients()
            local receivingClients, _, error = select(self._clients, nil, .01)
            for i, client in receivingClients do
               local data, error = client:receive()
               if error then
                  _syslog.print(_syslog.ERROR,"net.listen(): "..tostring(error).." on client "..tostring(client))
                  table.remove(self._clients,i)
               else
                  self._server:on("receive",data)
                  --client.send()
                  client:close()
                  table.remove(self._clients,i)
               end
            end
         end
         return self
      end
   }
end

net.createUDPSocket = function()    -- Creates an UDP socket.
end

net.multicastJoin = function()    -- Join multicast group.
end

net.multicastLeave = function()   -- Leave multicast group.
end

_ = [[
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

