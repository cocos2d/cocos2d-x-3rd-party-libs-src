#!/bin/sh

#
# A script to build static library for Mac
#

build_arches="x86_64"
build_mode="release"
build_library="all"

function usage()
{
    echo "You should follow the instructions here to build static library for Mac"
    echo ""
    echo "./build_png.sh"
    echo "\t[--help -h]  "
    echo "\t--libs=[all | png,lua,tiff,jpeg,webp,zlib etc]"
    echo "\t[--arch | -a]=[all | i386,x86_64 etc]"
    echo "\t[--mode | -m]=[release | debug]"
    echo "\t[--list | -l]"
    echo ""
    echo "Sample:"
    echo "\t./bulid.sh --libs=png --arch=i386,x86_64 --mode=debug"
    echo ""
}

function list_all_supported_libraries()
{

    # TODO: we need to update the supported libraries and version when we upgrade libraries
    echo "Supported libraries and versions:"
    echo "\t"
    echo "\tcurl 7.26.0"
    echo "\tfreetype 2.5.3"
    echo "\tjpeg 9.0"
    echo "\tlua 1.5.4"
    echo "\tluajit 2.0.1"
    echo "\topenssl 1.0.1.j"
    echo "\tlibpng 1.6.2"
    echo "\ttiff 4.0.3"
    echo "\twebp 0.4.2"
    echo "\twebsockets 1.3"
    echo "\tzlib 1.2.8"
    echo "\tglfw 3.0.4"
    echo ""
}


while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --help | -h)
            usage
            exit
            ;;
        --libs)
            build_library=$VALUE
            ;;
        --arch | -a)
            build_arches=$VALUE
            ;;
        --mode | -m)
            build_mode=$VALUE
            ;;
        --list | -l)
            list_all_supported_libraries
            exit
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

all_arches=("i386" "x86_64" )
all_libraries=("png" "zlib" "lua" "luajit" "websockets" "curl" "freetype2" "jpeg"  "tiff" "webp" "glfw")

# TODO: we only build a fat library with  i386 and x86_64 arch.  On default we only build x86_64 arch.
if [ $build_arches = "all" ]; then
    declare -a build_arches=("i386" "x86_64")
else
    build_arches=(${build_arches//,/ })
fi

if [ $build_library = "all" ]; then
    # TODO: more libraries need to be added here
    declare -a build_library=("png" "zlib" "lua" "luajit" "websockets" "curl" "freetype2" "jpeg" "tiff" "webp" "glfw")
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
    MAC_SDK=$(xcodebuild -showsdks | grep macosx | tail -n 1 | awk '{print substr($NF,1)}')
    echo "mac sdk is $MAC_SDK."
    LIPO="xcrun -sdk $MAC_SDK lipo"

    if [ -f $library_name/prebuilt/lib$library_name.a ]; then
        echo "removing old fat library..."
        rm $library_name/prebuilt/lib$library_name.a
    fi

    all_static_libs=$(find $library_name/prebuilt -type f -name "lib$library_name-*.a")

    echo "create fat library lib$library_name for $all_static_libs"
    $LIPO -create  $all_static_libs \
          -output $library_name/prebuilt/lib$library_name.a

    rm $all_static_libs

    # remove debugging info don't strip
    # $STRIP -S $library_name/prebuilt/lib$library_name.a
    $LIPO -info $library_name/prebuilt/lib$library_name.a
}


# build all the libraries for different arches
for lib in "${build_library[@]}"
do
    library_name=$lib
    archive_name=$lib
    current_dir=`pwd`
    top_dir=$current_dir/../..

    build_script_name="build_mac.sh"
    # if [ $lib = "luajit" ]; then
    #     build_script_name="build_ios_without_export.sh"
    # fi

    if [ $lib = "zlib" ]; then
        archive_name=z
    fi

    if [ $lib = "freetype2" ]; then
        archive_name=freetype
    fi

    mkdir -p $archive_name/prebuilt/
    mkdir -p $archive_name/include/

    for arch in "${build_arches[@]}"
    do
        #TODO: skip certain arch libraries

        install_library_path="install-mac"

        echo "build $arch for $lib"
        $top_dir/contrib/$build_script_name  -a $arch -l $library_name -m $build_mode

        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name.a $archive_name/prebuilt/lib$archive_name-$arch.a
        # FIXME: some archive names have some postfix in it.
        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name*.a $archive_name/prebuilt/lib$archive_name-$arch.a


        if [ $lib = "curl" ]; then
            mkdir -p ssl/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libssl.a ssl/prebuilt/libssl-$arch.a

            mkdir -p crypto/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libcrypto.a crypto/prebuilt/libcrypto-$arch.a

            echo "copying libz..."
            mkdir -p z/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libz.a z/prebuilt/libz-$arch.a
        fi

        if [ $lib = "png" ] || [ $lib = "freetype2" ] || [ $lib = "websockets" ];  then
            echo "copying libz..."
            mkdir -p z/prebuilt/
            cp $top_dir/contrib/$install_library_path/$arch/lib/libz.a z/prebuilt/libz-$arch.a
        fi

        echo "Copying needed heder files"
        if [ $lib = "png" ]; then
            cp  $top_dir/contrib/$install_library_path/$arch/include/png*.h  $archive_name/include/
        fi

        if [ $lib = "luajit" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/luajit-2.0/  $archive_name/include/
        fi

        if [ $lib = "lua" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/l*.h*  $archive_name/include/
        fi

        if [ $lib = "curl" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/curl/  $archive_name/include/
        fi

        if [ $lib = "freetype2" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/freetype2  $archive_name/include
        fi

        if [ $lib = "jpeg" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/j*.h  $archive_name/include/
        fi

        if [ $lib = "tiff" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/tif*.h  $archive_name/include/
        fi

        if [ $lib = "webp" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/webp/  $archive_name/include/
        fi

        if [ $lib = "websockets" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/libwebsockets.h  $archive_name/include/
        fi

        if [ $lib = "zlib" ]; then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/z*.h  $archive_name/include/
        fi

        if [ $lib = "glfw" ];then
            cp -r $top_dir/contrib/$install_library_path/$arch/include/GLFW  $archive_name/include
        fi

        # TODO: add more header files decides here

        echo "cleaning up"
        # FIXME: uncomment it for debug purpose
        # rm -rf $top_dir/contrib/$install_library_path
        # rm -rf $top_dir/contrib/$build_library_path-$arch
    done

    create_fat_library $archive_name

    if [ $lib = "curl" ]; then
        create_fat_library ssl
        create_fat_library crypto
    fi

    if [ $lib = "png" ] || [ $lib = "curl" ] || [ $lib = "freetype2" ] || [ $lib = "websockets" ]; then
        create_fat_library z
    fi

done
