# NodeMCU/Linux

## Introduction

<img src="https://raw.githubusercontent.com/Spiritdude/nodemcu-linux/master/imgs/nodemcu-linux.png" align=right>

**NodeMCU/Linux** aims to implement the NodeMCU API as known by [NodeMCU/ESP8266](https://github.com/nodemcu/nodemcu-firmware) or aka "NodeMCU firmware", to additionally support

- **Raspberry Pi** (EUR 35) and **RPi Zero** (EUR 5-10) running [Raspbian](https://www.raspberrypi.org/downloads/raspbian/)
- **NanoPi series**, like NanoPi Neo (EUR 8-30) with Allwinner H2 & H3 running [Armbian](https://armbian.org)
- **Orange Pi**, like Orange Pi Zero, Orange Pi Lite (EUR 6-30) series with Allwinner H2 & H3 running [Armbian](https://armbian.org)
- essentially any device which runs a Debian-based Linux distro, and preferably with GPIO, I2C, SPI facility

The idea is to implement majority of the base modules in Lua itself, with few hocks with FFI (either `luajit` or `luaffifb` module). 

## Current State

Check out the [NodeMCU/Linux Wiki](https://github.com/Spiritdude/nodemcu-linux/wiki) with current state of the base modules, an incomplete summary:
- `node`: mostly implemented
- `tmr`: just `tmr.now()`, `tmr.time()` and `tmr.uptime()` implemented, `tmr:*()` missing
- `file`: basic operations implemented but mostly untested
- `rtctime`: implemented
- `gpio`: partially implemented but entirely untested
- `i2c`: code skeleton, far away to be functional
- `bit`: built-in
- `math`: built-in
- `sjson`: built-in with `lunajson`

running with Lua 5.1 (`lua5.1`)

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

The main executable is `nodemcu`:

```
% nodemcu
I [0.000] loading modules ('node' and 'tmr' already loaded)
I [0.001] dofile ./modules/file/file.lua
I [0.003] dofile ./modules/gpio/gpio.lua
I [0.005] dofile ./modules/i2c/i2c.lua
I [0.005] i2c: no interface found (or limited permissions)
I [0.006] dofile ./modules/rtctime/rtctime.lua
I [0.008] dofile ./modules/sjson/sjson.lua
I [0.014] modules bit, struct built-in added
I [0.014] module math added
NodeMCU/Linux 0.0.3 powered by Lua 5.1, Device ID: 12285967 / 0xbb780f
   x86_64 Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz (8 cores, 800-3500MHz)
   modules: node tmr file gpio i2c rtctime sjson bit struct math
I [0.030] execute init.lua
I [0.030] dofile ./init.lua
I [0.031] dofile ./startup.lua
starting up...
tmr.now() 30842
tmr.time() 0
tmr.uptime() 0.030865907669067
rtctime 2018/02/27 11:44:07 UTC
node.chipid() 12285967 0xbb780f
node.heap() 2224451584 2193739KiB
file.list() nodemcu, LICENSE, Makefile, fw, modules, README.md, init.lua, imgs, misc, .git, startup.lua, examples, .., tests, .
file.stat() with json {"time":{"min":43,"wday":2,"day":27,"yday":57,"year":2018,"sec":39,"hour":11,"mon":2},"is_arch":false,"name":"README.md","is_sys":false,"is_rdonly":false,"is_hidden":false,"is_dir":false,"size":2205}
> 
```

The `>` is the prompt, awaiting console Lua input - abort with CTRL-C twice.

```
% nodemcu tests/file01.lua
```

## Detailed Development

See [NodeMCU Shell Development](https://spiritdude.wordpress.com/2018/02/26/nodemcu-linux/) which I document more fine-grained state of the development with examples.


Ren&eacute; K. M&uuml;ller<br>
February 2018
