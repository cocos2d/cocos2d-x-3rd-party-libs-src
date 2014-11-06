# GLFW
GLFW_VERSION := 3.0.4
GLFW_URL := $(SF)/glfw/$(GLFW_VERSION)/glfw-$(GLFW_VERSION).tar.gz

#FIXME: we don't want to use scripts to determine which libraries should be
#       included, because there is bug in cross compile
# PKGS += glfw
# ifeq ($(call need_pkg,"libglfw"),)
# PKGS_FOUND += glfw
# endif

$(TARBALLS)/glfw-$(GLFW_VERSION).tar.gz:
	$(call download,$(GLFW_URL))

.sum-glfw: glfw-$(GLFW_VERSION).tar.gz

glfw: glfw-$(GLFW_VERSION).tar.gz .sum-glfw
	$(UNPACK)
	$(MOVE)

.glfw: glfw
	cd $< &&  cmake . -DCMAKE_BUILD_TYPE=Release -DGLFW_BUILD_DOCS=0 -DCMAKE_INSTALL_PREFIX=$(PREFIX)
	cd $< && $(MAKE) VERBOSE=1 install
	touch $@
