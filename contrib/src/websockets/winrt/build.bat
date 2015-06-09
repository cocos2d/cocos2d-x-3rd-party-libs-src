@echo off

rem v1.3-chrome37-firefox30
set SHA=c1fdd10ff887994622f6f8a9534d4ab5c320c86d
set URL=https://github.com/warmcat/libwebsockets/archive/%SHA%.tar.gz
set ARGS=-DLWS_WITHOUT_TEST_SERVER:BOOL="1" -DLWS_IPV6:BOOL="0" -DLWS_WITHOUT_TEST_SERVER_EXTPOLL:BOOL="1" -DLWS_WITHOUT_TEST_FRAGGLE:BOOL="1" -DLWS_WITH_SSL:BOOL="0" -DLWS_WITHOUT_TEST_CLIENT:BOOL="1" -DCMAKE_CONFIGURATION_TYPES:STRING="Debug;Release;MinSizeRel;RelWithDebInfo" -DLWS_WITHOUT_TEST_PING:BOOL="1" -DLWS_WITHOUT_TESTAPPS:BOOL="1" 



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

	if not exist %SHA%.tar.gz (
		curl -O -L %URL%
	)

	tar -xzvf %SHA%.tar.gz

	pushd libwebsockets-%SHA%
		set SRC=%cd%
		echo Applying patch...
		patch -p1 < ..\..\patch\winrt.patch
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

	echo Building libwebsockets Windows 8.1 Phone Release/Win32...
	msbuild wp_8.1\win32\libwebsockets.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	
	echo Building libwebsockets Windows 8.1 Phone Release/ARM...
	msbuild wp_8.1\arm\libwebsockets.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild wp_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building libwebsockets Windows 8.1 Store Release/Win32...
	msbuild ws_8.1\win32\libwebsockets.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\win32\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /p:ForceImportBeforeCppTargets=%PATCH% /m

	echo Building libwebsockets Windows 8.1 Store Release/ARM...
	msbuild ws_8.1\arm\libwebsockets.sln /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
	msbuild ws_8.1\arm\INSTALL.vcxproj /p:Configuration="MinSizeRel" /p:Platform="ARM" /p:ForceImportBeforeCppTargets=%PATCH% /m
popd

echo Installing libwebsockets...

set INDIR=temp\wp_8.1\win32\install
xcopy "%INDIR%\include" "install\libwebsockets\include\winrt_8.1\*" /iycqs
xcopy "%INDIR%\include" "install\libwebsockets\include\wp_8.1\*" /iycqs

xcopy "%SRC%\win32port\win32helpers" "install\libwebsockets\include\winrt_8.1\win32helpers\*" /iycqs
xcopy "%SRC%\win32port\win32helpers" "install\libwebsockets\include\wp_8.1\win32helpers\*" /iycqs

xcopy "%SRC%\lib\private-libwebsockets.h" "install\libwebsockets\include\winrt_8.1\*" /iycq
xcopy "%SRC%\lib\private-libwebsockets.h" "install\libwebsockets\include\wp_8.1\*" /iycq

xcopy "temp\wp_8.1\win32\lws_config.h" "install\libwebsockets\include\winrt_8.1\*" /iycq
xcopy "temp\ws_8.1\win32\lws_config.h" "install\libwebsockets\include\wp_8.1\*" /iycq

set OUTDIR=install\libwebsockets\prebuilt\wp_8.1\win32
xcopy "%INDIR%\lib\libwebsockets.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\libwebsockets.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\wp_8.1\arm\install
set OUTDIR=install\libwebsockets\prebuilt\wp_8.1\arm
xcopy "%INDIR%\lib\libwebsockets.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\libwebsockets.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\win32\install
set OUTDIR=install\libwebsockets\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\lib\libwebsockets.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\libwebsockets.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\ws_8.1\arm\install
set OUTDIR=install\libwebsockets\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\lib\libwebsockets.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\bin\libwebsockets.dll" "%OUTDIR%\*" /iycq

echo libwebsockets build complete.





