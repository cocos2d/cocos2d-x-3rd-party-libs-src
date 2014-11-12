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

if test -z "$build_arches"
then
    echo "You must speficy a valid arch option"
    usage
    exit 1
fi

if test -z "$build_library"
then
    echo "You must specify a valid library option"
    usage
    exit 1
fi

if test -z "$build_mode"
then
    echo "You must specify a valid mode option"
    usage
    exit 1
fi


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

all_arches=("armv7" "arm64" "i386" "x86_64" "armv7s")
all_libraries=("png" "zlib" "lua" "luajit" "websockets" "curl" "box2d" "chipmunk" "freetype2" "jpeg" "protobuf" "tiff" "webp")

# TODO: we only build a fat library with armv7, arm64, i386 and x86_64 arch. If you want to build armv7s into the fat lib, please add it into the following array.
if [ $build_arches = "all" ]; then
    declare -a build_arches=("armv7" "arm64" "i386" "x86_64")
else
    build_arches=(${build_arches//,/ })
fi

if [ $build_library = "all" ]; then
    # TODO: more libraries need to be added here
    declare -a build_library=("png" "zlib" "lua" "luajit" "websockets" "curl" "box2d" "chipmunk" "freetype2" "jpeg" "protobuf" "tiff" "webp")
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



function create_fat_library()
{
    library_name=$1
    #strip & create fat library
    LIPO="xcrun -sdk iphoneos lipo"
    STRIP="xcrun -sdk iphoneos strip"

    if [ -f $library_name/prebuilt/lib$library_name.a ]; then
        echo "removing old fat library..."
        rm $library_name/prebuilt/lib$library_name.a
    fi

    all_static_libs=$(find $library_name/prebuilt -type f -name "lib$library_name-*.a")

    echo "create fat library lib$library_name for $all_static_libs"
    $LIPO -create  $all_static_libs \
          -output $library_name/prebuilt/lib$library_name.a

    rm $all_static_libs

    # remove debugging info
    $STRIP -S $library_name/prebuilt/lib$library_name.a
    $LIPO -info $library_name/prebuilt/lib$library_name.a
}


# build all the libraries for different arches
for lib in "${build_library[@]}"
do
    library_name=$lib
    archive_name=$lib
    current_dir=`pwd`
    top_dir=$current_dir/../..

    build_script_name="build_ios.sh"
    if [ $lib = "luajit" ]; then
        build_script_name="build_ios_without_export.sh"
    fi

    if [ $lib = "zlib" ]; then
        archive_name=z
    fi

    mkdir -p $archive_name/prebuilt/
    mkdir -p $archive_name/include/

    for arch in "${build_arches[@]}"
    do
        #skip certain arch libraries
        if [ $lib = "luajit" ] && [ $arch = "arm64" ]; then
            continue
        fi

        if [ $lib = "luajit" ] && [ $arch = "x86_64" ]; then
            continue
        fi

        is_simulator=""
        install_library_path="install-ios-OS"
        build_library_path="iPhoneOS"
        if [ $arch = "i386" ] || [ $arch = "x86_64" ];then
            is_simulator="-s"
            install_library_path="install-ios-Simulator"
            build_library_path="iPhoneSimulator"
        fi

        echo "build $arch for $lib"
        $top_dir/contrib/$build_script_name $is_simulator -a $arch -l $library_name

        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name.a $archive_name/prebuilt/lib$archive_name-$arch.a
        # FIXME: some archive names have some postfix in it.
        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name*.a $archive_name/prebuilt/lib$archive_name-$arch.a


        if [ $lib = "curl" ]; then
            mkdir -p ssl/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libssl.a ssl/prebuilt/libssl-$arch.a
            mkdir -p crypto/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libcrypto.a crypto/prebuilt/libcrypto-$arch.a
        fi

        if [ $lib = "png" ]; then
            echo "copying libz..."
            mkdir -p z/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libz.a z/prebuilt/libz-$arch.a
        fi

        echo "Copying needed heder files"
        if [ $lib = "png" ]; then
            cp  $top_dir/contrib/$install_library_path/$arch/include/png*.h  $library_name/include/
        fi

        if [ $lib = "luajit" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/luajit-2.0/  $library_name/include/
        fi

        if [ $lib = "curl" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/curl/  $library_name/include/
        fi

        # TODO: add more header files decides here

        echo "cleaning up"
        # rm -rf $top_dir/contrib/$install_library_path
        # rm -rf $top_dir/contrib/$build_library_path-$arch
    done

    create_fat_library $archive_name

    if [ $lib = "curl" ]; then
        create_fat_library ssl
        create_fat_library crypto
    fi

    if [ $lib = "png" ]; then
        create_fat_library z
    fi

done
