@echo off

set SHA=b221f4a5b43340310db3800bf16003791f6c42aa
set URL=https://github.com/Microsoft/CMake/archive/%SHA%.tar.gz
set CMAKE_ARGS = ""

if exist temp (
	rm -rf temp
)

rem remove previous build of CMake
if exist install (
	rm -rf install
)

mkdir temp
set INSTALL=%CD%\install

pushd temp
	echo Downloading CMake source code...
	curl -O -L %URL%
	echo Download complete.
	
	echo Decompressing CMake source code...
	tar -xzf %SHA%.tar.gz
	echo Decompresion complete.

	echo Generating project files with CMake...
	pushd cmake-%SHA%
		set SRC=%cd%
	popd

	mkdir win32
	pushd win32
		cmake -G"Visual Studio 14 2015" -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
	popd
	
	echo Building CMake MinSizeRel/Win32...
	call "%VS140COMNTOOLS%VsMSBuildCmd.bat"
	msbuild win32\cmake.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	msbuild win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
popd

rem cleanup
if exist temp (
	rm -rf temp
)

echo CMake build complete.


