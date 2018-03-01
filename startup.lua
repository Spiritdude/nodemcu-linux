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

if false then
   tmr.create():alarm(2,tmr.ALARM_AUTO,function(t)
      print("ping")
   end)
end
