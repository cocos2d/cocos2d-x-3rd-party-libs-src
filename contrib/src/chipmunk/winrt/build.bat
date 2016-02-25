@echo off

set VERSION="6.2.2"
set URL=http://chipmunk-physics.net/release/Chipmunk-6.x/Chipmunk-%VERSION%.tgz
set ARGS=-DBUILD_DEMOS:BOOL="0" -DBUILD_SHARED:BOOL="0"

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

	if not exist Chipmunk-%VERSION%.tgz (
		curl -O -L %URL%
	)

	tar -xzvf Chipmunk-%VERSION%.tgz

	pushd chipmunk-%VERSION%
		set SRC=%cd%
	popd
	
	echo Generating project files with CMake...

	mkdir wp_8.1
	pushd wp_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013 ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
	
	mkdir ws_8.1
	pushd ws_8.1 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS%  %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 12 2013 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
		
	call "%VS120COMNTOOLS%vsvars32.bat"

	echo Building Chipmunk Windows 8.1 Phone Release/Win32...
	msbuild wp_8.1\win32\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	
	echo Building Chipmunk Windows 8.1 Phone Release/ARM...
	msbuild wp_8.1\arm\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building Chipmunk Windows 8.1 Store Release/Win32...
	msbuild ws_8.1\win32\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building Chipmunk Windows 8.1 Store Release/ARM...
	msbuild ws_8.1\arm\chipmunk.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
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
	
echo Chipmunk build complete.


