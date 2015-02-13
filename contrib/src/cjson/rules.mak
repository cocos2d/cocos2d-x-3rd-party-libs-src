# cjson

CJSON_GITURL := https://github.com/mpx/lua-cjson.git


$(TARBALLS)/libcjson-git.tar.xz:
	$(call download_git,$(CJSON_GITURL),master,4bc5e91)

.sum-cjson: libcjson-git.tar.xz
	$(warning $@ not implemented)
	touch $@


cjson: libcjson-git.tar.xz .sum-cjson
	$(UNPACK)
	$(APPLY) $(SRC)/cjson/cmake-patch.patch
	$(MOVE)

# DEPS_cjson = lua $(DEPS_lua)

.cjson: cjson toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DUSE_INTERNAL_FPCONV=1 -DLUA_INCLUDE_DIR=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
