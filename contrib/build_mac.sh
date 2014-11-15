#!/bin/sh
set -e
set -x

info()
{
    local green="\033[1;32m"
    local normal="\033[0m"
    echo "[${green}build${normal}] $1"
}

ARCH="x86_64"
MINIMAL_OSX_VERSION="10.6"
OSX_VERSION=$(xcodebuild -showsdks | grep macosx | sort | tail -n 1 | awk '{print substr($NF,7)}')
SDKROOT=`xcode-select -print-path`/Platforms/MacOSX.platform/Developer/SDKs/MacOSX$OSX_VERSION.sdk
BUILD_MODE="release"

# TODO: configure to compile specify 3rd party libraries
OPTIONS=""

usage()
{
cat << EOF
usage: $0 [options]
Build cocos2d-x 3rd party libraries for mac
OPTIONS:
   -h            Show some help
   -q            Be quiet
   -k <sdk>      Use the specified sdk (default: $SDKROOT)
   -a <arch>     Use the specified arch (default: $ARCH)
   -l <libname>  Use the specified library name
   -m <build mode>  Build on debug or release mode(default: release)
EOF
}

spushd()
{
    pushd "$1" > /dev/null
}

spopd()
{
    popd > /dev/null
}

while getopts "hvk:a:l:m:" OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         q)
             set +x
             QUIET="yes"
             ;;
         a)
             ARCH=$OPTARG
             ;;
         l)
             OPTIONS=--enable-$OPTARG
             ;;
         k)
             SDKROOT=$OPTARG
             ;;
         m)
             BUILD_MODE=$OPTARG
             ;;
     esac
done

if test -z "$OPTIONS"
then
    echo "You must specify a OPTIONS parameter."
    usage
    exit 1
fi

shift $(($OPTIND - 1))

if [ "x$1" != "x" ]; then
    usage
    exit 1
fi

if [ $BUILD_MODE = "release" ]; then
    OPTIM="-O3 -DNDEBUG"
fi

if [ $BUILD_MODE = "debug" ]; then
    OPTIM="-O0 -g -DDEBUG"
fi
#
# Various initialization
#
out="/dev/stdout"
if [ "$QUIET" = "yes" ]; then
    out="/dev/null"
fi

info "Building 3rd party libraries for the Mac OS X"
cocos_root=`pwd`/../..

# FIXME: on MacOSX, we don't need to set the CC/CXX compiler indicators
# export CC="xcrun clang"
# export CXX="xcrun clang++"
# export OBJC="xcrun clang"
export OSX_VERSION
export SDKROOT
export PATH="${cocos_root}/extras/tools/bin:$PATH"
PREFIX="${cocos_root}/contrib/install-mac/${ARCH}"

#
# build 3rd party libraries
#
info "Building static libraries"
spushd "${cocos_root}/contrib"
mkdir -p "mac-${ARCH}" && cd "mac-${ARCH}"
../bootstrap ${OPTIONS} --host=${ARCH}-apple-darwin --prefix=${PREFIX}  > $out

echo "OPTIM := ${OPTIM}" >> config.mak
echo "MAC_ARCH := ${ARCH}" >> config.mak
#
# make
#
# FIXME: Can't use parallax make,
# core_count=`sysctl -n machdep.cpu.core_count`
# let jobs=$core_count+1
# info "Running make -j$jobs"
make fetch
make list
make
