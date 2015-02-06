# flatbuffer

FLATBUFFER_GITURL := https://github.com/google/flatbuffers.git

$(TARBALLS)/flatbuffer-git.tar.xz:
	$(call download_git,$(FLATBUFFER_GITURL),master,1e4d28b)


.sum-flatbuffer: flatbuffer-git.tar.xz
	$(warning $@ not implemented)
	touch $@

flatbuffer: flatbuffer-git.tar.xz .sum-flatbuffer
	$(UNPACK)
	$(APPLY) $(SRC)/flatbuffer/add-library.patch
	$(MOVE)

.flatbuffer: flatbuffer toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DFLATBUFFERS_BUILD_TESTS=OFF
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
