# luajit

LUAJIT_VERSION := 2.0.1
LUAJIT_URL := http://luajit.org/download/LuaJIT-$(LUAJIT_VERSION).tar.gz

$(TARBALLS)/luajit-$(LUAJIT_VERSION).tar.gz:
	$(call download,$(LUAJIT_URL))

.sum-luajit: luajit-$(LUAJIT_VERSION).tar.gz

luajit: luajit-$(LUAJIT_VERSION).tar.gz .sum-luajit
	$(UNPACK)
	$(MOVE)


ifdef HAVE_MACOSX
config_var="gcc -m64 -O3 -DNDEBUG -arch x86_64"
endif

.luajit: luajit
	cd $< && perl -i -pe "s|/usr/local|$(PREFIX)|g" Makefile
	cd $< && $(MAKE) HOST_CC="$(CC)" HOST_CFLAGS="$(CFLAGS)"
	cd $< && $(MAKE) install
	touch $@
