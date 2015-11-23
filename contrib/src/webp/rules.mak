# webp

WEBP_VERSION := 0.4.3
WEBP_URL := http://downloads.webmproject.org/releases/webp/libwebp-$(WEBP_VERSION).tar.gz

$(TARBALLS)/libwebp-$(WEBP_VERSION).tar.gz:
	$(call download,$(WEBP_URL))

.sum-webp: libwebp-$(WEBP_VERSION).tar.gz

webp: libwebp-$(WEBP_VERSION).tar.gz .sum-webp
	$(UNPACK)
	$(UPDATE_AUTOCONFIG)
	$(APPLY) $(SRC)/webp/missing-cpu-feature.patch
	$(MOVE)

.webp: webp
ifdef HAVE_ANDROID
	cd $< && echo "APP_ABI:=$(MY_TARGET_ARCH)" >> Application.mk
	cd $< && ln -s $(shell pwd)/webp $(shell pwd)/webp/jni
	cd $< && ndk-build
	cd $< && mkdir -p $(PREFIX)/lib/
	cd $< && cp obj/local/$(MY_TARGET_ARCH)/libwebp.a $(PREFIX)/lib/
	cd $< && mkdir -p $(PREFIX)/include/webp
	cd $< && cp -a src/webp/*.h $(PREFIX)/include/webp
else
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF)
	cd $< && $(MAKE)
	cd $< && $(MAKE) install
endif
	touch $@
