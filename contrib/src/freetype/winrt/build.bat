@echo off

set VERSION="2.5.5"
set URL=http://downloads.sourceforge.net/project/freetype/freetype2/%VERSION%/freetype-%VERSION%.tar.gz
set ARGS=-""

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

SET PATCH=%cd%\patch\winrt.props


pushd temp

	if not exist freetype-%VERSION%.tar.gz (
		echo Downloading freetype-%VERSION%.tar.gz
		curl -O -L %URL% 
	)

	echo Decompressing freetype-%VERSION%.tar.gz
	tar -xzf freetype-%VERSION%.tar.gz

	pushd freetype-%VERSION%
		set SRC=%cd%
	popd
	
	echo Generating project files with CMake...

	mkdir wp_8.1
	pushd wp_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
	
	mkdir ws_8.1
	pushd ws_8.1 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
	
	mkdir win10
	pushd win10 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
		
	call "%VS140COMNTOOLS%vsvars32.bat"

	echo Building freetype Windows 8.1 Phone Release/Win32...
	msbuild wp_8.1\win32\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	
	echo Building freetype Windows 8.1 Phone Release/ARM...
	msbuild wp_8.1\arm\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building freetype Windows 8.1 Store Release/Win32...
	msbuild ws_8.1\win32\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building freetype Windows 8.1 Store Release/ARM...
	msbuild ws_8.1\arm\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	
	echo Building freetype Windows 10.0 Store Release/Win32...
	msbuild win10\win32\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild win10\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building freetype Windows 10.0 Store Release/ARM...
	msbuild win10\arm\freetype.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild win10\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
popd

echo Installing freetype...

set INDIR=temp\wp_8.1\win32\install
set OUTDIR=install\freetype2\prebuilt\wp_8.1\win32
xcopy "%INDIR%\include" "install\freetype2\include\wp_8.1" /iycqs
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\wp_8.1\arm\install
set OUTDIR=install\freetype2\prebuilt\wp_8.1\arm
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\win32\install
set OUTDIR=install\freetype2\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\include" "install\freetype2\include\winrt_8.1" /iycqs
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\arm\install
set OUTDIR=install\freetype2\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\win32\install
set OUTDIR=install\freetype2\prebuilt\win10\win32
xcopy "%INDIR%\include" "install\freetype2\include\win10" /iycqs
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\arm\install
set OUTDIR=install\freetype2\prebuilt\win10\arm
xcopy "%INDIR%\lib\freetype.lib" "%OUTDIR%\*" /iycq
	
echo freetype build complete.


