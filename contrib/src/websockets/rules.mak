# websockets

WEBSOCKETS_VERSION := v1.3-chrome37-firefox30.zip
WEBSOCKETS_URL := https://github.com/warmcat/libwebsockets/archive/$(WEBSOCKETS_VERSION)

$(TARBALLS)/libwebsockets-1.3-chrome37-firefox30.zip:
	$(call download,$(WEBSOCKETS_URL))

.sum-websockets: libwebsockets-1.3-chrome37-firefox30.zip

websockets: libwebsockets-1.3-chrome37-firefox30.zip .sum-websockets
	$(UNPACK)
# ONLY FOR DEBUG!
# uncomment this line if you want to accept self signed cerdificates
#	$(APPLY) $(SRC)/websockets/websocket-ssl-self-signed-cert.patch
ifdef HAVE_ANDROID
	$(APPLY) $(SRC)/websockets/websocket_android.patch
ifeq ($(MY_TARGET_ARCH),arm64-v8a)
	$(APPLY) $(SRC)/websockets/android-arm64.patch
endif
endif
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif


DEPS_websockets = zlib $(DEPS_zlib)
DEPS_websockets = openssl $(DEPS_openssl)

ifdef HAVE_TVOS
	make_option=-DLWS_WITHOUT_DAEMONIZE=1
endif

.websockets: websockets .zlib .openssl toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DLWS_WITH_SSL=1 -DLWS_WITHOUT_TEST_PING=1 -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=1 $(make_option)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
