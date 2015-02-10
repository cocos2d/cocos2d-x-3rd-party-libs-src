# cjson

CJSON_GITURL := https://github.com/mpx/lua-cjson.git


$(TARBALLS)/libcjson-git.tar.xz:
	$(call download_git,$(CJSON_GITURL),master,4bc5e91)

.sum-cjson: libcjson-git.tar.xz
	$(warning $@ not implemented)
	touch $@


cjson: libcjson-git.tar.xz .sum-cjson
	$(UNPACK)
	$(MOVE)


.cjson: cjson
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE) install
	touch $@
