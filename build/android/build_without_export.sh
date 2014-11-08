#!/bin/sh
set -e
set -x

info()
{
    local green="\033[1;32m"
    local normal="\033[0m"
    echo "[${green}build${normal}] $1"
}

# TODO: You must set your ANDROID_NDK path in .bash_profile
source ~/.bash_profile
ANDROID_ABI="armeabi-v7a"
ANDROID_API="android-19"
ANDROID_GCC_VERSION=4.8
ANDROID_ARCH=arm

# TODO: configure to compile specify 3rd party libraries
OPTIONS=""

usage()
{
cat << EOF
usage: $0 [options]
Build cocos2d-x 3rd party libraries for Android
OPTIONS:
   -h            Show some help
   -q            Be quiet
   -k <sdk>      Use the specified Android API level (default: $ANDROID_API)
   -a <arch>     Use the specified arch (default: $ANDROID_ABI)
   -n <version>  Use the gcc version(default: $ANDROID_GCC_VERSION)
   -l <libname>  Use the specified library name
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

while getopts "hvk:a:l:" OPTION
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
             ANDROID_ABI=$OPTARG
             ;;
         k)
             ANDROID_API=$OPTARG
             ;;
         n)
             ANDROID_GCC_VERSION=$OPTARG
             ;;
         l)
             OPTIONS=--enable-$OPTARG
             ;;
     esac
done

if test -z "$OPTIONS"
then
    echo "You must specify a OPTIONS parameter."
    usage
    exit 1
fi

if [ "${ANDROID_ABI}" != "x86" ] && [ "${ANDROID_ABI}" != "armeabi-v7a" ] && [ "${ANDROID_ABI}" != "armeabi" ]; then
    echo "You must specify the right Android Arch within {armeabi, armeabi-v7a, x86}"
    exit 1
fi


# FIXME: we need a way to determine the toolchina address automatically
toolchain_bin=

if [ "${ANDROID_ABI}" = "x86" ]; then
    TARGET="i686-linux-android"
    toolchain_bin=${ANDROID_NDK}/toolchains/x86-${ANDROID_GCC_VERSION}/prebuilt/darwin-x86_64/bin
    ANDROID_ARCH=x86
else
    TARGET="arm-linux-androideabi"
    toolchain_bin=${ANDROID_NDK}/toolchains/${TARGET}-${ANDROID_GCC_VERSION}/prebuilt/darwin-x86_64/bin
fi

shift $(($OPTIND - 1))
if [ "x$1" != "x" ]; then
    usage
    exit 1
fi
#
# Various initialization
#
out="/dev/stdout"
if [ "$QUIET" = "yes" ]; then
    out="/dev/null"
fi

info "Building 3rd party libraries for the Android"
cocos_root=`pwd`/../..

export ANDROID_ABI
export ANDROID_API
# export LDFLAGS="-L${ANDROID_NDK}/platforms/${ANDROID_API}/arch-${ANDROID_ARCH}/usr/lib"
# info "LD FLAGS SELECTED = '${LDFLAGS}'"

export PATH="${toolchain_bin}:${cocos_root}/extras/tools/bin:$PATH"
if [ "$ANDROID_ABI" = "armeabi-v7a" ]; then
    CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -mthumb -Os -DNDEBUG -fomit-frame-pointer -fno-strict-aliasing -DANDROID  -Wa,--noexecstack -Wformat -Werror=format-security  "
elif [ "$ANDROID_ABI" = "armeabi" ]; then
    CFLAGS="-ffunction-sections -funwind-tables -fstack-protector -no-canonical-prefixes  -march=armv5te -mtune=xscale -msoft-float -mthumb -Os -DNDEBUG -fomit-frame-pointer -fno-strict-aliasing -DANDROID  -Wa,--noexecstack -Wformat -Werror=format-security"
else
    CFLAGS="-ffunction-sections -funwind-tables -fstack-protector -fPIC -no-canonical-prefixes -O2 -DNDEBUG -fomit-frame-pointer -fstrict-aliasing -DANDROID  -Wa,--noexecstack -Wformat -Werror=format-security"
fi

info "CFLAGS is ${CFLAGS}"

#
# build 3rd party libraries
#
info "Building static libraries"
spushd "${cocos_root}/contrib"
mkdir -p "Android-${ANDROID_ABI}" && cd "Android-${ANDROID_ABI}"


../bootstrap ${OPTIONS} \
             --host=${TARGET} \
             --prefix=${cocos_root}/contrib/${TARGET}-${ANDROID_ABI}> $out

echo "ANDROID_ARCH := ${CFLAGS}" >> config.mak

#
# make
#
make fetch
make list
make
