# bullet

BULLET_GITURL := https://github.com/bulletphysics/bullet3

$(TARBALLS)/libbullet-git.tar.xz:
	$(call download_git,$(BULLET_GITURL),master,19f999a)

.sum-bullet: libbullet-git.tar.xz

bullet: libbullet-git.tar.xz .sum-bullet
	$(UNPACK)
	$(APPLY) $(SRC)/bullet/cocos2d.patch
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif


.bullet: bullet toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DCMAKE_BUILD_TYPE=Release -DBUILD_CPU_DEMOS=OFF -DBUILD_EXTRAS=OFF -DBUILD_UNIT_TESTS=OFF
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
