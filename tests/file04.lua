luaunit = require('luaunit')

table.foreach({'test.txt','..'},function(i,fn) 
   print(fn)
   print(sjson.encode(file.stat(fn)))
end)

--luaunit.assertIs(l1,"line 1\n")

--os.exit( luaunit.LuaUnit.run() )

