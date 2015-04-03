# chipmunk

CHIPMUNK_VERSION := 6.2.2
CHIPMUNK_URL := http://chipmunk-physics.net/release/Chipmunk-6.x/Chipmunk-$(CHIPMUNK_VERSION).tgz

$(TARBALLS)/Chipmunk-$(CHIPMUNK_VERSION).tgz:
	$(call download,$(CHIPMUNK_URL))

.sum-chipmunk: Chipmunk-$(CHIPMUNK_VERSION).tgz

chipmunk: Chipmunk-$(CHIPMUNK_VERSION).tgz .sum-chipmunk
	$(UNPACK)
	$(MOVE)


.chipmunk: chipmunk toolchain.cmake
	cd $< && $(HOSTVARS_PIC) $(CMAKE) . -DBUILD_DEMOS=off
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
