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

The main executable is `nodemcu`, e.g. running on an Orange Pi Lite:

```
% nodemcu
I [0.000] loading modules ('node' and 'tmr' already loaded)
I [0.001] dofile ./modules/file/file.lua
I [0.006] dofile ./modules/gpio/gpio.lua
I [0.011] dofile ./modules/i2c/i2c.lua
I [0.013] i2c: 2 interface(s) found: /dev/i2c-0 /dev/i2c-1
I [0.014] dofile ./modules/rtctime/rtctime.lua
I [0.016] dofile ./modules/sjson/sjson.lua
I [0.037] modules bit, struct built-in added
I [0.038] module math added
NodeMCU/Linux 0.0.3 powered by Lua 5.1, Device ID: 8773060 / 0x85ddc4
   armv7l (4 cores, 480-1200MHz)
   modules: node tmr file gpio i2c rtctime sjson bit struct math
   cpu freq table [MHz]: 60, 120, 240, 312, 408, 480, 504, 528, 576, 600, 624, 648, 672, 720, 768, 816, 864, 912, 960, 1010, 1060, 1100, 1150, 1200, 1250, 1300, 1340, 1440, 1540
I [0.058] execute init.lua
I [0.059] dofile ./init.lua
I [0.059] dofile ./startup.lua
starting up...
tmr.now() 60290
tmr.time() 0
tmr.uptime() 0.060518026351929
rtctime 2018/03/02 13:41:33 UTC
node.chipid() 8773060 0x85ddc4
node.flashid() e4909995-cb78-4f89-bca8-d00bb3b914e1
node.heap() 99151872 97782KiB
file.list() init.lua(64) misc(4096) Makefile(1276) LICENSE(1082) ..(4096) fw(4096) imgs(4096) README.md(3666) .git(4096) startup.lua(1063) modules(4096) nodemcu(4024) tests(4096) examples(4096) .(4096) 
file.stat() with json {"time":{"min":28,"wday":4,"day":1,"yday":59,"year":2018,"sec":44,"hour":8,"mon":3},"is_arch":false,"name":"README.md","is_sys":false,"is_rdonly":false,"is_hidden":false,"is_dir":false,"size":3666}
file.fsinfo() remain 8738.391MiB, used 20639.449MiB, total 29691.949MiB
> 
```

The `>` is the prompt, awaiting console Lua input - abort with CTRL-C twice.


```
% cd tests
% nodemcu file01.lua
```

## Detailed Development

See my [Spiritude's Public Notebook: NodeMCU Shell Development](https://spiritdude.wordpress.com/2018/02/26/nodemcu-linux/) which I document more fine-grained state of the development with examples.


Ren&eacute; K. M&uuml;ller<br>
February 2018
