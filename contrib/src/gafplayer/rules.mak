# gafplayer

GAFPLAYER_GITURL := git@github.com:andyque/Cocos2dxGAFPlayer.git

PKGS += gafplayer

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
EX_ECFLAGS = -DMACOSX_DEPLOYMENT_TARGET=10.7
CMAKE_DEFINE=MACOX
endif

ifdef HAVE_IOS
CMAKE_DEFINE=IOS
endif

ifdef HAVE_ANDROID
CMAKE_DEFINE=ANDROID
endif



.gafplayer: gafplayer toolchain.cmake
	cd $</Library && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" ${CMAKE} -D${CMAKE_DEFINE}=1
	cd $</Library && $(MAKE) VERBOSE=1 install
	touch $@
