# ZLIB
ZLIB_VERSION := 1.2.8
ZLIB_URL := $(SF)/libpng/zlib-$(ZLIB_VERSION).tar.gz

#FIXME: we don't want to use scripts to determine which libraries should be
#       included, because there is bug in cross compile

# PKGS += zlib
# ifeq ($(call need_pkg,"zlib"),)
# PKGS_FOUND += zlib
# endif

ifeq ($(shell uname),Darwin) # zlib tries to use libtool on Darwin
ifdef HAVE_CROSS_COMPILE
ZLIB_CONFIG_VARS=CHOST=$(HOST)
endif
endif

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif

$(TARBALLS)/zlib-$(ZLIB_VERSION).tar.gz:
	$(call download,$(ZLIB_URL))

.sum-zlib: zlib-$(ZLIB_VERSION).tar.gz

zlib: zlib-$(ZLIB_VERSION).tar.gz .sum-zlib
	$(UNPACK)
	$(MOVE)

.zlib: zlib
	cd $< && $(HOSTVARS) $(ZLIB_CONFIG_VARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" ./configure --prefix=$(PREFIX) --static
	cd $< && $(MAKE) install
	touch $@
