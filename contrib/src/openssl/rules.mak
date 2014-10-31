# OPENSSL
OPENSSL_VERSION := 1.0.1j
OPENSSL_URL := https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz

#FIXME: we don't want to use scripts to determine which libraries should be
#       included, because there is bug in cross compile

# PKGS += openssl
# ifeq ($(call need_pkg,"openssl"),)
# PKGS_FOUND += openssl
# endif

# ifeq ($(shell uname),Darwin) # openssl tries to use libtool on Darwin
# ifdef HAVE_CROSS_COMPILE
# ZLIB_CONFIG_VARS=CHOST=$(HOST)
# endif
# endif

$(TARBALLS)/openssl-$(OPENSSL_VERSION).tar.gz:
	$(call download,$(OPENSSL_URL))

.sum-openssl: openssl-$(OPENSSL_VERSION).tar.gz

openssl: openssl-$(OPENSSL_VERSION).tar.gz .sum-openssl
	$(UNPACK)
	$(MOVE)

.openssl: openssl
	cd $< && $(HOSTVARS) ./config  no-shared --prefix=$(PREFIX)
	cd $< && $(MAKE) $(HOSTVARS)
	cd $< && $(MAKE) install
	touch $@
