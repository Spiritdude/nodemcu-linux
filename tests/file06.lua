luaunit = require('luaunit')

fh = file.open("test.txt")
t = fh:read()
fh:close()

luaunit.assertIs(t,"line 1\nline 2\nline 3\nline 4\nline 5\n")

--os.exit( luaunit.LuaUnit.run() )

