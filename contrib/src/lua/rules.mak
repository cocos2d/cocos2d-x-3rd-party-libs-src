# Lua 5.1

LUA_VERSION := 5.1.4
LUA_URL := http://www.lua.org/ftp/lua-$(LUA_VERSION).tar.gz

# Reverse priority order
LUA_TARGET := generic
ifdef HAVE_BSD
LUA_TARGET := bsd
endif
ifdef HAVE_LINUX
LUA_TARGET := linux
endif
ifdef HAVE_MACOSX
LUA_TARGET := macosx
endif
ifdef HAVE_IOS
LUA_TARGET := ios
endif
ifdef HAVE_TVOS
LUA_TARGET := tvos
endif
ifdef HAVE_WIN32
LUA_TARGET := mingw
endif
ifdef HAVE_SOLARIS
LUA_TARGET := solaris
endif


$(TARBALLS)/lua-$(LUA_VERSION).tar.gz:
	$(call download,$(LUA_URL))

.sum-lua: lua-$(LUA_VERSION).tar.gz

lua: lua-$(LUA_VERSION).tar.gz .sum-lua
	$(UNPACK)
	$(APPLY) $(SRC)/lua/lua-noreadline.patch
	$(APPLY) $(SRC)/lua/no-dylibs.patch
	$(APPLY) $(SRC)/lua/luac-32bits.patch
	$(APPLY) $(SRC)/lua/no-localeconv.patch
	$(APPLY) $(SRC)/lua/lua-macosx-support.patch
ifdef HAVE_TVOS
	$(APPLY) $(SRC)/lua/lua-no-system.patch
endif

	(cd $(UNPACK_DIR) && \
	sed -e 's%gcc%$(CC)%' \
		-e 's%LDFLAGS=%LDFLAGS=$(LDFLAGS)%' \
		-e 's%CFLAGS= -O2 -Wall $(MYCFLAGS)%CFLAGS=$(CFLAGS)%' \
		-i.orig src/Makefile)

ifdef HAVE_WIN32
	cd $(UNPACK_DIR) && sed -i.orig -e 's/lua luac/lua.exe luac.exe/' Makefile
endif
	cd $(UNPACK_DIR)/src && sed -i.orig \
		-e 's/CC=/#CC=/' \
		-e 's/= *strip/=$(STRIP)/' \
		-e 's/= *ar rcu/= $(AR) rcu/' \
		-e 's/= *ranlib/= $(RANLIB)/' \
		Makefile
	$(MOVE)

.lua: lua
	cd $< && $(HOSTVARS_PIC) $(MAKE) VERBOS=1 $(LUA_TARGET)
ifdef HAVE_WIN32
	cd $</src && $(HOSTVARS) $(MAKE) liblua.a
endif
	cd $< && $(HOSTVARS) $(MAKE) install INSTALL_TOP="$(PREFIX)"
ifdef HAVE_WIN32
	cd $< && $(RANLIB) "$(PREFIX)/lib/liblua.a"
	mkdir -p -- "$(PREFIX)/lib/pkgconfig"
	cp $</etc/lua.pc "$(PREFIX)/lib/pkgconfig/"
endif
ifdef HAVE_CROSS_COMPILE
	cd $</src && $(MAKE) clean && $(MAKE) liblua.a && ranlib liblua.a && $(MAKE) luac
	cp $</src/luac $(PREFIX)/bin
endif
	touch $@
