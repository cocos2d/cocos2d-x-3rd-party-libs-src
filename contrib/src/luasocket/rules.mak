# luasocket

LUASOCKET_GITURL := https://github.com/andyque/luasocket.git


$(TARBALLS)/libluasocket-git.tar.xz:
	$(call download_git,$(LUASOCKET_GITURL),v3.0)

.sum-luasocket: libluasocket-git.tar.xz
	$(warning $@ not implemented)
	touch $@


luasocket: libluasocket-git.tar.xz .sum-luasocket
	$(UNPACK)
	$(MOVE)

# DEPS_luasocket = lua $(DEPS_lua)

.luasocket: luasocket toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DLUA_INCLUDE_DIR=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
