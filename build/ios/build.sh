#!/bin/sh

#
# A script to build static library for iOS
#

build_arches="all"
build_mode="release"
build_library="all"

function usage()
{
    echo "You should follow the instructions here to build static library for iOS"
    echo "If you want to build a fat, you should pass 'all' to --arch parameter."
    echo ""
    echo "Sample:"
    echo "./bulid.sh --arch=armv7,arm64 --mode=debug"
    echo "You must seperate each arch with comma, otherwise it won't parse correctly. No whitespace is allowed between two arch types."
    echo ""
    echo "./build_png.sh"
    echo "\t-h --help"
    echo "\t--libs=[all | png,lua,tiff,jpeg,webp,zlib,websockets,luajit,freetype2,curl,chipmunk,box2d]"
    echo "\t--arch=[all | armv7,arm64,i386,x86_64]"
    echo "\t--mode=[release | debug]"
    echo ""
}


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --libs)
            build_library=$VALUE
            ;;
        --arch)
            build_arches=$VALUE
            ;;
        --mode)
            build_mode=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
            if [ "${!i}" == "${value}" ]; then
                echo "y"
                return 0
            fi
        }
        echo "n"
        return 1
}

all_arches=("armv7" "arm64" "i386" "x86_64")
all_libraries=("png" "zlib")

# TODO: we only build a fat library with armv7, arm64, i386 and x86_64 arch. If you want to build armv7s into the fat lib, please add it into the following array.
if [ $build_arches = "all" ]; then
    declare -a build_arches=("armv7" "arm64" "i386" "x86_64")
else
    build_arches=(${build_arches//,/ })
fi

if [ $build_library = "all" ]; then
    # TODO: more libraries need to be added here
    declare -a build_library=("png" "zlib")
else
    build_library=(${build_library//,/ })
fi

#check invalid arch type
function check_invalid_arch_type()
{
    for arch in "${build_arches[@]}"
    do
        echo "checking ${arch} is in ${all_arches[@]}"
        if [ $(contains "${all_arches[@]}" $arch) == "n" ]; then
            echo "Invalid arch! Only ${all_arches[@]} is acceptable."
            exit 1
        fi
    done
}

check_invalid_arch_type

#check invalid library name
function check_invalid_library_name()
{
    for lib in "${build_library[@]}"
    do
        echo "checking ${lib} is in ${all_libraries[@]}"
        if [ $(contains "${all_libraries[@]}" $lib) == "n" ]; then
            echo "Invalid library names! Only ${all_libraries[@]} is acceptable!"
            exit 1
        fi
    done
}

check_invalid_library_name

#check invalid build mode, only debug and release is acceptable
if [ $build_mode != "release" ] && [ $build_mode != "debug" ]; then
    echo "invalid build mode, only: debug and release is acceptabl"
    usage
    exit
fi


for arch in "${build_arches[@]}"
do
    echo $arch
done

for lib in "${build_library[@]}"
do
    echo $lib
done

echo "build mode is $build_mode"

exit


current_dir=`pwd`
library_name=png
rm -rf $library_name
# build for armv7
arch=armv7
./build.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib$library_name.a $library_name/prebuilt/lib$library_name-$arch.a
cp -r $top_dir/contrib/install-ios-Os/$arch/include/png*.h  $library_name/include/

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch

# build for i386
arch=i386
./build.sh -s -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-Simulator/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-Simulator
rm -rf $top_dir/contrib/iPhoneSimulator-$arch

#build for x86_64
arch=x86_64
./build.sh -s -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-Simulator/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-Simulator/
rm -rf $top_dir/contrib/iPhoneSimulator-$arch

#build for arm64
arch=arm64
./build.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch


#strip & create fat library
LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

$LIPO -create $library_name/prebuilt/lib$library_name-armv7.a \
      $library_name/prebuilt/lib$library_name-i386.a \
      $library_name/prebuilt/lib$library_name-arm64.a \
      $library_name/prebuilt/lib$library_name-x86_64.a \
      -output $library_name/prebuilt/lib$library_name.a

rm $library_name/prebuilt/lib$library_name-armv7.a
rm $library_name/prebuilt/lib$library_name-i386.a
rm $library_name/prebuilt/lib$library_name-arm64.a
rm $library_name/prebuilt/lib$library_name-x86_64.a


#remove debugging info
$STRIP -S $library_name/prebuilt/lib$library_name.a
$LIPO -info $library_name/prebuilt/lib$library_name.a
