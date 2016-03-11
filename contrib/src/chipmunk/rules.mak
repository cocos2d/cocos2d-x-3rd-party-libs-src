# chipmunk

CHIPMUNK_VERSION := 7.0.1
CHIPMUNK_URL := https://chipmunk-physics.net/release/Chipmunk-7.x/Chipmunk-$(CHIPMUNK_VERSION).tgz

$(TARBALLS)/Chipmunk-$(CHIPMUNK_VERSION).tgz:
	$(call download,$(CHIPMUNK_URL))

.sum-chipmunk: Chipmunk-$(CHIPMUNK_VERSION).tgz

chipmunk: Chipmunk-$(CHIPMUNK_VERSION).tgz .sum-chipmunk
	$(UNPACK)
	$(MOVE)


.chipmunk: chipmunk toolchain.cmake
	$(APPLY) $(SRC)/chipmunk/cocos2d.patch
	cd $< && $(HOSTVARS_PIC) $(CMAKE) . -DBUILD_DEMOS=off
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
