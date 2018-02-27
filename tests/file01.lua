luaunit = require('luaunit')

file.open("test.txt")
l1 = file.read("\n")
l2 = file.read("\n")
file.close()

luaunit.assertIs(l1,"line 1\n")
luaunit.assertIs(l2,"line 2\n")

--os.exit( luaunit.LuaUnit.run() )

