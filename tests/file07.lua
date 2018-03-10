file.remove("test2.txt")

fh = file.open("test.txt")
t = fh:read()
fh:close()

fw = file.open("test2.txt","w")
fw:write(t)
fw:close()

fh = file.open("test2.txt")
t0 = fh:read()
fh:close()

assert(t0=="line 1\nline 2\nline 3\nline 4\nline 5\n")

os.exit(0)

