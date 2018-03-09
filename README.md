# NodeMCU/Linux

## Introduction

<img src="https://raw.githubusercontent.com/Spiritdude/nodemcu-linux/master/imgs/nodemcu-linux.png" align=right>

**NodeMCU/Linux** aims to implement the NodeMCU API as known by [NodeMCU/ESP8266](https://github.com/nodemcu/nodemcu-firmware) or "NodeMCU firmware", to additionally support

- **Raspberry Pi** (EUR 35) and **RPi Zero** (EUR 5-10) running [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
- **NanoPi series**, like **NanoPi Neo** (EUR 8-30) with Allwinner H3 running [Armbian](https://armbian.org)
- **Orange Pi**, like **Orange Pi Zero**, **Orange Pi Lite** (EUR 6-30) series with Allwinner H2+ & H3 running [Armbian](https://armbian.org)
- essentially any device which runs a Debian-based Linux distro, and preferably with GPIO, I2C, SPI facility

The idea is to implement majority of the base modules in Lua itself, with few hooks with FFI (either `luajit` or `luaffifb` module). 

## Current State

Check out the [NodeMCU/Linux Wiki](https://github.com/Spiritdude/nodemcu-linux/wiki) with current state of the base modules, an incomplete summary:
- `node`: mostly implemented
- `tmr`: mostly implemented but not much tested
- `file`: basic operations implemented but mostly untested
- `net`: partially implemented but not much tested
- `rtctime`: partially implemented
- `gpio`: partially implemented but entirely untested
- `i2c`: code skeleton, far away to be functional
- `bit`: built-in
- `math`: built-in
- `sjson`: built-in with `lunajson`

running with Lua 5.1 with the [LuaNode](https://github.com/ignacio/LuaNode) (`luanode`) extension with `ffi` support.

## Todo
- implement **all** base modules **completely** and document it properly
- thorough tests (automated)
- `u8g2` which needs low-level I2C or SPI interface hardware-near implemented
- include Lua modules which support various I2C/SPI devices
- test example/tests with NodeMCU/8266 and NodeMCU/ESP32 as well

## Installation

```
% git clone https://github.com/Spiritdude/nodemcu-linux
% cd nodemcu-linux
% sudo make requirements
% sudo make install
```

## Usage

The main executable is `nodemcu`, when executed it "boots" NodeMCU/Linux and executes `init.lua` if it resides in the same directory.

An example with a NanoPi Neo:

```
% nodemcu
NodeMCU/Linux 0.0.6 powered by Lua 5.1, Device ID: 4310175 / 0x41c49f
   armv7l (4 cores, 240-1200MHz)
   modules: node tmr file gpio i2c net rtctime sjson bit struct math
   cpu freq table [MHz]: 60, 120, 240, 312, 408, 480, 504, 528, 576, 600, 624, 648, 672, 720, 768, 816, 864, 912, 960, 1010, 1060, 1100, 1150, 1200, 1250, 1300, 1340, 1440, 1540
> 
```

The `>` is the prompt, awaiting console Lua input - abort with CTRL-C.

```
% nodemcu --help
NodeMCU/Linux 0.0.6 USAGE: nodemcu {[options] .. } {[file1] .. }
   options:
      -v or -vv         increase verbosity
      --verbose=<n>     define verbosity n = 0..10
      -h                print this usage help
      --help               "           "
      --version         display version and exit
      
   examples:
      nodemcu                    boot and execute init.lua and enter Lua console
      nodemcu --version          
      nodemcu --help
      nodemcu -vvv 
      nodemcu --verbose=3
      nodemcu test.lua           boot and execute test.lua and exit

% nodemcu -v
I [0.000] loading modules ('node' and 'tmr' already loaded)
I [0.001] dofile /usr/local/lib/nodemcu/modules/file/file.lua
I [0.004] dofile /usr/local/lib/nodemcu/modules/gpio/gpio.lua
I [0.007] dofile /usr/local/lib/nodemcu/modules/i2c/i2c.lua
I [0.009] i2c: 3 interface(s) found: /dev/i2c-0 /dev/i2c-1 /dev/i2c-2
I [0.009] dofile /usr/local/lib/nodemcu/modules/net/net-node.lua
I [0.024] dofile /usr/local/lib/nodemcu/modules/rtctime/rtctime.lua
I [0.025] dofile /usr/local/lib/nodemcu/modules/sjson/sjson.lua
I [0.042] modules bit, struct built-in added
I [0.043] module math added
NodeMCU/Linux 0.0.6 powered by Lua 5.1, Device ID: 4310175 / 0x41c49f
   armv7l (4 cores, 240-1200MHz)
   modules: node tmr file gpio i2c net rtctime sjson bit struct math
   cpu freq table [MHz]: 60, 120, 240, 312, 408, 480, 504, 528, 576, 600, 624, 648, 672, 720, 768, 816, 864, 912, 960, 1010, 1060, 1100, 1150, 1200, 1250, 1300, 1340, 1440, 1540
> 
```

Within the `nodemcu-linux/` directory you cloned resides a default `init.lua` which executes `startup.lua` which performs some basic tests of various modules:

```
NodeMCU/Linux 0.0.6 powered by Lua 5.1, Device ID: 4310175 / 0x41c49f
   armv7l (4 cores, 240-1200MHz)
   modules: node tmr file gpio i2c net rtctime sjson bit struct math
   cpu freq table [MHz]: 60, 120, 240, 312, 408, 480, 504, 528, 576, 600, 624, 648, 672, 720, 768, 816, 864, 912, 960, 1010, 1060, 1100, 1150, 1200, 1250, 1300, 1340, 1440, 1540
starting up...
tmr.now() 67997
tmr.time() 0
tmr.uptime() 0.068331003189087
rtctime 2018/03/09 15:57:48 UTC
node.chipid() 4310175 0x41c49f
node.flashid() 9a463503-3ec8-4cb9-aa50-aaaeae3a9e97
node.heap() 150806528 148724KiB
file.list() init.lua(64) misc(4096) nodemcu(6818) LICENSE(1082) .git(4096) ..(4096) fw(4096) imgs(4096) README.md(5334) modules(4096) startup.lua(3169) tests(4096) LuaNode(4096) Makefile(1571) examples(4096) .(4096) 
file.stat() with json {"time":{"min":37,"wday":5,"day":9,"yday":67,"year":2018,"sec":55,"hour":15,"mon":3},"is_arch":false,"name":"README.md","is_sys":false,"is_rdonly":false,"is_hidden":false,"is_dir":false,"size":5334}
file.fsinfo() remain 21506.816MiB, used 7921.750MiB, total 29744.812MiB
net-test: connecting to httpbin.org
net-test: basic http server started on port 10080
> net-test: http-received:
| HTTP/1.1 200 OK
| Connection: close
...
..

% cd tests
% nodemcu file01.lua
```

## Detailed Development

See my [Spiritude's Public Notebook: NodeMCU Shell Development](https://spiritdude.wordpress.com/2018/02/26/nodemcu-linux/) which I document more fine-grained state of the development with examples.


Ren&eacute; K. M&uuml;ller<br>
February 2018
