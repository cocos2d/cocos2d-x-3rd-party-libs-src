#!/bin/bash

source `pwd`/main.ini
#
# A script to build static library for Android
#

build_arches=""
build_mode=""
build_library=""
build_api=""
build_gcc_version=""
build_platform=""
build_list_all_libraries=no
build_show_help_message=no

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

function usage()
{
    echo "Helper to build all the 3rd party libraries for Cocos2D-X on various platform."
    echo ""
    echo "Usage:"
    echo "    ./build.sh  -p=PLATFORM [--libs=LIBRARY...] [-a=ARCH...] [-mode=MODE]"
    echo "    ./build.sh  --platform=PLATFORM [--libs=LIBRARY...] [--arch=ARCH...] [--mode=MODE]"
    echo "    ./build.sh  -p=PLATFORM (-h | --help)"
    echo "    ./build.sh  -p=PLATFORM (-l | --list)"
    echo ""
    echo "Arguments:"
    echo "    PLATFORM:    Platform names, valid values are: mac,ios,tvos,android,win32,tizen,linux"
    echo "    LIBRARY:     Library names, valid values are platform dependent(png,jpeg,lua,chipmunk,etc)"
    echo "    ARCH:        Build arches, valid values are platform dependent(arm,arm64,armv7,i386,etc)"
    echo "    MODE:        Build mode, valid values are: release and debug"
    echo ""
    echo "Options:"
    echo "    --platform   Specify a target platform, one platform a time."
    echo "    --libs:      Specify a few target libraries,all the libraries should be comma separated.[default: all]"
    echo "    --arch:      Specify a few arches to build,all the arches should be comma separated. [default: all]"
    echo "    --mode:      Specify the build mode.[default: release]"
}



while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        --help | -h)
            build_show_help_message=yes
            ;;
        --platform | -p)
            build_platform=$VALUE
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
            build_list_all_libraries=yes
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

#check invalid platform
function check_invalid_platform()
{
    # echo "checking ${build_platform} is in ${cfg_all_valid_platforms[@]}"
    if [ $(contains "${cfg_all_valid_platforms[@]}" $build_platform) == "n" ]; then
        usage
        exit 1
    fi
}

check_invalid_platform

##load platform config files
for p in ${cfg_all_valid_platforms[@]}
do
    if [ $(contains "${cfg_all_valid_platforms[@]}" $build_platform) == "y" ];then
        platform_config_file=${build_platform}.ini
        if [ ! -f $platform_config_file ];then
            echo "platform config file is not exists!"
            exit;
        fi
        source $platform_config_file
        [[ -z "${build_api}" ]] && build_api=$cfg_default_build_api
        [[ -z "${build_gcc_version}" ]] && build_gcc_version=$cfg_default_gcc_version
    fi
done



function list_all_supported_libraries()
{

    echo "Supported libraries and versions:"

    for lib in ${cfg_all_supported_libraries[@]}
    do
        all_supported_libraries=$(find  ../contrib/src -type f | grep SHA512SUMS | xargs cat | awk 'match ($0, /.tgz|.tar.gz|.zip|.tar.xz/) { print substr($2,0,length($2)-RLENGTH)}' | grep -i $lib | awk '{print $1}')
        echo $all_supported_libraries | awk '{ print $1}'
    done
}

if [ $build_list_all_libraries = "yes" ];then
    list_all_supported_libraries
    exit 1
fi

if [ $build_show_help_message = "yes" ];then
    usage
    exit 1
fi


if test -z "$build_arches"
then
    build_arches=$cfg_default_build_arches
fi

if test -z "$build_library"
then
    while true; do
        read -p "Do you wish to build with all the libraries?[yes|no]" yn
        case $yn in
            [Yy]* ) build_library=$cfg_default_build_libraries; break;;
            [Nn]* ) usage;exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
fi

if test -z "$build_mode"
then
    echo "You don't specify a valid build mode, use release mode"
    build_mode=$cfg_default_build_mode
fi


if [ $cfg_platform_name = "android" ];then
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

fi

current_dir=`pwd`
top_dir=$current_dir/..

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

    if [ -f $cfg_platform_name/$library_name/prebuilt/lib$library_name.a ]; then
        echo "removing old fat library..."
        rm $cfg_platform_name/$library_name/prebuilt/lib$library_name.a
    fi

    all_static_libs=$(find $cfg_platform_name/$library_name/prebuilt -type f -name "lib$library_name.a")

    echo "create fat library lib$library_name for $all_static_libs"
    $LIPO -create  $all_static_libs \
          -output $cfg_platform_name/$library_name/prebuilt/lib$library_name.a

    # rm $all_static_libs

    # remove debugging info don't strip
    # $STRIP -S $library_name/prebuilt/lib$library_name.a
    $LIPO -info $cfg_platform_name/$library_name/prebuilt/lib$library_name.a
}


function set_build_mode_cflags()
{
    build_flag=cfg_build_${build_mode}_mode
    OPTIM=${!build_flag}

    export OPTIM
}

if [ $cfg_platform_name = "mac" ];then
    export MIN_MACOSX_TARGET=$cfg_min_macosx_deoply_tartget
fi


# build all the libraries for different arches
for lib in "${build_library[@]}"
do
    library_name=$lib

    parser_lib_archive_alias=${lib}_archive_alias
    archive_name=${!parser_lib_archive_alias}
    if [ -z $archive_name ];then
        archive_name=$lib
    fi


    mkdir -p $cfg_platform_name/$archive_name/include/

    for arch in "${build_arches[@]}"
    do
        #skip build libraries with certain arch
        ignore_arch_library=${lib}_ignore_arch_list
        ignore_arch_list=(${!ignore_arch_library})
        ignore_arch_list_array=(${ignore_arch_list//,/ })
        if [ ! -z ${ignore_arch_list} ]; then
            echo ${ignore_arch_list}
            if [ $(contains "${ignore_arch_list_array[@]}" $arch) == "y" ];then
                echo "ingore $lib for $arch"
                continue
            fi
        fi

        #set build mode flags -- debug or release
        set_build_mode_cflags

        #determine wether use mthumb or not
        parse_use_mthumb=cfg_${lib}_${arch}_use_mthumb
        use_mthumb=${!parse_use_mthumb}
        echo $use_mthumb
        if [ -z $use_mthumb ];then
            use_mthumb=yes
        fi

        export ANDROID_USE_MTHUMB=$use_mthumb
        export ANDROID_STL_VERSION=$cfg_default_build_stl

        install_library_path="install-${cfg_platform_name}"
        build_library_path=$cfg_platform_name

        echo "build $arch for $lib in $cfg_platform_name"

        parse_arch_folder_name=cfg_${arch}_alias_folder_name
        original_arch_name=${!parse_arch_folder_name}
        if [ -z $original_arch_name ];then
            original_arch_name=$arch
        fi

        MY_TARGET_ARCH=$original_arch_name
        export MY_TARGET_ARCH

        if [ ${cfg_is_cross_compile} = "yes" ];then
            cross_compile_toolchain_path=cfg_${arch}_toolchain_bin
            echo "toolchain path is ${!cross_compile_toolchain_path}"
            export PATH="${!cross_compile_toolchain_path}:${PATH}"
        fi

        # TODO: add more build and target options here
        if [ $cfg_platform_name = "ios" ];then
            export BUILDFORIOS="yes"
        fi
        
        if [ $cfg_platform_name = "tvos" ];then
            export BUILDFORTVOS="yes"
        fi

        if [ $cfg_platform_name = "android" ];then
            export ANDROID_GCC_VERSION=$build_gcc_version
            export ANDROID_API=android-$build_api
        fi


        mkdir -p "${top_dir}/contrib/${cfg_platform_name}-${arch}"
        cd "${top_dir}/contrib/${cfg_platform_name}-${arch}"

        PREFIX="${top_dir}/contrib/install-${cfg_platform_name}/${arch}"

        my_target_host=cfg_${arch}_host_machine
        if [ $cfg_is_cross_compile = "no" ];then
            cfg_build_machine=${!my_target_host}
        fi

        ../bootstrap --enable-$lib \
                     --build=$cfg_build_machine \
                     --host=${!my_target_host} \
                     --prefix=${PREFIX}


        echo "MY_TARGET_ARCH := ${MY_TARGET_ARCH}" >> config.mak
        echo "OPTIM := ${OPTIM}" >> config.mak

        make

        cd -

        local_library_install_path=$cfg_platform_name/$archive_name/prebuilt/$original_arch_name
        if [ ! -d $local_library_install_path ]; then
            echo "create folder for library with specify arch. $local_library_install_path"
            mkdir -p $local_library_install_path
        fi

        #determine the .a achive name with a specified libraries
        parse_original_lib_name=${lib}_original_name
        original_archive_name=${!parse_original_lib_name}
        if [ -z $original_archive_name ];then
            original_archive_name=$archive_name
        fi

        #copy .a archive from install-platform folder
        cp $top_dir/contrib/$install_library_path/$arch/lib/lib$original_archive_name.a $local_library_install_path/lib$archive_name.a

        #copy dependent .a archive
        parse_dependent_archive_list=${lib}_dependent_archive_list
        original_dependent_archive_list=${!parse_dependent_archive_list}
        if [ ! -z $original_dependent_archive_list ];then
            echo "copying dependent archives..."
            original_dependent_archive_list=(${original_dependent_archive_list//,/ })

            for dep_archive in ${original_dependent_archive_list[@]}
            do
                local_library_install_path=$cfg_platform_name/${dep_archive}/prebuilt/$original_arch_name
                mkdir -p $local_library_install_path
                cp $top_dir/contrib/$install_library_path/$arch/lib/lib${dep_archive}.a $local_library_install_path/lib${dep_archive}.a

            done
        fi


        echo "Copying needed heder files"
        copy_include_file_path=${lib}_header_files
        cp  -r $top_dir/contrib/$install_library_path/$arch/include/${!copy_include_file_path} $cfg_platform_name/$archive_name/include


        echo "cleaning up"
        if [ $cfg_is_cleanup_after_build = "yes" ];then
            rm -rf $top_dir/contrib/$install_library_path
            rm -rf $top_dir/contrib/$build_library_path-$arch
        fi
    done

    echo $cfg_build_fat_library
    if [ $cfg_build_fat_library = "yes" ];then

        create_fat_library $archive_name

        parse_dependent_archive_list=${lib}_dependent_archive_list
        original_dependent_archive_list=${!parse_dependent_archive_list}
        if [ ! -z $original_dependent_archive_list ];then
            echo "create fat library for dependent archives..."
            original_dependent_archive_list=(${original_dependent_archive_list//,/ })

            for dep_archive in ${original_dependent_archive_list[@]}
            do
                create_fat_library $dep_archive
            done
        fi
    fi

done
