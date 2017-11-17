# box2d

BOX2D_GITURL := https://github.com/erincatto/Box2D

$(TARBALLS)/libbox2d-git.tar.xz:
	$(call download_git,$(BOX2D_GITURL),master,f655c603ba9d83f07fc566d38d2654ba35739102)

box2d: libbox2d-git.tar.xz
	$(UNPACK)
	$(APPLY) $(SRC)/box2d/cocos2d.patch
	$(MOVE)

ifdef HAVE_ANDROID
BOX2D_EXFLAGS = -fPIC -fpermissive
endif

ifdef HAVE_LINUX
BOX2D_EXFLAGS += -fPIC
endif


.box2d: box2d toolchain.cmake
	cd $< &&  CXXFLAGS="$(CXXFLAGS) $(BOX2D_EXFLAGS) -std=c++11" CFLAGS="$(CFLAGS) $(BOX2D_EXFLAGS)" $(CMAKE)
	cd $< && $(MAKE)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
