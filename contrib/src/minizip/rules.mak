# minizip

MINIZIP_GITURL := https://github.com/nmoinvaz/minizip.git


$(TARBALLS)/libminizip-git.tar.xz:
	$(call download_git,$(MINIZIP_GITURL),master)

.sum-minizip: libminizip-git.tar.xz
	$(warning $@ not implemented)
	touch $@


minizip: libminizip-git.tar.xz .sum-minizip
	$(UNPACK)
	$(APPLY) $(SRC)/minizip/010-unzip-add-function-unzOpenBuffer.patch
	$(MOVE)

DEPS_minizip = zlib $(DEPS_zlib)

.minizip: minizip
	$(RECONF)
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE) install
	touch $@
