@echo off

set VERSION="1.2.8"
set URL=http://downloads.sourceforge.net/project/libpng/zlib/%VERSION%/zlib-%VERSION%.tar.gz
set CMAKE_ARGS=""

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp

	if not exist zlib-%VERSION%.tar.gz (
		curl -O -L %URL%
	)

	tar -xzvf zlib-%VERSION%.tar.gz

	pushd zlib-%VERSION%
		set SRC=%cd%
	popd
	
	echo Generating project files with CMake...

	mkdir wp_8.1
	pushd wp_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013 ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
	
	mkdir ws_8.1
	pushd ws_8.1 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
	
	call "%VS120COMNTOOLS%vsvars32.bat"

	echo Building zlib Windows 8.1 Phone Release/Win32...
	msbuild wp_8.1\win32\zlib.sln /p:Configuration="Release" /p:Platform="Win32" /m
	msbuild wp_8.1\win32\INSTALL.vcxproj /p:Configuration="Release" /p:Platform="Win32" /m
	
	echo Building zlib Windows 8.1 Phone Release/ARM...
	msbuild wp_8.1\arm\zlib.sln /p:Configuration="Release" /p:Platform="ARM" /m
	msbuild wp_8.1\arm\INSTALL.vcxproj /p:Configuration="Release" /p:Platform="ARM" /m

	echo Building zlib Windows 8.1 Store Release/Win32...
	msbuild ws_8.1\win32\zlib.sln /p:Configuration="Release" /p:Platform="Win32" /m
	msbuild ws_8.1\win32\INSTALL.vcxproj /p:Configuration="Release" /p:Platform="Win32" /m

	echo Building zlib Windows 8.1 Store Release/ARM...
	msbuild ws_8.1\arm\zlib.sln /p:Configuration="Release" /p:Platform="ARM" /m
	msbuild ws_8.1\arm\INSTALL.vcxproj /p:Configuration="Release" /p:Platform="ARM" /m
popd

echo Installing zlib...

set INDIR=temp\wp_8.1\win32\install
set OUTDIR=install\zlib\prebuilt\wp_8.1\win32
xcopy "%INDIR%\include" "install\wp_8.1-specific\zlib\include\" /iycqs
xcopy "%INDIR%\lib\zlib.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\zlib.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\wp_8.1\arm\install
set OUTDIR=install\zlib\prebuilt\wp_8.1\arm
xcopy "%INDIR%\lib\zlib.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\zlib.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\win32\install
set OUTDIR=install\zlib\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\include" "install\winrt_8.1-specific\zlib\include\" /iycqs
xcopy "%INDIR%\lib\zlib.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\zlib.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\arm\install
set OUTDIR=install\zlib\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\lib\zlib.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\zlib.dll" "%OUTDIR%\*" /iycq
	
echo zlib build complete.


