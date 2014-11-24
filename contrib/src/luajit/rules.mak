# luajit

LUAJIT_VERSION := 2.0.1
LUAJIT_URL := http://luajit.org/download/LuaJIT-$(LUAJIT_VERSION).tar.gz

$(TARBALLS)/luajit-$(LUAJIT_VERSION).tar.gz:
	$(call download,$(LUAJIT_URL))

.sum-luajit: luajit-$(LUAJIT_VERSION).tar.gz

luajit: luajit-$(LUAJIT_VERSION).tar.gz .sum-luajit
	$(UNPACK)
ifeq ($(LUAJIT_VERSION),2.0.1)
	$(APPLY) $(SRC)/luajit/v2.0.1_hotfix1.patch
endif
	$(MOVE)

ifdef HAVE_IOS

ifeq ($(MY_TARGET_ARCH),armv7)
LUAJIT_TARGET_FLAGS="-arch armv7 -isysroot $(IOS_SDK) $(OPTIM)"
LUAJIT_HOST_CC="gcc -m32 -arch i386"
endif

ifeq ($(MY_TARGET_ARCH),armv7s)
LUAJIT_TARGET_FLAGS="-arch armv7s -isysroot $(IOS_SDK) $(OPTIM)"
LUAJIT_HOST_CC="gcc -m32 -arch i386"
endif
endif #endof HAVE_IOS

ifdef HAVE_ANDROID
NDKF=--sysroot=$(ANDROID_NDK)/platforms/$(ANDROID_API)/arch-$(PLATFORM_SHORT_ARCH)
ifeq ($(ANDROID_ABI),armv7)
LUAJIT_LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
endif
endif


.luajit: luajit
ifdef HAVE_ANDROID
	cd $< && $(MAKE) HOST_CC="gcc -m32 $(OPTIM)" CROSS=$(HOST)- TARGET_SYS=Linux TARGET_FLAGS="${NDKF} ${EXTRA_CFLAGS}" TARGET_LDFLAGS=$(LUAJIT_LDFLAGS)
endif
ifdef HAVE_MACOSX
	cd $< && $(HOSTVARS_PIC) $(MAKE) HOST_CC="$(CC)" HOST_CFLAGS="$(CFLAGS)"
endif
ifdef HAVE_IOS
ifeq ($(MY_TARGET_ARCH),armv7)
	cd $< && make HOST_CC=$(LUAJIT_HOST_CC) TARGET_FLAGS=$(LUAJIT_TARGET_FLAGS) TARGET=arm TARGET_SYS=iOS
endif
ifeq ($(MY_TARGET_ARCH),armv7s)
	cd $< && make HOST_CC=$(LUAJIT_HOST_CC) TARGET_FLAGS=$(LUAJIT_TARGET_FLAGS) TARGET=arm TARGET_SYS=iOS
endif
ifeq ($(MY_TARGET_ARCH),i386)
	cd $< && make CC="gcc -m32 -arch i386 $(OPTIM)"
endif
endif
	cd $< && make install PREFIX=$(PREFIX)
	touch $@
