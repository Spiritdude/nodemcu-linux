-- == SJSON Module ==
--
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT License (see LICENSE file)
--
-- Description: 
--    Providing JSON encode/decode facility
-- Notes:
--    Uses lunajson package for now, a true C JSON (sjson) might come later
--
-- History: 
-- 2018/02/27: 0.0.1: sjson.encode() and sjson.decode() work, sjson.decoder()/.encoder() does not yet

local JSON = require("lunajson")

sjson = {
   encoder = function(tbl,opts)
      _syslog.print(_syslog.ERROR,"sjson.encoder() not yet implemented")
      return {}
   end,
   encode = function(tbl,opts)
      return JSON.encode(tbl)
   end,
   decoder = function(opts)
      _syslog.print(_syslog.ERROR,"sjson.encoder() not yet implemented")
      return {}
   end,
   decode = function(str,opts)
      return JSON.decode(str)
   end
}

table.insert(node.modules,'sjson')
return sjson
