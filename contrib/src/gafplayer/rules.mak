# gafplayer

GAFPLYER_GITURL := git@github.com:andyque/Cocos2dxGAFPlayer.git

ifdef HAVE_MACOSX
PKGS += gafplyer
endif

$(TARBALLS)/gafplyer-git.tar.xz:
	$(call download_git,$(GAFPLYER_GITURL),addCMakeSupport)


.sum-gafplyer: gafplyer-git.tar.xz
	$(warning $@ not implemented)
	touch $@

gafplyer: gafplyer-git.tar.xz .sum-gafplyer
	$(UNPACK)
	$(MOVE)

ifdef HAVE_TIZEN
EX_ECFLAGS = -fPIC
endif

ifdef HAVE_MACOSX
EX_ECFLAGS = -DMACOSX_DEPLOYMENT_TARGET=10.7
endif

.gafplyer: gafplyer toolchain.cmake
	cd $</Library && $(HOSTVARS) CFLAGS="$(CFLAGS) $(EX_ECFLAGS)" ${CMAKE}
	cd $</Library && $(MAKE) VERBOSE=1 install
	touch $@
