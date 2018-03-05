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

if file.exists("cpu/main.lua") then          -- NodeMCU Shell arround, if so run `cpu` command
   dofile("cpu/main.lua")("cpu")
end

local ffi = require("ffi")                   -- testing ffi
if ffi then
   ffi.cdef[[
   int printf(const char *fmt, ...);
   ]]
   ffi.C.printf("ffi: Hello %s!\n", "world")
end
