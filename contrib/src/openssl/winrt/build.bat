@echo off

set SHA=b4da0d80af262ff0aa431fef88fc0c1ca76abac9
set URL=https://github.com/Microsoft/openssl/archive/%SHA%.tar.gz



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
