@echo off

Building OpenSSL for Windows 10.0...

pushd temp
	pushd openssl
		echo creating Windows 10.0 Visual Studio projects...
		call ms\do_vsprojects14.bat
	popd

	call "%VS140COMNTOOLS%VsMSBuildCmd.bat"

	set SOLUTION=openssl\vsout\NT-Universal-10.0-Dll-Unicode\NT-Universal-10.0-Dll-Unicode.vcxproj
	echo Building OpenSSL Windows 10.0 Release/Win32...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x86" /m

	echo Building OpenSSL Windows 10.0 Release/ARM...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

	echo Building OpenSSL Windows 10.0 Release/x64...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x64" /m

	pushd openssl
		call ms\do_packwinuniversal.bat
	popd
popd

echo Installing OpenSSL...

xcopy "temp\openssl\vsout\package" "install" /iycqs

echo Windows 10.0 OpenSSL build complete.
