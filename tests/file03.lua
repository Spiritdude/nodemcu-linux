luaunit = require('luaunit')

for i,v in pairs(file.list()) do
   print(i,v)
end

--luaunit.assertIs(l1,"line 1\n")

--os.exit( luaunit.LuaUnit.run() )

