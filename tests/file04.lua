luaunit = require('luaunit')

table.foreach({'test.txt','..'},function(i,fn) 
   print(fn)
   print(sjson.encode(file.stat(fn)))
end)

--assert(l1=="line 1\n")

os.exit(0)

