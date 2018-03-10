file.open("test.txt")
t = file.read()
file.close()

assert(t=="line 1\nline 2\nline 3\nline 4\nline 5\n")

os.exit(0)

