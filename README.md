cocos2d-x 3rd party libs
========================

This repository includes the source code of the 3rd party libraries (binary) that are bundled with cocos2d-x.

This repository is needed for cocos2d-x developers and/or people who want to port cocos2d-x to other platforms.

As an example, if you want to support cocos2d-x in ARM64, you need to compile all these libraries for ARM64.

**Note:**

- We use MacOSX to build all the static libraries for iOS, Android, Mac and Tizen.

- We use Windows to build all the static libraries for Win32.

- We use Ubuntu to build all the static libraries for Linux.

- Other platforms is not tested which means if you use windows to build static libraries for Android, it might be failed.


## Download

    $ git clone https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src.git
    $ cd cocos2d-x-dependencies
    $ git submodule update --init

## Prerequisite
### For Mac users
- You should install the latest version of XCode.  You should also install the `Command Line Tools` bundled with XCode.

- You should install Git 1.8+, CMake 2.8+ and M4 1.4+.
If you are a Homebrew user, you could simply run the following commands to install these tools:

```cpp
brew install git
brew install cmake
brew install m4
```


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
### For iOS Platform
For building libpng fat library:

```cpp
cd build/ios
./build_png.sh
```

Or you can also use `build.sh` script build each static library for different arch.
The usage would be:

```cpp
usage: $0 [-s] [-k sdk] [-a arch] [-l libname]

OPTIONS
   -k <sdk version>      Specify which sdk to use ('xcodebuild -showsdks', current: 8.1)
   -s            Build for simulator
   -a <arch>     Specify which arch to use (current: armv7)
   -l <libname>  Specify which static library to build
```

If you want to build *websockets* with *i386* arch, you could use the following command:

```cpp
./build.sh -s -a i386 -l websockets (Don't forget the -s option, it is stand for simulator, if you omit it, it will give you errors.)
```

In this way, you can only build one arch a time, if you want to build a fat library, please use `build_xxx.sh` instead.(xxx is the library name, we will follow this conversion throughout this document.)

If you use `build_xxx.sh` to build static libraries, all the generated `header files` and `.a files` are under the folder named as `xxx`.

Let's give png as an example, after you run `./build_png.sh`, it will generate a folder named `png`:

The folder structure would be:

```
-png
--include(this folder contains the exported header files)
- prebuilt(this folder contains the fat library)
```

All the other libraries share the same folder structure.

### For Android Platform
For building libpng with armeabi, armeabi-v7a and x86 arch, you can do it like this:

```cpp
cd build/android
./build_png.sh
```
Or you can also use `build.sh` script build each static library for different arch.
The usage would be:

```cpp
   -k <sdk>      Use the specified Android API level (default: android-19)
   -a <arch>     Use the specified arch (default: armeabi-v7a)
   -n <version>  Use the gcc version(default: 4.8)
   -l <libname>  Use the specified library name
EOF
```

If you want to build a `curl` library with `armeabi` arch support, you can do it like this:

```cpp
./build.sh -a armeabi -l curl
```

### For Mac
For building libpng x86_64 arch library:

```cpp
cd build/mac
./build_png.sh
```
### For Tizen

### For Linux

## How to build a DEBUG and RELEASE version
xxx we need to improve the script to add debug and release options.

## How to do build clean?
If you use `./build_xxx.sh` to build static libraries, there is no need to do clean. After generating the static library, script will delete the intermediate files.

If you use `./build.sh` manually, you should delete the folders generated in src folder.

## How to upgrade a existing library
If you find a 3rd party library has some critical bug fix, you might need to update it.
You can following the [README](./contrib/src/README) file to do this job.

