# OPENSSL
OPENSSL_VERSION := 1.0.1l
OPENSSL_URL := https://www.openssl.org/source/openssl-$(OPENSSL_VERSION).tar.gz


ifdef HAVE_MACOSX
ifeq ($(MY_TARGET_ARCH),x86_64)
OPENSSL_CONFIG_VARS="darwin64-x86_64-cc"
OPENSSL_ARCH=-m64
endif

ifeq ($(MY_TARGET_ARCH),i386)
OPENSSL_CONFIG_VARS="BSD-generic32"
OPENSSL_ARCH=-m32
endif
endif

ifdef HAVE_LINUX
ifeq ($(MY_TARGET_ARCH),x86_64)
OPENSSL_CONFIG_VARS="linux-x86_64"
OPENSSL_ARCH=-m64
endif

ifeq ($(MY_TARGET_ARCH),i386)
OPENSSL_CONFIG_VARS="linux-generic32"
OPENSSL_ARCH=-m32
endif
endif

ifdef HAVE_TIZEN
OPENSSL_COMPILER=os/compiler:arm-linux-gnueabi-
endif

ifdef HAVE_ANDROID
OPENSSL_COMPILER=os/compiler:$(HOST)
endif

ifdef HAVE_IOS
ifeq ($(MY_TARGET_ARCH),armv7)
OPENSSL_CONFIG_VARS="BSD-generic32"
endif

ifeq ($(MY_TARGET_ARCH),i386)
OPENSSL_CONFIG_VARS="BSD-generic32"
endif

ifeq ($(MY_TARGET_ARCH),arm64)
OPENSSL_CONFIG_VARS="BSD-generic64"
endif
ifeq ($(MY_TARGET_ARCH),armv7s)
OPENSSL_CONFIG_VARS="BSD-generic32"
endif
ifeq ($(MY_TARGET_ARCH),x86_64)
OPENSSL_CONFIG_VARS="darwin64-x86_64-cc"
endif
endif

ifdef HAVE_TVOS
ifeq ($(MY_TARGET_ARCH),arm64)
OPENSSL_CONFIG_VARS="BSD-generic64"
endif
ifeq ($(MY_TARGET_ARCH),x86_64)
OPENSSL_CONFIG_VARS="darwin64-x86_64-cc"
endif
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
	cd $< && $(HOSTVARS_PIC)  ./Configure $(OPENSSL_CONFIG_VARS)  --prefix=$(PREFIX) $(OPENSSL_COMPILER) ${OPENSSL_ARCH}
ifdef HAVE_IOS
	cd $< && perl -i -pe "s|^CC= xcrun clang|CC= xcrun cc -arch ${MY_TARGET_ARCH} -miphoneos-version-min=6.0 |g" Makefile
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${IOS_SDK} ${OPTIM} -fembed-bitcode |g" Makefile
endif
ifdef HAVE_TVOS
	cd $< && perl -i -pe "s|^CC= xcrun clang|CC= xcrun cc -arch ${MY_TARGET_ARCH} |g" Makefile
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= -DHAVE_FORK=0 -isysroot ${TVOS_SDK} ${OPTIM} |g" Makefile
endif
ifdef HAVE_LINUX
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= ${EXTRA_CFLAGS} ${OPTIM} |g" Makefile
endif
ifdef HAVE_MACOSX
	cd $< && perl -i -pe "s|^CC= xcrun clang|CC= xcrun cc -arch ${MY_TARGET_ARCH} -mmacosx-version-min=10.7 |g" Makefile
	cd $< && perl -i -pe "s|^CFLAG= (.*)|CFLAG= -isysroot ${MACOSX_SDK} ${OPTIM} ${OPENSSL_ARCH} |g" Makefile
endif
	cd $< && $(MAKE) install
	touch $@
