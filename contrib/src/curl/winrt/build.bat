@echo off

set VERSION=7.48.0
set URL=http://curl.haxx.se/download/curl-%VERSION%.tar.gz
set CMAKE_ARGS=-DCURL_LDAP_WIN:BOOL="0" -DCMAKE_USE_OPENSSL:BOOL="1" -DCMAKE_USE_LIBSSH2:BOOL="0" -DENABLE_UNIX_SOCKETS:BOOL="0" -DENABLE_MANUAL:BOOL="0" -DBUILD_CURL_EXE:BOOL="0" -DBUILD_CURL_TESTS:BOOL="0" -DUSE_WIN32_LDAP:BOOL="0" -DCURL_DISABLE_TELNET:BOOL="1" -DENABLE_IPV6:BOOL="0"
set ZLIB_DIR=%cd%\..\..\zlib\winrt\install
set OpenSSL_DIR=%cd%\..\..\openssl\winrt\install
SET PATCH=%cd%\patch\winrt.patch


if exist install (
	rm -rf install
)
mkdir install

if exist temp (
	rm -rf temp
)
mkdir temp

pushd temp
	if not exist curl-%VERSION%.tar.gz (
		curl -O -L %URL%
	)

	echo Decompressing curl-%VERSION%.tar.gz...
	tar -xzf curl-%VERSION%.tar.gz

	pushd curl-%VERSION%
		set SRC=%cd%
		echo Applying winrt patch...
		patch -p1 < %PATCH%
	popd
popd
	
:CMAKE
pushd temp
	echo Generating project files with CMake...

	mkdir wp_8.1
	pushd wp_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\prebuilt\win32\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\prebuilt\win32\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\Win32\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
		
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\prebuilt\arm\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\wp_8.1-specific\zlib\prebuilt\arm\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Phone\8.1\Dll\Unicode\Release\arm\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsPhone -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
	
	mkdir winrt_8.1
	pushd winrt_8.1
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\prebuilt\win32\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\prebuilt\win32\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\Win32\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
		
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\prebuilt\arm\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\winrt_8.1-specific\zlib\prebuilt\arm\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Store\8.1\Dll\Unicode\Release\arm\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=8.1  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
	popd
	
	mkdir win10
	pushd win10
		mkdir win32
		pushd win32
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\prebuilt\win32\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\prebuilt\win32\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\Win32\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
		
		mkdir arm
		pushd arm
			set INSTALL=%CD%\install
			set ZIB_INCLUDE_DIR=-DZLIB_INCLUDE_DIR:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\include"
			set ZLIB_LIBRARY_RELEASE=-DZLIB_LIBRARY_RELEASE:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\prebuilt\arm\zlib.lib"
			set ZLIB_LIBRARY_DEBUG=-DZLIB_LIBRARY_DEBUG:FILEPATH="%ZLIB_DIR%\win10-specific\zlib\prebuilt\arm\zlib.lib"
			
			set OPENSSL_INCLUDE_DIR=-DOPENSSL_INCLUDE_DIR:FILEPATH="%OpenSSL_DIR%\include"

			set SSL_EAY_LIBRARY_DEBUG=-DSSL_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_DEBUG=-DSSL_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_LIBRARY_RELEASE=-DSSL_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\ssleay32.lib"
			set SSL_EAY_RELEASE=-DSSL_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\ssleay32.lib"
			
			set LIB_EAY_LIBRARY_DEBUG=-DLIB_EAY_LIBRARY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_DEBUG=-DLIB_EAY_DEBUG:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_LIBRARY_RELEASE=-DLIB_EAY_LIBRARY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\libeay32.lib"
			set LIB_EAY_RELEASE=-DLIB_EAY_RELEASE:FILEPATH="%OpenSSL_DIR%\lib\Universal\10.0\Dll\Unicode\Release\arm\libeay32.lib"

			
			set ARGS=%CMAKE_ARGS% %ZIB_INCLUDE_DIR% %ZLIB_LIBRARY_RELEASE% %ZLIB_LIBRARY_DEBUG% %OPENSSL_INCLUDE_DIR% %SSL_EAY_LIBRARY_DEBUG% %SSL_EAY_DEBUG% %SSL_EAY_LIBRARY_RELEASE% %SSL_EAY_RELEASE% %LIB_EAY_LIBRARY_DEBUG% %LIB_EAY_DEBUG% %LIB_EAY_LIBRARY_RELEASE% %LIB_EAY_RELEASE%
			echo %ARGS%
			cmake -G"Visual Studio 14 2015 ARM" -DCMAKE_SYSTEM_NAME=WindowsStore -DCMAKE_SYSTEM_VERSION=10.0  -DCMAKE_INSTALL_PREFIX:PATH=%INSTALL% %ARGS% %SRC%
		popd
		
	popd
	
	call "%VS140COMNTOOLS%vsvars32.bat"

	pushd wp_8.1\win32\
		echo Building curl Windows Phone 8.1 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	popd

	pushd wp_8.1\arm\
		echo Building curl Windows Phone 8.1 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="arm" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="arm" /m
	popd
	
	pushd winrt_8.1\win32\
		echo Building curl Windows Store 8.1 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	popd

	pushd winrt_8.1\arm\
		echo Building curl Windows Store 8.1 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="arm" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="arm" /m
	popd
	
	pushd win10\win32\
		echo Building curl Windows 10.0 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="Win32" /m
	popd

	pushd win10\arm\
		echo Building curl Windows 10.0 MinSizeRel/Win32...
		msbuild CURL.sln /p:Configuration="MinSizeRel" /p:Platform="arm" /m
		msbuild Install.vcxproj /p:Configuration="MinSizeRel" /p:Platform="arm" /m
	popd
popd

:INSTALL
echo Installing curl...

rem install Win10 binary files
set INDIR="%OpenSSL_DIR%\bin\Universal\10.0\Dll\Unicode\Release\Win32"
set OUTDIR=install\curl\prebuilt\win10\win32
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\win10\win32\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

set INDIR="%OpenSSL_DIR%\bin\Universal\10.0\Dll\Unicode\Release\arm"
set OUTDIR=install\curl\prebuilt\win10\arm
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\win10\arm\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

rem install wp_8.1 binary files
set INDIR="%OpenSSL_DIR%\bin\Phone\8.1\Dll\Unicode\Release\Win32"
set OUTDIR=install\curl\prebuilt\wp_8.1\win32
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\wp_8.1\win32\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

set INDIR="%OpenSSL_DIR%\bin\Phone\8.1\Dll\Unicode\Release\arm"
set OUTDIR=install\curl\prebuilt\wp_8.1\arm
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\wp_8.1\arm\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

rem install winrt_8.1 binary files
set INDIR="%OpenSSL_DIR%\bin\Store\8.1\Dll\Unicode\Release\Win32"
set OUTDIR=install\curl\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\winrt_8.1\win32\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

set INDIR="%OpenSSL_DIR%\bin\Store\8.1\Dll\Unicode\Release\arm"
set OUTDIR=install\curl\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq

set INDIR="temp\winrt_8.1\arm\install\"
xcopy "%INDIR%\bin\libcurl.dll" "%OUTDIR%\*" /iycqs
xcopy "%INDIR%\lib\libcurl_imp.lib" "%OUTDIR%\*" /iycqs
mv "%OUTDIR%\libcurl_imp.lib" "%OUTDIR%\libcurl.lib"

rem install include files
xcopy "temp\win10\win32\install\include" "install\curl\include\win10" /iycqs
xcopy "temp\wp_8.1\win32\install\include" "install\curl\include\wp_8.1" /iycqs
xcopy "temp\winrt_8.1\win32\install\include" "install\curl\include\winrt_8.1" /iycqs

echo curl build complete.



