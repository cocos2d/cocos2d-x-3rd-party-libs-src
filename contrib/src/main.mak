# Main makefile for cocos2d-x 3rd party libraries ("contrib")
# Copyright (C) 2003-2011 the VideoLAN team
#
# This file is under the same license as the vlc package.

all: install

# bootstrap configuration
include config.mak

TOPSRC ?= ../../contrib
TOPDST ?= ..
SRC := $(TOPSRC)/src
TARBALLS := $(TOPSRC)/tarballs

PATH := $(abspath ../../extras/tools/bin):$(PATH)
export PATH

PKGS_ALL := $(patsubst $(SRC)/%/rules.mak,%,$(wildcard $(SRC)/*/rules.mak))
DATE := $(shell date +%Y%m%d)
VPATH := $(TARBALLS)

# Common download locations
GNU := http://ftp.gnu.org/gnu
SF := https://downloads.sourceforge.net/project
GITHUB := https://github.com


#
# Machine-dependent variables
#

PREFIX ?= $(TOPDST)/$(HOST)
PREFIX := $(abspath $(PREFIX))
ifneq ($(HOST),$(BUILD))
HAVE_CROSS_COMPILE = 1
endif
ARCH := $(shell $(SRC)/get-arch.sh $(HOST))

ifeq ($(ARCH)-$(HAVE_WIN32),x86_64-1)
HAVE_WIN64 := 1
endif

ifdef HAVE_CROSS_COMPILE
need_pkg = 1
else
need_pkg = $(shell $(PKG_CONFIG) $(1) || echo 1)
endif

#
# Default values for tools
#
ifndef HAVE_CROSS_COMPILE
ifneq ($(findstring $(origin CC),undefined default),)
CC := gcc
endif
ifneq ($(findstring $(origin CXX),undefined default),)
CXX := g++
endif
ifneq ($(findstring $(origin LD),undefined default),)
LD := ld
endif
ifneq ($(findstring $(origin AR),undefined default),)
AR := ar
endif
ifneq ($(findstring $(origin RANLIB),undefined default),)
RANLIB := ranlib
endif
ifneq ($(findstring $(origin STRIP),undefined default),)
STRIP := strip
endif
else
ifneq ($(findstring $(origin CC),undefined default),)
CC := $(HOST)-gcc
endif
ifneq ($(findstring $(origin CXX),undefined default),)
CXX := $(HOST)-g++
endif
ifneq ($(findstring $(origin LD),undefined default),)
LD := $(HOST)-ld
endif
ifneq ($(findstring $(origin AR),undefined default),)
AR := $(HOST)-ar
endif
ifneq ($(findstring $(origin RANLIB),undefined default),)
RANLIB := $(HOST)-ranlib
endif
ifneq ($(findstring $(origin STRIP),undefined default),)
STRIP := $(HOST)-strip
endif
endif

ifdef HAVE_ANDROID
CC :=  $(HOST)-gcc --sysroot=$(ANDROID_NDK)/platforms/$(ANDROID_API)/arch-$(PLATFORM_SHORT_ARCH)
CXX := $(HOST)-g++ --sysroot=$(ANDROID_NDK)/platforms/$(ANDROID_API)/arch-$(PLATFORM_SHORT_ARCH)
endif

ifdef HAVE_TIZEN
ifeq ($(ARCH),arm)
CC := ${HOST}-gcc --sysroot=$(TIZEN_STUDIO_HOME)/platforms/tizen-$(TIZEN_SDK_VERSION)/mobile/rootstraps/mobile-$(TIZEN_SDK_VERSION)-device.core
CXX := ${HOST}-g++ --sysroot=$(TIZEN_STUDIO_HOME)/platforms/tizen-$(TIZEN_SDK_VERSION)/mobile/rootstraps/mobile-$(TIZEN_SDK_VERSION)-device.core
else
CC := ${HOST}-gcc --sysroot=$(TIZEN_STUDIO_HOME)/platforms/tizen-$(TIZEN_SDK_VERSION)/mobile/rootstraps/mobile-$(TIZEN_SDK_VERSION)-emulator.core
CXX := ${HOST}-g++ --sysroot=$(TIZEN_STUDIO_HOME)/platforms/tizen-$(TIZEN_SDK_VERSION)/mobile/rootstraps/mobile-$(TIZEN_SDK_VERSION)-emulator.core
EXTRA_CFLAGS += -ldl -latomic
endif
endif

ifdef HAVE_MACOSX
MIN_OSX_VERSION=${MIN_MACOSX_TARGET}
CC=xcrun cc
CXX=xcrun c++
AR=xcrun ar
LD=xcrun ld
STRIP=xcrun strip
RANLIB=xcrun ranlib
EXTRA_CFLAGS += -isysroot $(MACOSX_SDK) -mmacosx-version-min=$(MIN_OSX_VERSION) -DMACOSX_DEPLOYMENT_TARGET=$(MIN_OSX_VERSION)
EXTRA_LDFLAGS += -Wl,-syslibroot,$(MACOSX_SDK) -mmacosx-version-min=$(MIN_OSX_VERSION) -isysroot $(MACOSX_SDK) -DMACOSX_DEPLOYMENT_TARGET=$(MIN_OSX_VERSION)

ifeq ($(ARCH),x86_64)
EXTRA_CFLAGS += -m64 $(OPTIM)
EXTRA_LDFLAGS += -m64
else
EXTRA_CFLAGS += -m32 $(OPTIM)
EXTRA_LDFLAGS += -m32
endif

XCODE_FLAGS = -sdk macosx$(OSX_VERSION)
ifeq ($(shell xcodebuild -version 2>/dev/null | tee /dev/null|head -1|cut -d\  -f2|cut -d. -f1),3)
XCODE_FLAGS += ARCHS=$(ARCH)
# XCode 3 doesn't support -arch
else
XCODE_FLAGS += -arch $(ARCH)
endif

endif #end of MacOSX

#32bit / 64bit for Linux
ifndef HAVE_CROSS_COMPILE

ifdef HAVE_LINUX

ifeq ($(ARCH),x86_64)
EXTRA_CFLAGS += -m64 $(OPTIM)
EXTRA_LDFLAGS += -m64
else
EXTRA_CFLAGS += -m32 $(OPTIM)
EXTRA_LDFLAGS += -m32
endif

endif  #end of HAVE_LINUX
endif #end of HAVE_CROSS_COMPILE

CCAS=$(CC) -c

ifneq "$(or $(HAVE_IOS),$(HAVE_TVOS))" ""
CC=xcrun clang
CXX=xcrun clang++
EXTRA_CFLAGS += $(ENABLE_BITCODE)
ifdef HAVE_NEON
AS=perl $(abspath ../../extras/tools/bin/gas-preprocessor.pl) $(CC)
CCAS=gas-preprocessor.pl $(CC) -c
else
CCAS=$(CC) -c
endif
AR=xcrun ar
LD=xcrun ld
STRIP=xcrun strip
RANLIB=xcrun ranlib
# CPP=xcrun cc -E
# CXXCPP=xcrun c++ -E
endif

ifdef HAVE_WIN32
ifneq ($(shell $(CC) $(CFLAGS) -E -dM -include _mingw.h - < /dev/null | grep -E __MINGW64_VERSION_MAJOR),)
HAVE_MINGW_W64 := 1
endif
endif


cppcheck = $(shell $(CC) $(CFLAGS) -E -dM - < /dev/null | grep -E $(1))

EXTRA_CFLAGS += -I$(PREFIX)/include
CFLAGS := $(CFLAGS) $(EXTRA_CFLAGS) $(OPTIM)
CPPFLAGS := $(CPPFLAGS) $(EXTRA_CFLAGS) $(OPTIM)
CXXFLAGS := $(CXXFLAGS) $(EXTRA_CFLAGS) $(OPTIM)
EXTRA_LDFLAGS += -L$(PREFIX)/lib
LDFLAGS := $(LDFLAGS) $(EXTRA_LDFLAGS)
# Do not export those! Use HOSTVARS.

# Do the FPU detection, after we have figured out our compilers and flags.
ifneq ($(findstring $(ARCH),aarch64 i386 ppc ppc64 sparc sparc64 x86_64),)
# This should be consistent with include/vlc_cpu.h
HAVE_FPU = 1
else ifneq ($(findstring $(ARCH),arm),)
ifneq ($(call cppcheck, __VFP_FP__)),)
ifeq ($(call cppcheck, __SOFTFP__),)
HAVE_FPU = 1
endif
endif
else ifneq ($(call cppcheck, __mips_hard_float),)
HAVE_FPU = 1
endif

ACLOCAL_AMFLAGS += -I$(PREFIX)/share/aclocal
export ACLOCAL_AMFLAGS

PKG_CONFIG ?= pkg-config
ifdef HAVE_CROSS_COMPILE
# This inhibits .pc file from within the cross-compilation toolchain sysroot.
# Hopefully, nobody ever needs that.
PKG_CONFIG_PATH := /usr/share/pkgconfig
PKG_CONFIG_LIBDIR := /usr/$(HOST)/lib/pkgconfig
export PKG_CONFIG_LIBDIR
endif
PKG_CONFIG_PATH := $(PKG_CONFIG_PATH):$(PREFIX)/lib/pkgconfig
export PKG_CONFIG_PATH

ifndef GIT
ifeq ($(shell git --version >/dev/null 2>&1 || echo FAIL),)
GIT = git
endif
endif
GIT ?= $(error git not found!)

ifndef SVN
ifeq ($(shell svn --version >/dev/null 2>&1 || echo FAIL),)
SVN = svn
endif
endif
SVN ?= $(error subversion client (svn) not found!)

ifeq ($(shell curl --version >/dev/null 2>&1 || echo FAIL),)
download = curl -f -L -- "$(1)" > "$@"
else ifeq ($(shell wget --version >/dev/null 2>&1 || echo FAIL),)
download = rm -f $@.tmp && \
	wget --passive -c -p -O $@.tmp "$(1)" && \
	touch $@.tmp && \
	mv $@.tmp $@
else ifeq ($(which fetch >/dev/null 2>&1 || echo FAIL),)
download = rm -f $@.tmp && \
	fetch -p -o $@.tmp "$(1)" && \
	touch $@.tmp && \
	mv $@.tmp $@
else
download = $(error Neither curl nor wget found!)
endif

ifeq ($(shell which bzcat >/dev/null 2>&1 || echo FAIL),)
BZCAT = bzcat
else
BZCAT ?= $(error Bunzip2 client (bzcat) not found!)
endif

ifeq ($(shell gzcat --version >/dev/null 2>&1 || echo FAIL),)
ZCAT = gzcat
else ifeq ($(shell zcat --version >/dev/null 2>&1 || echo FAIL),)
ZCAT = zcat
else
ZCAT ?= $(error Gunzip client (zcat) not found!)
endif

ifeq ($(shell sha512sum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = sha512sum --check
else ifeq ($(shell shasum --version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = shasum -a 512 --check
else ifeq ($(shell openssl version >/dev/null 2>&1 || echo FAIL),)
SHA512SUM = openssl dgst -sha512
else
SHA512SUM = $(error SHA-512 checksumming not found!)
endif

#
# Common helpers
#
HOSTCONF := --prefix="$(PREFIX)"
HOSTCONF += --datarootdir="$(PREFIX)/share"
HOSTCONF += --includedir="$(PREFIX)/include"
HOSTCONF += --libdir="$(PREFIX)/lib"
HOSTCONF += --build="$(BUILD)" --host="$(HOST)" --target="$(HOST)"
HOSTCONF += --program-prefix=""
# libtool stuff:
HOSTCONF += --enable-static --disable-shared --disable-dependency-tracking
ifdef HAVE_WIN32
HOSTCONF += --without-pic
PIC :=
else
HOSTCONF += --with-pic
PIC := -fPIC
endif

HOSTTOOLS := \
	CC="$(CC)" CXX="$(CXX)" LD="$(LD)" \
	AR="$(AR)" CCAS="$(CCAS)" RANLIB="$(RANLIB)" STRIP="$(STRIP)" \
	PATH="$(PREFIX)/bin:$(PATH)"
HOSTVARS := $(HOSTTOOLS) \
	CPPFLAGS="$(CPPFLAGS)" \
	CFLAGS="$(CFLAGS)" \
	CXXFLAGS="$(CXXFLAGS)" \
	LDFLAGS="$(LDFLAGS)"
HOSTVARS_PIC := $(HOSTTOOLS) \
	CPPFLAGS="$(CPPFLAGS) $(PIC)" \
	CFLAGS="$(CFLAGS) $(PIC)" \
	CXXFLAGS="$(CXXFLAGS) $(PIC)" \
	LDFLAGS="$(LDFLAGS)"

download_git = \
	rm -Rf $(@:.tar.xz=) && \
	$(GIT) clone $(2:%=--branch %) $(1) $(@:.tar.xz=) && \
	(cd $(@:.tar.xz=) && $(GIT) checkout $(3:%= %)) && \
	rm -Rf $(@:%.tar.xz=%)/.git && \
	(cd $(dir $@) && \
	tar cvJ $(notdir $(@:.tar.xz=))) > $@ && \
	rm -Rf $(@:.tar.xz=)
checksum = \
	$(foreach f,$(filter $(TARBALLS)/%,$^), \
		grep -- " $(f:$(TARBALLS)/%=%)$$" \
			"$(SRC)/$(patsubst .sum-%,%,$@)/$(2)SUMS" &&) \
	(cd $(TARBALLS) && $(1) /dev/stdin) < \
		"$(SRC)/$(patsubst .sum-%,%,$@)/$(2)SUMS"
CHECK_SHA512 = $(call checksum,$(SHA512SUM),SHA512)
UNPACK = $(RM) -R $@ \
	$(foreach f,$(filter %.tar.gz %.tgz,$^), && tar xvzf $(f)) \
	$(foreach f,$(filter %.tar.bz2,$^), && tar xvjf $(f)) \
	$(foreach f,$(filter %.tar.xz,$^), && tar xvJf $(f)) \
	$(foreach f,$(filter %.zip,$^), && unzip $(f))
UNPACK_DIR = $(patsubst %.tar,%,$(basename $(notdir $<)))
APPLY = (cd $(UNPACK_DIR) && patch -fp1) <
pkg_static = (cd $(UNPACK_DIR) && ../../../contrib/src/pkg-static.sh $(1))
MOVE = mv $(UNPACK_DIR) $@ && touch $@

AUTOMAKE_DATA_DIRS=$(foreach n,$(foreach n,$(subst :, ,$(shell echo $$PATH)),$(abspath $(n)/../share)),$(wildcard $(n)/automake*))
UPDATE_AUTOCONFIG = for dir in $(AUTOMAKE_DATA_DIRS); do \
		if test -f "$${dir}/config.sub" -a -f "$${dir}/config.guess"; then \
			cp "$${dir}/config.sub" "$${dir}/config.guess" $(UNPACK_DIR); \
			break; \
		fi; \
	done

RECONF = mkdir -p -- $(PREFIX)/share/aclocal && \
	cd $< && autoreconf -fiv $(ACLOCAL_AMFLAGS)
CMAKE = cmake . -DCMAKE_TOOLCHAIN_FILE=$(abspath toolchain.cmake) \
		-DCMAKE_INSTALL_PREFIX=$(PREFIX)

#
# Per-package build rules
#
PKGS_FOUND :=
include $(SRC)/*/rules.mak

ifeq ($(PKGS_DISABLE), all)
PKGS :=
endif
#
# Targets
#
ifneq ($(filter $(PKGS_DISABLE),$(PKGS_ENABLE)),)
$(error Same package(s) disabled and enabled at the same time)
endif
# Apply automatic selection (= remove distro packages):
PKGS_AUTOMATIC := $(filter-out $(PKGS_FOUND),$(PKGS))
# Apply manual selection (from bootstrap):
PKGS_MANUAL := $(sort $(PKGS_ENABLE) $(filter-out $(PKGS_DISABLE),$(PKGS_AUTOMATIC)))
# Resolve dependencies:
PKGS_DEPS := $(filter-out $(PKGS_FOUND) $(PKGS_MANUAL),$(sort $(foreach p,$(PKGS_MANUAL),$(DEPS_$(p)))))
PKGS := $(sort $(PKGS_MANUAL) $(PKGS_DEPS))

fetch: $(PKGS:%=.sum-%)
fetch-all: $(PKGS_ALL:%=.sum-%)
install: $(PKGS:%=.%)

mostlyclean:
	-$(RM) $(foreach p,$(PKGS_ALL),.$(p) .sum-$(p) .dep-$(p))
	-$(RM) toolchain.cmake
	-$(RM) -R "$(PREFIX)"
	-$(RM) -R */

clean: mostlyclean
	-$(RM) $(TARBALLS)/*.*

distclean: clean
	$(RM) config.mak
	unlink Makefile


list:
	@echo All packages:
	@echo '  $(PKGS_ALL)' | fmt
	@echo Distribution-provided packages:
	@echo '  $(PKGS_FOUND)' | fmt
	@echo Automatically selected packages:
	@echo '  $(PKGS_AUTOMATIC)' | fmt
	@echo Manually deselected packages:
	@echo '  $(PKGS_DISABLE)' | fmt
	@echo Manually selected packages:
	@echo '  $(PKGS_ENABLE)' | fmt
	@echo Depended-on packages:
	@echo '  $(PKGS_DEPS)' | fmt
	@echo To-be-built packages:
	@echo '  $(PKGS)' | fmt

.PHONY: all fetch fetch-all install mostlyclean clean distclean package list prebuilt

# CMake toolchain
toolchain.cmake:
	$(RM) $@
ifdef HAVE_WIN32
	echo "set(CMAKE_SYSTEM_NAME Windows)" >> $@
	echo "set(CMAKE_RC_COMPILER $(HOST)-windres)" >> $@
endif
ifdef HAVE_DARWIN_OS
	echo "set(CMAKE_SYSTEM_NAME Darwin)" >> $@
	echo "set(CMAKE_C_FLAGS $(CFLAGS))" >> $@
	echo "set(CMAKE_CXX_FLAGS $(CFLAGS))" >> $@
	echo "set(CMAKE_LD_FLAGS $(LDFLAGS))" >> $@
	echo "set(CMAKE_AR ar CACHE FILEPATH "Archiver")" >> $@
ifdef HAVE_TVOS
	echo "set(CMAKE_OSX_SYSROOT $(TVOS_SDK))" >> $@
else ifdef HAVE_IOS
	echo "set(CMAKE_OSX_SYSROOT $(IOS_SDK))" >> $@
else
	echo "set(CMAKE_OSX_SYSROOT $(MACOSX_SDK))" >> $@
endif
endif
ifdef HAVE_CROSS_COMPILE
	echo "set(_CMAKE_TOOLCHAIN_PREFIX $(HOST)-)" >> $@
ifdef HAVE_ANDROID
# cmake will overwrite our --sysroot with a native (host) one on Darwin
# Set it to "" right away to short-circuit this behaviour
	echo "set(CMAKE_SYSTEM_NAME Linux)" >> $@
	echo "set(CMAKE_CXX_SYSROOT_FLAG \"\")" >> $@
	echo "set(CMAKE_C_SYSROOT_FLAG \"\")" >> $@
ifdef HAVE_STL_GUN
	echo "include_directories($(ANDROID_NDK)/sources/cxx-stl/gnu-libstdc++/4.9/include  \
	    $(ANDROID_NDK)/sources/cxx-stl/gnu-libstdc++/4.9/libs/$(MY_TARGET_ARCH)/include \
            $(ANDROID_NDK)/sources/cxx-stl/gnu-libstdc++/4.9/include/backward)"  >> $@
endif
ifdef HAVE_STL_CLANG
	echo "include_directories($(ANDROID_NDK)/sources/android/support/include \
	 	$(ANDROID_NDK)/sources/cxx-stl/llvm-libc++/libcxx/include)"  >> $@
endif

endif  #end of HAVE_ANDROID

ifdef HAVE_TIZEN
	echo "set(CMAKE_SYSTEM_NAME Linux)" >> $@
endif
endif
	echo "set(CMAKE_C_COMPILER $(CC))" >> $@
	echo "set(CMAKE_CXX_COMPILER $(CXX))" >> $@
	echo "set(CMAKE_FIND_ROOT_PATH $(PREFIX))" >> $@
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> $@
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> $@
	echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> $@

# Default pattern rules
.sum-%: $(SRC)/%/SHA512SUMS
	$(CHECK_SHA512)
	touch $@

.sum-%:
	$(error Download and check target not defined for $*)

# Dummy dependency on found packages
$(patsubst %,.dep-%,$(PKGS_FOUND)): .dep-%:
	touch $@

# Real dependency on missing packages
$(patsubst %,.dep-%,$(filter-out $(PKGS_FOUND),$(PKGS_ALL))): .dep-%: .%
	touch -r $< $@

.SECONDEXPANSION:

# Dependency propagation (convert 'DEPS_foo = bar' to '.foo: .bar')
$(foreach p,$(PKGS_ALL),.$(p)): .%: $$(foreach d,$$(DEPS_$$*),.dep-$$(d))

.DELETE_ON_ERROR:
