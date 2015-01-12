# gafplayer

GAFPLAYER_GITURL := https://github.com/andyque/Cocos2dxGAFPlayer.git

$(TARBALLS)/gafplayer-git.tar.xz:
	$(call download_git,$(GAFPLAYER_GITURL),addCMakeSupport)


.sum-gafplayer: gafplayer-git.tar.xz
	$(warning $@ not implemented)
	touch $@

gafplayer: gafplayer-git.tar.xz .sum-gafplayer
	$(UNPACK)
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif

ifdef HAVE_MACOSX
CMAKE_DEFINE=MACOX
endif

ifdef HAVE_IOS
CMAKE_DEFINE=IOS
endif

ifdef HAVE_ANDROID
CMAKE_DEFINE=ANDROID
endif

ifndef HAVE_CROSS_COMPILE
ifdef HAVE_LINUX
CMAKE_DEFINE=LINUX
endif
endif

.gafplayer: gafplayer toolchain.cmake
	cd $</Library && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" ${CMAKE} -D${CMAKE_DEFINE}=1
	cd $</Library && $(MAKE) VERBOSE=1 install
	touch $@
