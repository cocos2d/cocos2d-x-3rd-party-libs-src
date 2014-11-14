cocos2d-x 3rd party libs
========================

This repository includes the source code of the 3rd party libraries (binary) that are bundled with cocos2d-x.

This repository is needed for cocos2d-x developers and/or people who want to:

* generate a updated version of a certain library (eg: upgrade libpng 1.2.2 to 1.2.14)
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
- If you want to use these scripts, you should install Git 1.8+, CMake 2.8+ and M4 1.4+.
If you are a Homebrew user, you could simply run the following commands to install these tools:

```
brew update
brew install git
brew install cmake
brew install m4
brew install autoconf
```

- If you want to build static libraries for iOS and Mac, you should install the latest version of XCode.  You should also install the `Command Line Tools` bundled with XCode.


- If you want to build static libraries for Android, you should install [NDK](https://developer.android.com/tools/sdk/ndk/index.html). NDK r9d is required at the moment and you should also specify the ANDROID_NDK environment variable in your shell.

- If you want to build static libraries for Tizen, you should download and install [Tizen SDK](https://developer.tizen.org/downloads/tizen-sdk). And you should also add a environment variable named `TIZEN_SDK` in your shell.

### For Linux users
xxx need to improve the document here later.

### For Windows users
In order to run these scripts, you should install [msys2](http://msys2.github.io/) and update the system packages.

After that, you should also install the following dependencies:

```cpp
pacman -S gcc
pacman -S make
pacman -S autoconf
pacman -S automake
pacman -S git
pacman -S cmake
pacman -S libtool
```

## How to use
We have one build script for each platform, they are under `build/platform{ios/mac/android/tizen}` directory.

All of them share the same usage:

```
./build.sh --libs=param1 --arch=param2 --mode=param3
```

- param1:
    - use `all` to build all the 3rd party libraries, it will take you a very long time.
    - use comma separated library names, for example, `png,lua,jpeg/webp`,  no space between the comma.

- param2:
    - use `all` to build all the supported arches. For iOS, they are "armv7, arm64, i386, x86_64", for Android, they are "armeabi, armeabi-v7a, x86, arm64", for Mac, they are "x86_64", for Tizen, they are "armv7"
    - use comma separated arch name, for example, `armv7, arm64`, no space between the comma.

- param3:
    - release:  Build library on release mode. This is the default option. We use `-O3 -DNDEBUG` flags to build release library.
    - debug:  Build library on debug mode. we use `-O0 -g -DDEBUG` flag to build debug library.

### For iOS Platform
For building libpng fat library with all arch x86_64, i386, armv7, arm64 on release mode:

```cpp
cd build/ios
./build.sh --libs=png
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
cd build/ios
./build.sh --libs=png --arch=armv7,arm64 --mode=debug
```

### For Android Platform
xxx document will be update later.

### For Mac
xxx document will be update later.

### For Tizen
xxx document will be update later.

### For Linux
xxx After testing these scripts on Linux, document will be update.

## How to build a DEBUG and RELEASE version
xxx we need to improve the script to add debug and release options.

## How to do build clean?
If you use `./build.sh` to build static libraries, there is no need to do clean. After generating the static library, script will delete the intermediate files.


## How to upgrade a existing library
If you find a 3rd party library has some critical bug fix, you might need to update it.
You can following the [README](./contrib/src/README) file to do this job.

## How to add new 3rd party libraries
Please refer to [README](./contrib/src/README)
