# edtaa3func

EDTAA3FUNC_GITURL := https://github.com/andyque/edtaa3func.git

$(TARBALLS)/edtaa3func-git.tar.xz:
	$(call download_git,$(EDTAA3FUNC_GITURL),master)


.sum-edtaa3func: edtaa3func-git.tar.xz
	$(warning $@ not implemented)
	touch $@

edtaa3func: edtaa3func-git.tar.xz .sum-edtaa3func
	$(UNPACK)
	$(MOVE)

.edtaa3func: edtaa3func toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} 
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
