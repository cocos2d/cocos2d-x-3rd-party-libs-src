#!/bin/sh
set -e
set -x
# FIXME: you must set TIZEN_SDK in your .bash_profile
# source ~/.bash_profile
# export TIZEN_SDK=~/tizen-sdk/

info()
{
    local green="\033[1;32m"
    local normal="\033[0m"
    echo "[${green}build${normal}] $1"
}


# TODO: configure to compile specify 3rd party libraries
OPTIONS=""

usage()
{
cat << EOF
usage: $0 [options]
Build cocos2d-x 3rd party libraries for tizen
OPTIONS:
   -h            Show some help
   -q            Be quiet
   -l            specify a library name (eg. png)
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

while getopts "hvl:" OPTION
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

info "Building 3rd party libraries for the Mac OS X"
cocos_root=`pwd`/../..

# FIXME: we need a way to determine the toolchina address automatically
toolchain_bin=${TIZEN_SDK}/tools/arm-linux-gnueabi-gcc-4.8/bin
info $toolchain_bin

export PATH="${toolchain_bin}:${cocos_root}/extras/tools/bin:$PATH"
TARGET="arm-linux-gnueabi"

# export LDFLAGS="-L${TIZEN_SDK}/platforms/mobile-2.3/rootstraps/mobile-2.3-device.core/usr/lib"
# info "LD FLAGS SELECTED = '${LDFLAGS}'"

#
# build 3rd party libraries
#
info "Building static libraries"
spushd "${cocos_root}/contrib"
mkdir -p "tizen-armv7-a" && cd "tizen-armv7-a"
../bootstrap ${OPTIONS} \
             --host=${TARGET} \
             --prefix=${cocos_root}/contrib/${TARGET}-armv7a > $out

#
# make
#
## FIXME:  some 3rd party libraries doesn't support parallel build, like openssl. so we just disable the feature here
# core_count=`sysctl -n machdep.cpu.core_count`
# let jobs=$core_count+1
# info "Running make -j$jobs"
make fetch
make list
make
