# GLFW
GLFW_VERSION := 3.2
GLFW_URL := $(GITHUB)/glfw/glfw/releases/download/$(GLFW_VERSION)/glfw-$(GLFW_VERSION).zip


$(TARBALLS)/glfw-$(GLFW_VERSION).zip:
	$(call download,$(GLFW_URL))

.sum-glfw: glfw-$(GLFW_VERSION).zip

glfw: glfw-$(GLFW_VERSION).zip .sum-glfw
	$(UNPACK)
#	$(APPLY) $(SRC)/glfw/fix-pr567.patch
	$(APPLY) $(SRC)/glfw/dont_include_applicationservices.patch
	$(MOVE)

.glfw: glfw
	cd $< && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)"  cmake .  -DGLFW_BUILD_DOCS=0 -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
