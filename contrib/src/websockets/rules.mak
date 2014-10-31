# websockets

WEBSOCKETS_VERSION := v1.3-chrome37-firefox30.zip
WEBSOCKETS_URL := https://github.com/warmcat/libwebsockets/archive/$(WEBSOCKETS_VERSION)

$(TARBALLS)/libwebsockets-1.3-chrome37-firefox30.zip:
	$(call download,$(WEBSOCKETS_URL))

.sum-websockets: libwebsockets-1.3-chrome37-firefox30.zip

websockets: libwebsockets-1.3-chrome37-firefox30.zip .sum-websockets
	$(UNPACK)
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif

DEPS_websockets = zlib $(DEPS_zlib)

DEPS_websockets = openssl $(DEPS_openssl)

.websockets: websockets .zlib .openssl toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DCMAKE_BUILD_TYPE=Release -DLIBWEBSOCKETS_LIBRARIES=websocket
	cd $< && $(MAKE) install
	touch $@
