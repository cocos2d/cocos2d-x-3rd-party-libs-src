@echo off

pushd temp

	pushd openssl
		call ms\do_vsprojects.bat
	popd

	call "%VS120COMNTOOLS%vsvars32.bat"

	set SOLUTION=openssl\vsout\NT-Phone-8.1-Dll-Unicode\NT-Phone-8.1-Dll-Unicode.vcxproj
	echo Building OpenSSL Windows 8.1 Phone Release/Win32...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="Win32" /m

	echo Building OpenSSL Windows 8.1 Phone Release/ARM...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

	set SOLUTION=openssl\vsout\NT-Store-8.1-Dll-Unicode\NT-Store-8.1-Dll-Unicode.vcxproj
	echo Building OpenSSL Windows 8.1 Store Release/Win32...
	msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="Win32" /m

	echo Building OpenSSL Windows 8.1 Store Release/ARM...
	msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="ARM" /m

	pushd openssl
		call ms\do_packwinapp.bat
	popd
popd

echo Installing OpenSSL...
xcopy "temp\openssl\vsout\package" "install" /iycqs
echo Windows 8.1 OpenSSL build complete.
