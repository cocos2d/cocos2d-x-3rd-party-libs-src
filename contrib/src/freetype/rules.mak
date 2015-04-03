# freetype

FREETYPE2_VERSION := 2.5.5
FREETYPE2_URL := $(SF)/freetype/freetype2/$(FREETYPE2_VERSION)/freetype-$(FREETYPE2_VERSION).tar.gz

$(TARBALLS)/freetype-$(FREETYPE2_VERSION).tar.gz:
	$(call download,$(FREETYPE2_URL))

.sum-freetype: freetype-$(FREETYPE2_VERSION).tar.gz

freetype: freetype-$(FREETYPE2_VERSION).tar.gz .sum-freetype
	$(UNPACK)
	$(call pkg_static, "builds/unix/freetype2.in")
	$(MOVE)

DEPS_freetype = zlib $(DEPS_zlib)

.freetype: freetype
	sed -i.orig s/-ansi// $</builds/unix/configure
	cd $< && GNUMAKE=$(MAKE) $(HOSTVARS) ./configure --with-harfbuzz=no --with-zlib=yes --without-png --with-bzip2=no $(HOSTCONF)
	cd $< && $(MAKE) && $(MAKE) install
	touch $@
