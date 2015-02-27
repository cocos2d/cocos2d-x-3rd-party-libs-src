# tinyxml2

TINYXML2_GITURL := https://github.com/leethomason/tinyxml2.git


$(TARBALLS)/libtinyxml2-git.tar.xz:
	$(call download_git,$(TINYXML2_GITURL),master,5321a0e)

.sum-tinyxml2: libtinyxml2-git.tar.xz
	$(warning $@ not implemented)
	touch $@


tinyxml2: libtinyxml2-git.tar.xz .sum-tinyxml2
	$(UNPACK)
	$(APPLY) $(SRC)/tinyxml2/android.patch
	$(MOVE)

.tinyxml2: tinyxml2 toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -DCMAKE_INSTALL_PREFIX:PATH=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
