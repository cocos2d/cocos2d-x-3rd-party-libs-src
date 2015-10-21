# convertutf

CONVERTUTF_GITURL := https://github.com/andyque/convertuft

$(TARBALLS)/convertutf-git.tar.xz:
	$(call download_git,$(CONVERTUTF_GITURL),master)


.sum-convertutf: convertutf-git.tar.xz
	$(warning $@ not implemented)
	touch $@

convertutf: convertutf-git.tar.xz .sum-convertutf
	$(UNPACK)
	$(MOVE)


ifdef HAVE_MACOSX
CMAKE_DEFINE=MACOX
endif

ifdef HAVE_IOS
CMAKE_DEFINE=IOS
endif

ifdef HAVE_APPLETV
CMAKE_DEFINE=IOS
endif

.convertutf: convertutf toolchain.cmake
	cd $< && $(HOSTVARS) ${CMAKE} -D${CMAKE_DEFINE}=1
	cd $< && $(MAKE)  VERBOSE=1 install
	touch $@
