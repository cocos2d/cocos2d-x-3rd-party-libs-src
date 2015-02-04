# xxhash

XXHASH_GITURL := https://github.com/andyque/xxHash.git

$(TARBALLS)/xxhash-git.tar.xz:
	$(call download_git,$(XXHASH_GITURL),master)


.sum-xxhash: xxhash-git.tar.xz
	$(warning $@ not implemented)
	touch $@

xxhash: xxhash-git.tar.xz .sum-xxhash
	$(UNPACK)
	$(MOVE)

.xxhash: xxhash toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} 
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
