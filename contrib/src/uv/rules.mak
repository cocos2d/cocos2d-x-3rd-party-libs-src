# libuv

LIBUV_GITURL := https://github.com/libuv/libuv

$(TARBALLS)/libuv-git.tar.xz:
	$(call download_git,$(LIBUV_GITURL),master,69c43d987b6aca)


uv: libuv-git.tar.xz 
	$(UNPACK)
	$(MOVE)



.uv: uv toolchain.cmake
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" $(CMAKE) -DBUILD_TESTING=OFF $(make_option)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
