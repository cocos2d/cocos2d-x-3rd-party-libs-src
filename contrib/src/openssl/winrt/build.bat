@echo off

set SHA=b4da0d80af262ff0aa431fef88fc0c1ca76abac9
set URL=https://github.com/Microsoft/openssl/archive/%SHA%.tar.gz

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
	curl -O -L %URL%
)

tar -xzvf %SHA%.tar.gz

pushd openssl-%SHA%
	if exist vsout (
		rmdir /s /q vsout
	)
	call ms\do_vsprojects.bat
popd

call "%VS120COMNTOOLS%vsvars32.bat"

msbuild  openssl\vsout\NT-Phone-8.1-Dll-Unicode\NT-Phone-8.1-Dll-Unicode.vcxproj /p:Configuration="Release" /p:Platform="Win32" /m

msbuild  openssl\vsout\NT-Phone-8.1-Dll-Unicode\NT-Phone-8.1-Dll-Unicode.vcxproj /p:Configuration="Release" /p:Platform="ARM" /m

msbuild  openssl\vsout\NT-Store-8.1-Dll-Unicode\NT-Store-8.1-Dll-Unicode.vcxproj /p:Configuration="Release" /p:Platform="Win32" /m

msbuild  openssl\vsout\NT-Store-8.1-Dll-Unicode\NT-Store-8.1-Dll-Unicode.vcxproj /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=openssl-%SHA%\vsout\NT-Phone-8.1-Dll-Unicode\NT-Phone-8.1-Dll-Unicode.vcxproj
echo Building OpenSSL Windows 8.1 Phone Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="Win32" /m

echo Building OpenSSL Windows 8.1 Phone Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=openssl-%SHA%\vsout\NT-Store-8.1-Dll-Unicode\NT-Store-8.1-Dll-Unicode.vcxproj
echo Building OpenSSL Windows 8.1 Store Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="Win32" /m

echo Building OpenSSL Windows 8.1 Store Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="ARM" /m

popd

echo Installing OpenSSL...
set INDIR=temp\openssl-%SHA%\vsout\NT-Store-8.1-Dll-Unicode\Release\Win32\bin
set OUTDIR=install\curl\prebuilt\winrt_8.1\win32
xcopy "%INDIR%\ssleay32.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\openssl-%SHA%\vsout\NT-Store-8.1-Dll-Unicode\Release\arm\bin
set OUTDIR=install\curl\prebuilt\winrt_8.1\arm
xcopy "%INDIR%\ssleay32.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\openssl-%SHA%\vsout\NT-Phone-8.1-Dll-Unicode\Release\Win32\bin
set OUTDIR=install\curl\prebuilt\wp_8.1\win32
xcopy "%INDIR%\ssleay32.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.lib" "%OUTDIR%\*" /iycq

set INDIR=temp\openssl-%SHA%\vsout\NT-Phone-8.1-Dll-Unicode\Release\arm\bin
set OUTDIR=install\curl\prebuilt\wp_8.1\arm
xcopy "%INDIR%\ssleay32.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\ssleay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libeay32.lib" "%OUTDIR%\*" /iycq

echo OpenSSL build complete.

pause
