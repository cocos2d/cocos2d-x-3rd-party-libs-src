# luajit

LUAJIT_VERSION := 2.1.0-beta2
LUAJIT_URL := http://luajit.org/download/LuaJIT-$(LUAJIT_VERSION).tar.gz

$(TARBALLS)/luajit-$(LUAJIT_VERSION).tar.gz:
	$(call download,$(LUAJIT_URL))

.sum-luajit: luajit-$(LUAJIT_VERSION).tar.gz

luajit: luajit-$(LUAJIT_VERSION).tar.gz .sum-luajit
	$(UNPACK)
ifeq ($(LUAJIT_VERSION),2.0.1)
	$(APPLY) $(SRC)/luajit/v2.0.1_hotfix1.patch
endif
	$(APPLY) $(SRC)/luajit/lua-log-size.patch
	$(MOVE)

ifdef HAVE_IOS
ifeq ($(MY_TARGET_ARCH),arm64)
LUAJIT_HOST_CC="gcc -m64 $(OPTIM)"
else
LUAJIT_HOST_CC="gcc -m32 $(OPTIM)"
endif

LUAJIT_TARGET_FLAGS="-isysroot $(IOS_SDK) -Qunused-arguments $(EXTRA_CFLAGS) $(EXTRA_LDFLAGS) $(ENABLE_BITCODE)"
LUAJIT_CROSS_HOST=$(xcrun cc)
endif #endof HAVE_IOS

ifdef HAVE_ANDROID
ifeq ($(MY_TARGET_ARCH),arm64-v8a)
LUAJIT_HOST_CC="gcc -m64 $(OPTIM)"
else
LUAJIT_HOST_CC="gcc -m32 $(OPTIM)"
endif

NDKF=--sysroot=$(ANDROID_NDK)/platforms/$(ANDROID_API)/arch-$(PLATFORM_SHORT_ARCH)
LUAJIT_TARGET_FLAGS="${NDKF} ${EXTRA_CFLAGS} ${EXTRA_LDFLAGS}"
LUAJIT_CROSS_HOST=$(HOST)-
endif


.luajit: luajit
ifdef HAVE_ANDROID
	cd $< && $(MAKE) HOST_CC=$(LUAJIT_HOST_CC) CROSS=$(LUAJIT_CROSS_HOST) TARGET_SYS=Android TARGET_FLAGS=$(LUAJIT_TARGET_FLAGS) HOST_SYS=Linux
endif

ifdef HAVE_MACOSX
	cd $< && $(HOSTVARS_PIC) $(MAKE) HOST_CC="$(CC)" HOST_CFLAGS="$(CFLAGS)"
endif

ifdef HAVE_IOS
	cd $< && make HOST_CC=$(LUAJIT_HOST_CC) CROSS=$(LUAJIT_CROSS_HOST) TARGET_SYS=iOS  TARGET_FLAGS=$(LUAJIT_TARGET_FLAGS)
endif
	cd $< && make install PREFIX=$(PREFIX)
	touch $@
