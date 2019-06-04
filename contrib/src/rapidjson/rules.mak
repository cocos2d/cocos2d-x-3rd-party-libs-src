# rapidjson

RAPIDJSON_GITURL := https://github.com/Tencent/rapidjson 


$(TARBALLS)/librapidjson-git.tar.xz:
	$(call download_git,$(RAPIDJSON_GITURL),master,f54b0e47)

.sum-rapidjson: librapidjson-git.tar.xz
	$(warning $@ not implemented)
	touch $@


rapidjson: librapidjson-git.tar.xz .sum-rapidjson
	$(UNPACK)
	$(MOVE)

.rapidjson: rapidjson toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DRAPIDJSON_BUILD_DOC=OFF -DRAPIDJSON_BUILD_EXAMPLES=OFF -DRAPIDJSON_BUILD_TESTS=OFF
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
