file.open("test.txt")
l1 = file.read("\n")
l2 = file.read("\n")
file.close()

assert(l1=="line 1\n")
assert(l2=="line 2\n")

os.exit(0)

