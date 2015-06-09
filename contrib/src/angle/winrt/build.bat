@echo off

set SHA=ff68ed35a5fe07283e804849d56ae3993756faa4
set URL=https://github.com/msopentech/angle/archive/%SHA%.tar.gz

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

call "%VS120COMNTOOLS%vsvars32.bat"

set SOLUTION=angle-%SHA%\winrt\8.1\windows\src\angle.sln

echo Building Angle Windows 8.1 Store Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="Win32" /m

echo Building Angle Windows 8.1 Store Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=angle-%SHA%\winrt\8.1\windowsphone\src\angle.sln
echo Building Angle Windows 8.1 Phone Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="Win32" /m

echo Building Angle Windows 8.1 Phone Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release"  /p:Platform="ARM" /m

popd

echo Installing Angle...

xcopy "temp\angle-%SHA%\include" "install\winrt_8.1-specific\angle\include\" /iycqs

set INDIR=temp\angle-%SHA%\winrt\8.1\windows\src\Release_Win32
set OUTDIR=install\winrt_8.1-specific\angle\prebuilt\win32
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\angle-%SHA%\winrt\8.1\windows\src\Release_ARM
set OUTDIR=install\winrt_8.1-specific\angle\prebuilt\arm
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq

xcopy "temp\angle-%SHA%\include" "install\wp_8.1-specific\angle\include\" /iycqs

set INDIR=temp\angle-%SHA%\winrt\8.1\windowsphone\src\Release_Win32
set OUTDIR=install\wp_8.1-specific\angle\prebuilt\win32
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\angle-%SHA%\winrt\8.1\windowsphone\src\Release_ARM
set OUTDIR=install\wp_8.1-specific\angle\prebuilt\arm
xcopy "%INDIR%\lib\libEGL.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libEGL.dll" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\lib\libGLESv2.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libGLESv2.dll" "%OUTDIR%\*" /iycq

echo Angle build complete.
