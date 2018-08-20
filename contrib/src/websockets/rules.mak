# websockets

WEBSOCKETS_GITURL := https://github.com/warmcat/libwebsockets

$(TARBALLS)/libwebsockets-git.tar.xz:
	$(call download_git,$(WEBSOCKETS_GITURL),v2.4-stable,fe3c115f438cfa4cdf0c6a03d9e61c7f8684135a)

.sum-websockets: libwebsockets-git.tar.xz
	$(warning $@ not implemented)
	touch $@

websockets: libwebsockets-git.tar.xz .sum-websockets
	$(UNPACK)
	$(APPLY) $(SRC)/websockets/remove-werror.patch
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
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DLWS_WITH_LIBUV=0 -DLWS_WITH_SSL=1 -DLWS_WITH_SHARED=0 -DLWS_WITHOUT_TEST_SERVER=1 -DLWS_WITHOUT_TEST_SERVER_EXTPOLL=1 -DLWS_WITHOUT_TEST_PING=1 -DLWS_WITHOUT_TEST_ECHO=1 -DLWS_WITHOUT_TEST_FRAGGLE=1 -DLWS_IPV6=1 $(make_option)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
