# GLFW
GLFW_VERSION := 3.3
#GLFW_URL := $(GITHUB)/glfw/glfw/releases/download/$(GLFW_VERSION)/glfw-$(GLFW_VERSION).zip
GLFW_URL := https://codeload.github.com/glfw/glfw/tar.gz/$(GLFW_VERSION)


$(TARBALLS)/glfw-$(GLFW_VERSION).tar.gz:
	$(call download,$(GLFW_URL))

.sum-glfw: glfw-$(GLFW_VERSION).tar.gz

glfw: glfw-$(GLFW_VERSION).tar.gz .sum-glfw
	$(UNPACK)
	$(APPLY) $(SRC)/glfw/dont_include_applicationservices.patch
	$(MOVE)

.glfw: glfw
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)"  cmake .  -DGLFW_BUILD_DOCS=0 -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
