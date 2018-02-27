-- == File Module ==
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
--
-- License: MIT (see LICENSE file)
--
-- Description:
--    basic file operations, alike io with some slight alterations like file.read()
--
-- History:
-- 2018/02/27: 0.0.3: fh:*() cleaner setup using file.*(self,[...]) and argument checking if file.read() or fh:read() is called
-- 2018/02/27: 0.0.2: file.open(), file.read() and file.close() work, fh:read() and fh:*() do not yet, file.stat() and file.list() work
-- 2018/02/21: 0.0.1: first version, mostly using io.open():xyz convention, but needs to be tested for proper compatibility

local lfs = require("lfs")
local os = require("os")

file = {
   _VERSION = '0.0.3'
}

file.chdir = function(d)      -- Change current directory (and drive).
   return lfs.chdir(d)
end

file.exists = function(fn)    -- Determines whether the specified file exists.
   local f = io.open(fn,"r")
   if f then io.close(f) end
   return f and true or false
end

file.format = function()      -- Format the file system.
   _syslog.print(_syslog.ERROR,"file.format() not implemented")
end

file.fscfg = function()       -- Returns the flash address and physical size of the file system area, in bytes.
   return 0,0
end

file.fsinfo = function()      -- Return size information for the file system.
   return 0
end

file.list = function(d)       -- Lists all files in the file system.
   local fl = { }
   for f in lfs.dir(d or ".") do
      table.insert(fl,f)
   end
   return fl
end

file.mount = function()       -- Mounts a FatFs volume on SD card.
   _syslog.print(_syslog.ERROR,"file.mount() not implemented yet")
end

file.on = function()          -- Registers callback functions.
   _syslog.print(_syslog.ERROR,"file.on() not implemented yet")
end

file.open = function(fn,m) 
   file._fh = io.open(fn,m)
   if file._fh then
      return {
         _fh = file._fh,
         read = file.read,          
         readline = file.readline,
         write = file.write,
         writeline = file.writeline,
         flush = file.flush,
         close = file.close,
         seek = file.seek
      }
   end
   return nil
end

file.remove = function(fn)    -- Remove a file from the file system.
   return os.remove(fn)
end

file.rename = function(fno,fnn)  -- Renames a file.
   return os.rename(fno,fnn)
end

file.stat = function(fn)      -- Get attribtues of a file or directory in a table.
   local st = lfs.attributes(fn)
   local s = { }
   if st then
      s.size = st.size or null
      s.name = fn
      s.is_dir = st.mode == 'directory'
      s.is_rdonly = false
      s.is_hidden = false
      s.is_sys = false
      s.is_arch = false
      s.time = rtctime.epoch2cal(st.modification)
      return s
   else
      return st
   end
end

-- Basic model: In the basic model there is max one file opened at a time.
-- Object model: Files are represented by file objects which are created by file.

file.close = function(self) 
   (self and self._fh or file._fh):close()
end

file.flush = function(self)       -- Flushes any pending writes to the file system, ensuring no data is lost on a restart.
   (self and self._fh or file._fh):flush()
end

file.read = function(self,sep)
   local fh
   if type(self)=='table' then      -- called as f:read(sep)
      --print("fh:read",type(self),self,sep)
      fh = self._fh
   else                             -- called as file.read(sep)
      --print("file.read",type(self),self,sep)
      fh = file._fh 
      sep = self
   end
   if not sep then
      return fh:read("*all")
   elseif type(sep)=='number' then
      return fh:read(sep)
   else 
      local c 
      local b
      repeat
         c = fh:read(1)
         if c then
            b = (b or "") .. (c or '')
         end
      until c == sep or not c
      return b
   end
end

file.readline = function(self) 
   return (self._fh or file._fh):read("*line") 
end
                              
file.seek = function(...)     -- Sets and gets the file position, measured from the beginning of the file, to the position given by offset plus a base specified by the string whence.
   local fh = type(arg[1])=='table' and table.remove(arg,1)._fh or file._fh
   local w, o = arg[1], arg[2]
   return fh:seek(w,o)
end

file.write = function(self,s)       -- Write a string to the open file.
   local fh
   if type(self)=='table' then
      fh = self._fh
   else 
      fh = file._fh
      s = self
   end
   return fh:write(s)
end

file.writeline = function(self,s)   -- Write a string to the open file and append '\n' at the end.
   local fh
   if type(self)=='table' then
      fh = self._fh
   else 
      fh = file._fh
      s = self
   end
   return fh:write(s.."\n")
end

table.insert(node.modules,'file')

return file;
