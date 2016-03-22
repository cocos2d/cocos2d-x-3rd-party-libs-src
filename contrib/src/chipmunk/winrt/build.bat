@echo off

set VERSION="7.0.1"
set URL=http://chipmunk-physics.net/release/Chipmunk-7.x/Chipmunk-%VERSION%.tgz
set CMAKE_ARGS=-DBUILD_DEMOS:BOOL="0" -DBUILD_SHARED:BOOL="0"

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

SET PATCH=%cd%\patch\winrt.patch

if not exist ../../../tarballs\Chipmunk-%VERSION%.tgz (
	curl -o ../../../tarballs/Chipmunk-%VERSION%.tgz -L %URL%
)


pushd temp

	echo Decompressing Chipmunk...
	tar -xzf ../../../../tarballs/Chipmunk-%VERSION%.tgz

	echo Patching Chipmunk...
	pushd Chipmunk-%VERSION%
		patch -p1 < %PATCH%
		patch -p1 < ../../../cocos2d.patch
		patch -p1 < ../../../cocos2d_winrt.patch
		set SRC=%cd%
	popd
popd

pushd temp
	echo Generating project files with CMake...

	mkdir wp_8.1
	pushd wp_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS%  %SRC%
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
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
	
	mkdir win10
	pushd win10 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		
		mkdir x64
		pushd x64
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 Win64" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
		
	call "%VS140COMNTOOLS%vsvars32.bat"

	echo Building Chipmunk Windows 8.1 Phone Release/Win32...
	msbuild wp_8.1\win32\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	msbuild wp_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	
	echo Building Chipmunk Windows 8.1 Phone Release/ARM...
	msbuild wp_8.1\arm\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /m
	msbuild wp_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /m

	echo Building Chipmunk Windows 8.1 Store Release/Win32...
	msbuild ws_8.1\win32\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	msbuild ws_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m

	echo Building Chipmunk Windows 8.1 Store Release/ARM...
	msbuild ws_8.1\arm\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /m
	msbuild ws_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /m

	echo Building Chipmunk Windows 10.0 Store Release/Win32...
	msbuild win10\win32\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PROPS% /m
	msbuild win10\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PROPS% /m
	
	echo Building Chipmunk Windows 10.0 Store Release/x64...
	msbuild win10\x64\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="x64" /p:ForceImportBeforeCppTargets=%PROPS% /m
	msbuild win10\x64\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="x64" /p:ForceImportBeforeCppTargets=%PROPS% /m

	echo Building Chipmunk Windows 10.0 Store Release/ARM...
	msbuild win10\arm\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PROPS% /m
	msbuild win10\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PROPS% /m
popd

echo Installing Chipmunk...

set INDIR=temp\wp_8.1\win32\install
set OUTDIR=install\chipmunk\prebuilt\wp_8.1\win32
xcopy "%INDIR%\include" "install\chipmunk\include\" /iycqs
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\wp_8.1\arm\install
set OUTDIR=install\chipmunk\prebuilt\wp_8.1\arm
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\win32\install
set OUTDIR=install\chipmunk\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\arm\install
set OUTDIR=install\chipmunk\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\win32\install
set OUTDIR=install\chipmunk\prebuilt\win10\win32
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\x64\install
set OUTDIR=install\chipmunk\prebuilt\win10\x64
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\arm\install
set OUTDIR=install\chipmunk\prebuilt\win10\arm
xcopy "%INDIR%\lib\chipmunk.lib" "%OUTDIR%\*" /iycq
	
echo Chipmunk build complete.

