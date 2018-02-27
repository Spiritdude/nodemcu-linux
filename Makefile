NAME="NodeMCU-Linux"
DATE=`date +%F`

all::
	@echo "make requirements install deinstall backup"

requirements::	lua lua_modules luaffi

lua::
	sudo apt -y install luajit lua5.1 luarocks lua5.1-dev

lua_modules::
	sudo luarocks install luafilesystem
	sudo luarocks install lua-periphery
	sudo luarocks install luasocket
	sudo luarocks install luabitop
	sudo luarocks install lua-struct
	sudo luarocks install lunajson
	sudo luarocks install luaunit

luaffi::
	git clone https://github.com/facebook/luaffifb
	cd luaffifb; sudo luarocks make
	sudo rm -rf luaffifb

install::
	install nodemcu /usr/local/bin/nodemcu
	mkdir -p /usr/local/lib/nodemcu
	#install -d modules misc | (cd /usr/local/lib/nodemcu/ && tar xf -)
	tar cf - modules misc | (cd /usr/local/lib/nodemcu/ && tar xf -)

deinstall::
	sudo rm -rf /usr/local/bin/nodemcu /usr/local/lib/nodemcu/


# -- developer only

backup::
	cd ..; tar cfz ${NAME}-${DATE}.tar.gz '--exclude=fw/*' ${NAME}; scp ${NAME}-${DATE}.tar.gz backup:Backup/; mv ${NAME}-${DATE}.tar.gz ~/Backup/; 

dist::
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" opl1:Projects
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" npn1:Projects
	cd ..; rsync -avP ${NAME} "--exclude=fw/*" opz1:Projects

edit::
	dee4 nodemcu *.lua modules/*/*.lua Makefile README.md
