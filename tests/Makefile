SOURCES=$(wildcard *.lua)
TESTS=$(patsubst %.lua, %.lua.test, $(SOURCES))

all::	${TESTS}

%.lua.test:	%.lua
	@nodemcu -s $< || echo "$< failed" 

