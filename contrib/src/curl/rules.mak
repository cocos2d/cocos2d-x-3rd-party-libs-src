# curl

CURL_VERSION := 7.26.0
CURL_URL :=  http://curl.haxx.se/download/curl-$(CURL_VERSION).tar.gz

$(TARBALLS)/curl-$(CURL_VERSION).tar.gz:
	$(call download,$(CURL_URL))

.sum-curl: curl-$(CURL_VERSION).tar.gz

curl: curl-$(CURL_VERSION).tar.gz .sum-curl
	$(UNPACK)
	$(UPDATE_AUTOCONFIG)
	$(MOVE)


.curl: curl
	cd $< && $(HOSTVARS) ./configure $(HOSTCONF) \
		--with-ssl \
		--with-zlib \
	cd $< && $(MAKE)
	cd $< && $(MAKE) install
	touch $@
