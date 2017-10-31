# box2d

BOX2D_VERSION := 2.3.1
BOX2D_URL := https://codeload.github.com/erincatto/Box2D/tar.gz/v$(BOX2D_VERSION)

$(TARBALLS)/Box2D-${BOX2D_VERSION}.tar.gz:
	$(call download,$(BOX2D_URL))

.sum-box2d: Box2D-${BOX2D_VERSION}.tar.gz

box2d: Box2D-${BOX2D_VERSION}.tar.gz .sum-box2d
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
	cd $< &&  CXXFLAGS="$(CXXFLAGS) $(BOX2D_EXFLAGS)" CFLAGS="$(CFLAGS) $(BOX2D_EXFLAGS)" $(CMAKE)
	cd $< && $(MAKE)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
