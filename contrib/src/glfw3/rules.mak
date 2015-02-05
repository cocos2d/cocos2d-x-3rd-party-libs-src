# GLFW
GLFW_VERSION := 3.1
GLFW_URL := $(SF)/glfw/$(GLFW_VERSION)/glfw-$(GLFW_VERSION).tar.gz


$(TARBALLS)/glfw-$(GLFW_VERSION).tar.gz:
	$(call download,$(GLFW_URL))

.sum-glfw3: glfw-$(GLFW_VERSION).tar.gz

glfw3: glfw-$(GLFW_VERSION).tar.gz .sum-glfw3
	$(UNPACK)
	$(MOVE)

.glfw3: glfw3
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)"  cmake .  -DGLFW_BUILD_DOCS=0 -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
