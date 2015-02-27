# flatbuffers

FLATBUFFERS_GITURL := https://github.com/google/flatbuffers.git

$(TARBALLS)/flatbuffers-git.tar.xz:
	$(call download_git,$(FLATBUFFERS_GITURL),master,1e4d28b)

.sum-flatbuffers: flatbuffers-git.tar.xz
	$(warning $@ not implemented)
	touch $@

flatbuffers: flatbuffers-git.tar.xz .sum-flatbuffers
	$(UNPACK)
	$(APPLY) $(SRC)/flatbuffers/add-library.patch
	$(MOVE)

.flatbuffers: flatbuffers toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DFLATBUFFERS_BUILD_TESTS=OFF
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
