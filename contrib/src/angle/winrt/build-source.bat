@echo off

set CONFIG="release"
if not "%1"=="" set CONFIG=%1

set SHA=52be963147ea681a016ed38931685a7844429e83
set URL=https://github.com/MSOpenTech/angle.git


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
		git clone %URL%
	)

	cd angle
	echo Checking out commit SHA %SHA%...
	git checkout %SHA%

	call "%VS140COMNTOOLS%vsvars32.bat"

	set SOLUTION=winrt\10\src\angle.sln
	echo Building Angle Windows 10.0 UWP %CONFIG%/Win32...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%"  /p:Platform="Win32" /m
	echo Building Angle Windows 10.0 UWP %CONFIG%/ARM...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%"  /p:Platform="ARM" /m

	set SOLUTION=winrt\8.1\windows\src\angle.sln
	echo Building Angle Windows 8.1 Store %CONFIG%/Win32...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%" /p:Platform="Win32" /m
	echo Building Angle Windows 8.1 Store %CONFIG%/ARM...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%" /p:Platform="ARM" /m

	set SOLUTION=winrt\8.1\windowsphone\src\angle.sln
	echo Building Angle Windows 8.1 Phone %CONFIG%/Win32...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%"  /p:Platform="Win32" /m
	echo Building Angle Windows 8.1 Phone %CONFIG%/ARM...
	msbuild %SOLUTION% /p:Configuration="%CONFIG%"  /p:Platform="ARM" /m

popd

echo Installing Angle...

xcopy "temp\angle\include" "install\win10-specific\angle\include\" /iycqs

set INDIR=temp\angle\winrt\10\src\%CONFIG%_Win32
set OUTDIR=install\win10-specific\angle\prebuilt\win32
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq

set INDIR=temp\angle\winrt\10\src\%CONFIG%_ARM
set OUTDIR=install\win10-specific\angle\prebuilt\arm
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq

xcopy "temp\angle\include" "install\winrt_8.1-specific\angle\include\" /iycqs

set INDIR=temp\angle\winrt\8.1\windows\src\%CONFIG%_Win32
set OUTDIR=install\winrt_8.1-specific\angle\prebuilt\win32
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq

set INDIR=temp\angle\winrt\8.1\windows\src\%CONFIG%_ARM
set OUTDIR=install\winrt_8.1-specific\angle\prebuilt\arm
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq
xcopy "temp\angle\include" "install\wp_8.1-specific\angle\include\" /iycqs

set INDIR=temp\angle\winrt\8.1\windowsphone\src\%CONFIG%_Win32
set OUTDIR=install\wp_8.1-specific\angle\prebuilt\win32
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq

set INDIR=temp\angle\winrt\8.1\windowsphone\src\%CONFIG%_ARM
set OUTDIR=install\wp_8.1-specific\angle\prebuilt\arm
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.pdb" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.pdb" "%OUTDIR%\*" /iycq

echo Angle build complete.
