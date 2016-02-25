@echo off

pushd temp
	pushd openssl
		call ms\do_vsprojects14.bat
	popd

	call "%VS140COMNTOOLS%VsMSBuildCmd.bat"

	set SOLUTION=openssl\vsout\NT-Universal-10.0-Dll-Unicode\NT-Universal-10.0-Dll-Unicode.vcxproj
	echo Building OpenSSL Windows 10.0 Release/Win32...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x86" /m

	echo Building OpenSSL Windows 10.0 Release/ARM...
	msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m


	pushd openssl
		call ms\do_packwinuniversal.bat
	popd
popd

echo Installing OpenSSL...

xcopy "temp\openssl\vsout\package" "install" /iycqs

echo Windows 10.0 OpenSSL build complete.
