@echo off
setlocal

set SHA=15c92b1bf6a4562733b52e03b9e2f21421d180c6
set URL=https://github.com/warmcat/libwebsockets/archive/%SHA%.tar.gz
set CMAKE_ARGS=-DLWS_WITHOUT_TEST_SERVER:BOOL="1" -DLWS_IPV6:BOOL="0" -DLWS_WITHOUT_TEST_SERVER_EXTPOLL:BOOL="1" -DLWS_WITHOUT_TEST_FRAGGLE:BOOL="1" -DLWS_WITH_SSL:BOOL="0" -DLWS_WITHOUT_TEST_CLIENT:BOOL="1" -DCMAKE_CONFIGURATION_TYPES:STRING="Debug;Release;MinSizeRel;RelWithDebInfo" -DLWS_WITHOUT_TEST_PING:BOOL="1" -DLWS_WITHOUT_TESTAPPS:BOOL="1" 

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp

	if not exist %SHA%.tar.gz (
		echo Downloading libwebsockets...
		curl -O -L %URL%
	)

	echo Decompressing libwebsockets...
	tar -xzf %SHA%.tar.gz

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
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
	
	mkdir winrt_8.1
	pushd winrt_8.1 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd
	
	mkdir win10
	pushd win10 
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0 -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %CMAKE_ARGS% %SRC%
		popd
	popd	
popd	


:build	


pushd temp
	call "%VS140COMNTOOLS%vsvars32.bat"
	call:DO_BUILD win10 win32 MinSizeRel
	call:DO_BUILD win10 arm MinSizeRel
	
	call:DO_BUILD wp_8.1 win32 MinSizeRel
	call:DO_BUILD wp_8.1 arm MinSizeRel
	
	call:DO_BUILD winrt_8.1 win32 MinSizeRel
	call:DO_BUILD winrt_8.1 arm MinSizeRel
popd


:install	

echo Installing websockets...

set INDIR=temp\winrt_8.1\win32\install
xcopy "%INDIR%\include" "install\websockets\include\winrt_8.1\*" /iycqs

set INDIR=temp\wp_8.1\win32\install
xcopy "%INDIR%\include" "install\websockets\include\wp_8.1\*" /iycqs

set INDIR=temp\win10\win32\install
xcopy "%INDIR%\include" "install\websockets\include\win10\*" /iycqs


xcopy "%SRC%\lib\private-libwebsockets.h" "install\websockets\include\winrt_8.1\*" /iycq
xcopy "%SRC%\lib\private-libwebsockets.h" "install\websockets\include\wp_8.1\*" /iycq
xcopy "%SRC%\lib\private-libwebsockets.h" "install\websockets\include\win10\*" /iycq

xcopy "temp\wp_8.1\win32\lws_config.h" "install\websockets\include\winrt_8.1\*" /iycq
xcopy "temp\winrt_8.1\win32\lws_config.h" "install\websockets\include\wp_8.1\*" /iycq
xcopy "temp\win10\win32\lws_config.h" "install\websockets\include\win10\*" /iycq

set INDIR=temp\wp_8.1\win32\install
set OUTDIR=install\websockets\prebuilt\wp_8.1\win32
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

set INDIR=temp\wp_8.1\arm\install
set OUTDIR=install\websockets\prebuilt\wp_8.1\arm
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

set INDIR=temp\winrt_8.1\win32\install
set OUTDIR=install\websockets\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

set INDIR=temp\winrt_8.1\arm\install
set OUTDIR=install\websockets\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

set INDIR=temp\win10\win32\install
set OUTDIR=install\websockets\prebuilt\win10\win32
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

set INDIR=temp\win10\arm\install
set OUTDIR=install\websockets\prebuilt\win10\arm
xcopy "%INDIR%\lib\websockets_static.lib" "%OUTDIR%\*" /iycq
mv "%OUTDIR%\websockets_static.lib" "%OUTDIR%\libwebsockets.lib"

echo libwebsockets build complete.


endlocal
goto:eof
::End of script

::--------------------------------------------------------
::-- DO_BUILD
::		%~1 Target (win10, wp8.1, winrt-8.1)
::		%~2 Platform (win32, x64, arm)
::		%~3 Config (debug, release, MinSizeRel, etc.)
::--------------------------------------------------------

:DO_BUILD
	setlocal
	set TARGET=%~1
	set PLATFORM=%~2
	set CONFIG=%~3
	echo DO_BUILD TARGET: %TARGET% PLATFORM: %PLATFORM% CONFIG: %CONFIG%
	
	echo Building libzip %TARGET% %CONFIG%/%PLATFORM%...
	msbuild %CD%\%TARGET%\%PLATFORM%\libzip.sln /p:Configuration="%CONFIG%" /p:Platform="%PLATFORM%" /m
	msbuild %CD%\%TARGET%\%PLATFORM%\INSTALL.vcxproj /p:Configuration="%CONFIG%" /p:Platform="%PLATFORM%" /m

	endlocal
	goto:eof





