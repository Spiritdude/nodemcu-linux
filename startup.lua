print("starting up...")

print("tmr.now()",tmr.now())
print("tmr.time()",tmr.time())
print("tmr.uptime()",tmr.uptime())
local tm = rtctime.epoch2cal(rtctime.get())
local tz = 'UTC'
print("rtctime",string.format("%04d/%02d/%02d %02d:%02d:%02d %s",tm["year"],tm["mon"],tm["day"],tm["hour"],tm["min"],tm["sec"],tz))

print("node.chipid()",node.chipid(),string.format("0x%x",node.chipid()))
print("node.flashid()",node.flashid())
print("node.heap()",node.heap(),string.format("%dKiB",node.heap()/1014))

local o = ""
for f,s in pairs(file.list()) do 
   o = o .. f .. "("..s..") "
end
print("file.list()",o)

print("file.stat() with json",sjson.encode(file.stat("README.md")))
local remain, used, total = file.fsinfo()
print("file.fsinfo()",string.format("remain %.3fMiB, used %.3fMiB, total %.3fMiB",remain/1024,used/1024,total/1024))

if true then         -- brief tmr.* testing
   local n = 1
   tmr.create():alarm(1*1000,tmr.ALARM_AUTO,function(t)
      print("tmr-test: ping",tmr.uptime(),n)
      if n==5 then
         tmr.suspend_all()
         tmr.create():alarm(3*1000,tmr.ALARM_SINGLE,function(t)
            print("tmr-test: once",tmr.uptime())
         end)
      end
      n = n + 1
   end)
   tmr.create():alarm(1.5*1000,tmr.ALARM_AUTO,function(t)
      print("tmr-test: pong",tmr.uptime())
      t:unregister()
   end)
end

if not _sysinfo.architecture:match("^arm") then
   local ffi = require("ffi")                   -- testing ffi (disabled for ARM-based CPU, as luaffifb seems broken there)
   if ffi then
      ffi.cdef[[
      int printf(const char *fmt, ...);
      ]]
      ffi.C.printf("ffi: Hello %s!\n", "world")
   end
end

if net and net.createConnection then
   local srv = net.createConnection(net.TCP, 0)
   srv:on("receive", function(sck, c) print(": ",c) end)
   srv:on("connection", function(sck, c)
      -- 'Connection: close' rather than 'Connection: keep-alive' to have server 
      -- initiate a close of the connection after final response (frees memory 
      -- earlier here), https://tools.ietf.org/html/rfc7230#section-6.6 
      sck:send("GET /get HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\nAccept: */*\r\n\r\n")
   end)
   srv:connect(80,"httpbin.org")
end

if net and net.createServer then 
   local sv = net.createServer(net.TCP, 30)
   if sv then
      sv:listen(10080, function(conn)
         conn:on("receive",function(sck,data) 
            print("==server received",data)
         end)
         conn:on("sent",function(sck)
            print("sent received, now closing",sck,conn)
            sck:close()
         end)
         conn:send("HTTP/1.0 200 OK\r\nConnection: close\r\n\r\nHello world! "..tmr.uptime())
      end)
   end
end

if file.exists("cpu/main.lua") then          -- NodeMCU Shell arround, if so run `cpu` command
   dofile("cpu/main.lua")("cpu")
end


