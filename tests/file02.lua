fh = file.open("test.txt")
l1 = fh:read("\n")
l2 = fh:read("\n")
fh:close()

assert(l1=="line 1\n")
assert(l2=="line 2\n")

os.exit(0)

