# chipmunk

CHIPMUNK_VERSION := 6.2.1
CHIPMUNK_URL := https://chipmunk-physics.net/release/Chipmunk-6.x/Chipmunk-$(CHIPMUNK_VERSION).tgz

$(TARBALLS)/chipmunk-$(CHIPMUNK_VERSION).tgz:
	$(call download,$(CHIPMUNK_URL))

.sum-chipmunk: chipmunk-$(CHIPMUNK_VERSION).tgz

chipmunk: chipmunk-$(CHIPMUNK_VERSION).tgz .sum-chipmunk
	$(UNPACK)
	$(MOVE)


.chipmunk: chipmunk toolchain.cmake
	cd $< && $(HOSTVARS_PIC) $(CMAKE) . -DBUILD_DEMOS=off
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
