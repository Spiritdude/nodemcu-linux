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
Within the `nodemcu-linux/` directory you cloned resides a default `init.lua` which executes `startup.lua` which performs some basic tests of various modules:

```
% nodemcu
NodeMCU/Linux 0.0.6 powered by Lua 5.1, Device ID: 3255662 / 0x31ad6e
   x86_64 Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz (8 cores, 800-3500MHz)
   modules: node tmr file gpio i2c net rtctime sjson bit struct math
starting up...
tmr.now() 26137
tmr.time() 0
tmr.uptime() 0.026159048080444
rtctime 2018/03/09 15:27:16 UTC
node.chipid() 3255662 0x31ad6e
node.flashid() e769a2e7-a4f8-4c2c-86dc-b0a35cc592ef
node.heap() 777887744 767147KiB
file.list() init.lua(64) misc(4096) nodemcu(6766) LICENSE(1082) Makefile(1571) ..(4096) fw(4096) imgs(4096) README.md(4131) tests(4096) startup.lua(3169) examples(4096) LuaNode(4096) modules(4096) .git(4096) .(4096) 
file.stat() with json {"time":{"min":49,"wday":5,"day":9,"yday":67,"year":2018,"sec":33,"hour":9,"mon":3},"is_arch":false,"name":"README.md","is_sys":false,"is_rdonly":false,"is_hidden":false,"is_dir":false,"size":4131}
file.fsinfo() remain 16033.281MiB, used 196257.359MiB, total 223675.238MiB
ffi-test: Hello world!
net-test: connecting to httpbin.org
...
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
I [0.000] dofile ./modules/file/file.lua
I [0.001] dofile ./modules/gpio/gpio.lua
I [0.001] dofile ./modules/i2c/i2c.lua
I [0.002] i2c: 7 interface(s) found: /dev/i2c-0 /dev/i2c-1 /dev/i2c-2 /dev/i2c-3 /dev/i2c-4 /dev/i2c-5 /dev/i2c-6
I [0.002] dofile ./modules/net/net-node.lua
I [0.004] dofile ./modules/rtctime/rtctime.lua
I [0.004] dofile ./modules/sjson/sjson.lua
I [0.007] modules bit, struct built-in added
I [0.008] module math added
NodeMCU/Linux 0.0.6 powered by Lua 5.1, Device ID: 3255662 / 0x31ad6e
   x86_64 Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz (8 cores, 800-3500MHz)
   modules: node tmr file gpio i2c net rtctime sjson bit struct math
I [0.014] execute init.lua
I [0.014] dofile ./init.lua
I [0.015] dofile ./startup.lua
starting up...
tmr.now() 18914
tmr.time() 0
tmr.uptime() 0.018966197967529
rtctime 2018/03/09 15:33:12 UTC
...
..

% cd tests
% nodemcu file01.lua
```

## Detailed Development

See my [Spiritude's Public Notebook: NodeMCU Shell Development](https://spiritdude.wordpress.com/2018/02/26/nodemcu-linux/) which I document more fine-grained state of the development with examples.


Ren&eacute; K. M&uuml;ller<br>
February 2018
