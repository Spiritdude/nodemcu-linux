print("starting up...")

print("tmr.now()",tmr.now())
print("tmr.time()",tmr.time())
print("tmr.uptime()",tmr.uptime())
local tm = rtctime.epoch2cal(rtctime.get())
local tz = 'UTC'
print("rtctime",string.format("%04d/%02d/%02d %02d:%02d:%02d %s",tm["year"],tm["mon"],tm["day"],tm["hour"],tm["min"],tm["sec"],tz))

print("node.chipid()",node.chipid(),string.format("0x%x",node.chipid()))
print("node.heap()",node.heap(),string.format("%dKiB",node.heap()/1014))

print("file.list()",table.concat(file.list(),", "))

print("file.stat() with json",sjson.encode(file.stat("README.md")))
