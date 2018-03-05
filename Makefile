NAME="NodeMCU-Linux"
DATE=`date +%F`

all::
	@echo "make requirements install deinstall backup"

requirements::	lua luanode lua_modules luaffi

lua::
	sudo apt -y install luajit lua5.1 luarocks lua5.1-dev 

luanode:
	sudo apt -y install cmake libboost-dev libboost-system-dev libboost-date-time-dev libboost-thread-dev
	rm -rf LuaNode
	git clone https://github.com/ignacio/LuaNode
	cd LuaNode/build; cmake ..; make
	sudo cp LuaNode/build/luanode /usr/bin/
	rm -rf LuaNode
	
lua_modules::
	sudo luarocks install luafilesystem
	sudo luarocks install lua-periphery
	sudo luarocks install luasocket
	sudo luarocks install luabitop
	sudo luarocks install lua-struct
	sudo luarocks install lunajson
	sudo luarocks install luaunit

luaffi::
	sudo rm -rf luaffifb
	git clone https://github.com/facebook/luaffifb
	cd luaffifb; sudo luarocks make
	sudo rm -rf luaffifb

install::
	install nodemcu /usr/local/bin/nodemcu
	mkdir -p /usr/local/lib/nodemcu
	tar cf - modules misc | (cd /usr/local/lib/nodemcu/ && tar xf -)

deinstall::
	sudo rm -rf /usr/local/bin/nodemcu /usr/local/lib/nodemcu/


# -- developer only

backup::
	cd ..; tar cfz ${NAME}-${DATE}.tar.gz '--exclude=fw/*' ${NAME}; scp ${NAME}-${DATE}.tar.gz backup:Backup/; mv ${NAME}-${DATE}.tar.gz ~/Backup/; 

dist::
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" "--exclude=LuaNode/*" opl1:Projects
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" "--exclude=LuaNode/*" npn1:Projects
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" "--exclude=LuaNode/*" opz1:Projects

edit::
	dee4 nodemcu *.lua modules/*/*.lua Makefile README.md
