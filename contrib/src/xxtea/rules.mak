# xxtea

XXTEA_GITURL := https://github.com/andyque/pecl-xxtea.git

$(TARBALLS)/xxtea-git.tar.xz:
	$(call download_git,$(XXTEA_GITURL),master)


.sum-xxtea: xxtea-git.tar.xz
	$(warning $@ not implemented)
	touch $@

xxtea: xxtea-git.tar.xz .sum-xxtea
	$(UNPACK)
	$(MOVE)

.xxtea: xxtea toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} 
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
