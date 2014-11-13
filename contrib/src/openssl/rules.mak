# OPENSSL
OPENSSL_VERSION := 1.0.1j
OPENSSL_URL := https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz

#FIXME: we don't want to use scripts to determine which libraries should be
#       included, because there is bug in cross compile

# PKGS += openssl
# ifeq ($(call need_pkg,"openssl"),)
# PKGS_FOUND += openssl
# endif

ifeq ($(shell uname),Darwin)
OPENSSL_CONFIG_VARS=darwin64-x86_64-cc
endif

ifdef HAVE_TIZEN
OPENSSL_COMPILER=os/compiler:arm-linux-gnueabi-
endif

ifdef HAVE_ANDROID
OPENSSL_COMPILER=os/compiler:$(HOST)
endif

ifeq ($(IOS_ARCH),armv7)
OPENSSL_CONFIG_VARS="BSD-generic32"
endif

ifeq ($(IOS_ARCH),i386)
OPENSSL_CONFIG_VARS="BSD-generic32"
endif

ifeq ($(IOS_ARCH),arm64)
OPENSSL_CONFIG_VARS="BSD-generic64"
endif

$(TARBALLS)/openssl-$(OPENSSL_VERSION).tar.gz:
	$(call download,$(OPENSSL_URL))

.sum-openssl: openssl-$(OPENSSL_VERSION).tar.gz

openssl: openssl-$(OPENSSL_VERSION).tar.gz .sum-openssl
	$(UNPACK)
ifdef HAVE_TIZEN
	$(APPLY) $(SRC)/openssl/tizen.patch
endif
	$(MOVE)

.openssl: openssl
	cd $< && $(HOSTVARS)  ./Configure $(OPENSSL_CONFIG_VARS)  --prefix=$(PREFIX) $(OPENSSL_COMPILER)
ifdef HAVE_IOS
	cd $< && perl -i -pe "s|^CC= xcrun clang|CC= xcrun cc -arch ${IOS_ARCH} -miphoneos-version-min=6.0 |g" Makefile
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${IOS_SDK} ${OPTIM} |g" Makefile
endif
ifdef HAVE_ANDROID
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= ${ANDROID_ARCH} ${OPTIM} |g" Makefile
endif
	cd $< && $(MAKE) install
	touch $@
