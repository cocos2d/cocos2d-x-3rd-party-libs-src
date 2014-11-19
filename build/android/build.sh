#!/bin/sh

source `pwd`/android.ini
source `pwd`/main.ini
#
# A script to build static library for Android
#

build_arches=$cfg_default_build_arches
build_mode=$cfg_default_build_mode
build_library=$cfg_default_build_libraries
build_api=$cfg_default_build_api
build_gcc_version=$cfg_default_gcc_version

function usage()
{
    echo "You should follow the instructions here to build static library for $cfg_platform_name"
    echo ""
    echo "./build_png.sh"
    echo "\t[-h --help]  "
    echo "\t--libs=[all | png,lua,tiff,jpeg,webp,zlib etc]"
    echo "\t[--arch | -a]=[all | $cfg_help_arch_string etc]"
    echo "\t[--mode | -m]=[release | debug]"
    
if [ $cfg_platform_name = "Android" ]; then
    echo "\t[--api]=[18,19,20 etc, 19 is default.]"
    echo "\t[--gcc]=[4.8+, default is 4.8]"
fi
    echo "\t[--list | -l]"
    echo ""
    echo "Sample:"
    echo "\t.$cfg_help_sample_string"
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
        --api)
            build_api=$VALUE
            ;;
        --gcc)
            build_gcc_version=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

function check_jq_library()
{
    if [[ $(which jq | grep "not found") ]];then
        echo "You should install jq at first."
        exit 1
    fi
}

# check_jq_library

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

echo "build api is $build_api."
if [[ ! $build_api =~ ^[0-9]+$ ]]; then
    echo "Android API should be integers!"
    usage
    exit 1
fi

if [[ ! $build_gcc_version =~ ^[0-9]\.[0-9]+$ ]]; then
    echo "Invalid gcc version number! Gcc version should be numerical numbers."
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

all_arches=(${cfg_all_supported_arches[@]})
all_libraries=(${cfg_all_supported_libraries[@]})

if [ $build_arches = $cfg_default_build_arches ]; then
    build_arches=(${cfg_default_arches_all[@]})
else
    build_arches=(${build_arches//,/ })
fi

if [ $build_library = $cfg_default_build_libraries ]; then
    build_library=(${cfg_default_libraries_all[@]})
else
    build_library=(${build_library//,/ })
fi

#check invalid arch type
function check_invalid_arch_type()
{
    for arch in ${build_arches[@]}
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
function check_invalid_build_mode() {
    if [ $(contains ${cfg_valid_build_mode[@]} $1) == "n" ];then
        echo "invalid build mode, only: ${cfg_valid_build_mode[@]} is allowed!"
        usage
        exit 1
    fi
}

check_invalid_build_mode $build_mode


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

    build_script_name=$cfg_build_script_name
    is_export_cflags=yes
    if [ $lib = "luajit" ]; then
        is_export_cflags=no
    fi

    # parser_lib_archive_alias=${lib}_archive_alias
    # archive_name=${!parser_lib_archive_alias}

    if [ $lib = "zlib" ]; then
        archive_name=z
    fi

    if [ $lib = "freetype2" ]; then
        archive_name=freetype
    fi

    mkdir -p $archive_name/include/

    for arch in "${build_arches[@]}"
    do
        #skip certain arch libraries
        if [ $lib = "luajit" ] && [ $arch = "arm64" ]; then
            continue
        fi


        install_library_path=$cfg_library_install_prefix
        build_library_path=$cfg_library_build_folder

        echo "build $arch for $lib"
        if [ $cfg_platform_name = "Android" ];then
            $top_dir/contrib/$build_script_name  -a $arch -l $library_name -m $build_mode -e $is_export_cflags -k $build_api -n $build_gcc_version
        else
            $top_dir/contrib/$build_script_name  -a $arch -l $library_name -m $build_mode -e $is_export_cflags
        fi

  
        local_library_install_path=$archive_name/prebuilt/$arch
        if [ ! -d $local_library_install_path ]; then
            echo "create folder for library with specify arch."
            mkdir -p $local_library_install_path
        fi
        
        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name.a $local_library_install_path/lib$archive_name.a
        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$archive_name*.a $local_library_install_path/lib$archive_name.a


        if [ $lib = "curl" ]; then
            local_library_install_path=ssl/prebuilt/$arch 
            mkdir -p $local_library_install_path
            cp $top_dir/contrib/$install_library_path/$arch/lib/libssl.a $local_library_install_path/libssl.a

            local_library_install_path=crypto/prebuilt/$arch
            mkdir -p $local_install_path
            cp $top_dir/contrib/$install_library_path/$arch/lib/libcrypto.a $local_library_install_path/libcrypto.a

        fi

        if [ $lib = "png" ] || [ $lib = "freetype2" ] || [ $lib = "websockets" ] || [ $lib = "curl" ];  then
            echo "copying libz..."
            local_install_path=z/prebuilt/$arch
            mkdir -p $local_install_path
            cp $top_dir/contrib/$install_library_path/$arch/lib/libz.a $local_install_path/libz.a
        fi

        echo "Copying needed heder files"
        copy_include_file_path=${lib}_header_files
        cp  -r $top_dir/contrib/$install_library_path/$arch/include/${!copy_include_file_path} $archive_name/include


        echo "cleaning up"
        # rm -rf $top_dir/contrib/$install_library_path
        # rm -rf $top_dir/contrib/$build_library_path-$arch
    done

    if [ $cfg_platform_name = "iOS" ] || [ $cfg_platform_name = "Mac" ]; then
        
        create_fat_library $archive_name

        if [ $lib = "curl" ]; then
            create_fat_library ssl
            create_fat_library crypto
        fi

        if [ $lib = "png" ] || [ $lib = "curl" ] || [ $lib = "freetype2" ] || [ $lib = "websockets" ]; then
            create_fat_library z
        fi
    fi

done
