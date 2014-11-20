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
# source ~/.bash_profile
ANDROID_ABI="armeabi-v7a"
ANDROID_API=21
ANDROID_GCC_VERSION=4.9
BUILD_MODE=release

# TODO: configure to compile specify 3rd party libraries
OPTIONS=""
IS_EXPORT_CFLAGS=yes

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
   -e <export cflags> Whether to export cflags
   -m <build mode>  Use release or debug mode
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

while getopts "hvk:a:l:e:n:m:" OPTION
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
             ANDROID_API=android-$OPTARG
             ;;
         n)
             ANDROID_GCC_VERSION=$OPTARG
             ;;
         l)
             OPTIONS=--enable-$OPTARG
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

if [ "${ANDROID_ABI}" != "x86" ] && [ "${ANDROID_ABI}" != "armeabi-v7a" ] && [ "${ANDROID_ABI}" != "armeabi" ] && [ "${ANDROID_ABI}" != "arm64" ]; then
    echo "You must specify the right Android Arch within {armeabi, armeabi-v7a, x86, arm64}"
    exit 1
fi



shift $(($OPTIND - 1))
if [ "x$1" != "x" ]; then
    usage
    exit 1
fi
#
# Various initialization
#


#
# make
#
make fetch
make list
make
