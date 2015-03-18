# luasocket

LUASOCKET_GITURL := https://github.com/andyque/luasocket.git


$(TARBALLS)/libluasocket-git.tar.xz:
	$(call download_git,$(LUASOCKET_GITURL),v3.0)

.sum-luasocket: libluasocket-git.tar.xz
	$(warning $@ not implemented)
	touch $@


luasocket: libluasocket-git.tar.xz .sum-luasocket
	$(UNPACK)
	$(APPLY) $(SRC)/luasocket/delete-makefile.patch
	$(MOVE)

DEPS_luasocket = luajit $(DEPS_luajit)

.luasocket: luasocket toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DLUA_INCLUDE_DIR=$(PREFIX)/include/luajit-2.0 -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
