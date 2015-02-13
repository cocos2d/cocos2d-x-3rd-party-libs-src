# box2d

BOX2D_VERSION := 2.3.0
BOX2D_URL := https://github.com/andyque/Box2D.git

$(TARBALLS)/libbox2d-git.tar.xz:
	$(call download_git,$(BOX2D_URL),master)

.sum-box2d: libbox2d-git.tar.xz
	$(warning $@ not implemented)
	touch $@

box2d: libbox2d-git.tar.xz .sum-box2d
	$(UNPACK)
	$(MOVE)


.box2d: box2d toolchain.cmake
	cd $</Box2D && $(HOSTVARS_PIC) $(CMAKE) . -DBOX2D_BUILD_EXAMPLES=0
	cd $</Box2D && $(MAKE) VERBOSE=1 install
	touch $@
