luaunit = require('luaunit')

fh = file.open("test.txt")
l1 = fh:read("\n")
l2 = fh:read("\n")
fh:close()

luaunit.assertIs(l1,"line 1\n");
luaunit.assertIs(l2,"line 2\n");

--os.exit( luaunit.LuaUnit.run() )

