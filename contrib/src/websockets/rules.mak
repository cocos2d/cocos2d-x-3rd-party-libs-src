# websockets

WEBSOCKETS_VERSION := v1.3-chrome37-firefox30.zip
WEBSOCKETS_URL := https://github.com/warmcat/libwebsockets/archive/$(WEBSOCKETS_VERSION)

$(TARBALLS)/libwebsockets-1.3-chrome37-firefox30.zip:
	$(call download,$(WEBSOCKETS_URL))

.sum-websockets: libwebsockets-1.3-chrome37-firefox30.zip

websockets: libwebsockets-1.3-chrome37-firefox30.zip .sum-websockets
	$(UNPACK)
ifdef HAVE_ANDROID
	$(APPLY) $(SRC)/websockets/websocket_android.patch
endif
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif

#FIXME: we need to pass __ANDROID__ to cflags
# ifdef HAVE_ANDROID
# EX_ECFLAGS = -D__ANDROID__
# endif

DEPS_websockets = zlib $(DEPS_zlib)

.websockets: websockets .zlib toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DLWS_WITH_SSL=0 -DLWS_WITHOUT_TEST_PING=1
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
