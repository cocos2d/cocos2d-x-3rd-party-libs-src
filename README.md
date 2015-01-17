cocos2d-x 3rd party libs
========================

This repository includes the source code of the 3rd party libraries (binary) that are bundled with cocos2d-x.

This repository is needed for cocos2d-x developers and/or people who want to:

* generate a updated version of a certain library (eg: upgrade libpng 1.6.2 to 1.6.14)
* port cocos2d-x to other platforms (eg: port it to Android ARM64, or Xbox One, etc)
* generate DEBUG versions of all the 3rd party library


**Note:**

- We use MacOSX to build all the static libraries for iOS, Android, Mac and Tizen.

- We use Windows to build all the static libraries for Win32, WP8 and WinRT.

- We use Ubuntu to build all the static libraries for Linux.

Other configuration were not tested. Compiling the Android binaries from a Linux
or Windows machine were not tested, so we don't know if it works or not.

## Download

    $ git clone https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src.git

## Prerequisite
### For Mac users
- If you want to use these scripts, you should install Git 1.8+, CMake 2.8+, autoconf and libtool.
If you are a Homebrew user, you could simply run the following commands to install these tools:

```
brew update
brew install git
brew install cmake
brew install autoconf
brew install automake
brew install libtool
```

- If you want to build static libraries for iOS and Mac, you should install the latest version of XCode.  You should also install the `Command Line Tools` bundled with XCode.


- If you want to build static libraries for Android, you should install [NDK](https://developer.android.com/tools/sdk/ndk/index.html). NDK r9d is required at the moment and you should also specify the ANDROID_NDK environment variable in your shell.

- If you want to build static libraries for Tizen, you should download and install [Tizen SDK](https://developer.tizen.org/downloads/tizen-sdk). And you should also add a environment variable named `TIZEN_SDK` in your shell.

### For Linux(Ubuntu) users
- If you want to use these scripts, you should instll *autoconf*:

```
sudo apt-get install autoconf
sudo apt-get install automake
sudo apt-get install cmake
sudo apt-get install libtool
sudo apt-get install git
```

### For Windows users
In order to run these scripts, you should install [msys2](http://msys2.github.io/) and update the system packages.

After that, you should also install the following dependencies:

```
pacman -S mingw-w64-i686-toolchain
pacman -S git make mingw-w64-i686-cmake tar autoconf automake libtool automake

```

## How to use
We have one build script for each platform, it is under `build` directory.

The usage would be:

```
./build.sh -p=platform --libs=libs --arch=arch --mode=mode --list
```

- platform: specify a platform. Supported platforms: ios, mac, android, linux and tizen

  libs:
    - use `all` to build all the 3rd party libraries.
    - use comma separated library names, for example, `png,lua,jpeg,webp`, no space between the comma to select one or more libs

  arch:
    - use `all` to build all the supported architectures.
    - for iOS, they are "armv7, arm64, i386, x86_64"
    - for Android, they are "arm,armv7,arm64,x86"
    - for Mac, they are "x86_64"
    - for Tizen, they are "armv7"
    - use comma separated arch name, for example, `armv7, arm64`, no space between the comma.

- mode:
    - release:  Build library on release mode. This is the default option. We use `-O3 -DNDEBUG` flags to build release library.
    - debug:  Build library on debug mode. we use `-O0 -g -DDEBUG` flag to build debug library.

- list:
    - Use these option to list all the supported library names and versions.

### Build png on iOS platform
For building libpng fat library with all arch x86_64, i386, armv7, arm64 on release mode:

```
cd build
./build.sh -p=ios --libs=png
```

After running this command, it will generate a folder named `png`:

The folder structure would be:

```
-png
--include(this folder contains the exported header files)
- prebuilt(this folder contains the fat library)
```

All the other libraries share the same folder structure.

For building libpng fat library with arch armv7 and arm64 on debug mode:

```
cd build
./build.sh -p=ios --libs=png --arch=armv7,arm64 --mode=debug
```

### Build for Android arm64

1. Download Android NDK r10c and set the ANDROID_NDK to point to the Android ndk r10c path. Don't forget to `source ~/.bash_profile`.

2. Modify the android.ini config file. Change `cfg_default_build_api=21` and `cfg_default_gcc_version=4.9`.

3. Pass `--arch=64` to build the libraries with arm64 support.

Note:
If you build `webp` with arm64, you will get `cpu-features.h` header file not found error. This is a known issue of Android NDK r10c. You could simply create a empty header file
named `cpu-features.h` under `{ANDROID_NDK}/platforms/android-21/arch-arm64/usr/include`.


## How to build a DEBUG and RELEASE version
You can add flag "--mode=[debug | release]" for building DEBUG and RELEASE version.

## How to do build clean?
You could simply turn on the flag `cfg_is_cleanup_after_build` to "yes" in `main.ini` file.
After each build, you could also delete the generated folders under `contrib` directory.


## How to upgrade a existing library
If you find a 3rd party library has some critical bug fix, you might need to update it.
You can following the [README](./contrib/src/README) file to do this job.

## How to add new 3rd party libraries
Please refer to [README](./contrib/src/README)
