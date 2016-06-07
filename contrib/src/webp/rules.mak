# webp

WEBP_VERSION := 0.5.0
WEBP_URL := http://downloads.webmproject.org/releases/webp/libwebp-$(WEBP_VERSION).tar.gz

$(TARBALLS)/libwebp-$(WEBP_VERSION).tar.gz:
	$(call download,$(WEBP_URL))

.sum-webp: libwebp-$(WEBP_VERSION).tar.gz

ifdef HAVE_ANDROID
ifeq ($(MY_TARGET_ARCH),armeabi-v7a)
	mkdir -p $(PREFIX)/lib
	cp $(PREFIX)/../../src/webp/libcpufeatures.a $(PREFIX)/lib/
endif
endif

webp: libwebp-$(WEBP_VERSION).tar.gz .sum-webp
	$(UNPACK)
	$(UPDATE_AUTOCONFIG)
	$(APPLY) $(SRC)/webp/missing-cpu-feature.patch
	$(MOVE)

.webp: webp
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE)
	cd $< && $(MAKE) install
	touch $@
