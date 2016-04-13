@echo off

set OGG_VERSION="1.3.2"
set VORBIS_VERSION="1.3.5"
set OGG.TAR.GZ=libogg-%OGG_VERSION%.tar.gz
set VORBIS.TAR.GZ=libvorbis-%VORBIS_VERSION%.tar.gz
set OGG_URL=http://downloads.xiph.org/releases/ogg/%OGG.TAR.GZ%
set VORBIS_URL=http://downloads.xiph.org/releases/vorbis/%VORBIS.TAR.GZ%

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp

if not exist %OGG.TAR.GZ% (
	curl -O -L %OGG_URL%
)

if not exist %VORBIS.TAR.GZ% (
	curl -O -L %VORBIS_URL%
)

echo Decompressing %OGG.TAR.GZ%
tar -xzf %OGG.TAR.GZ%
echo Decompressing %VORBIS.TAR.GZ%
tar -xzf %VORBIS.TAR.GZ%

mv libogg-%OGG_VERSION% libogg
mv libvorbis-%VORBIS_VERSION% libvorbis

echo Patching libogg and libvorbis...
xcopy ..\patch\libogg\win32 libogg\win32 /iycqs
xcopy ..\patch\libvorbis\win32 libvorbis\win32 /iycqs

call "%VS140COMNTOOLS%vsvars32.bat"

set SOLUTION=libogg\win32\VS2013\libogg-win8.1-universal.sln

echo Building Ogg Windows 8.1 Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="Win32" /m

rem echo Building Ogg Windows 8.1 Release/x64...
rem msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x64" /m

echo Building Ogg Windows 8.1 Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=libvorbis\win32\VS2013\libvorbis-win8.1-universal.sln

echo Building Ogg Windows 8.1 Release/Win32...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="Win32" /m

rem echo Building Ogg Windows 8.1 Release/x64...
rem msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x64" /m

echo Building Ogg Windows 8.1 Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=libogg\win32\VS2015\libogg-win10-universal.sln

echo Building Ogg Windows 10.0 Release/x86...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x86" /m

rem echo Building Ogg Windows 10.0 Release/x64...
rem msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x64" /m

echo Building Ogg Windows 10.0 Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

set SOLUTION=libvorbis\win32\VS2015\libvorbis-win10-universal.sln

echo Building Ogg Windows 10.0 Release/x86...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x86" /m

rem echo Building Ogg Windows 10.0 Release/x64...
rem msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="x64" /m

echo Building Ogg Windows 10.0 Release/ARM...
msbuild %SOLUTION% /p:Configuration="Release" /p:Platform="ARM" /m

popd

echo Installing Ogg...

rem copy include files
xcopy "temp\libogg\include\ogg" "install\winrt_8.1-specific\OggDecoder\include\ogg" /iycqs
xcopy "temp\libvorbis\include\vorbis" "install\winrt_8.1-specific\OggDecoder\include\vorbis" /iycqs
xcopy "temp\libogg\include\ogg" "install\wp_8.1-specific\OggDecoder\include\ogg" /iycqs
xcopy "temp\libvorbis\include\vorbis" "install\wp_8.1-specific\OggDecoder\include\vorbis" /iycqs
xcopy "temp\libogg\include\ogg" "install\win10-specific\OggDecoder\include\ogg" /iycqs
xcopy "temp\libvorbis\include\vorbis" "install\win10-specific\OggDecoder\include\vorbis" /iycqs

rem copy libs and dlls
call:CopyOggWin10Files win32
call:CopyOggWin10Files arm
call:CopyOggFiles Windows win32 winrt_8.1 
call:CopyOggFiles Windows arm winrt_8.1 
call:CopyOggFiles WindowsPhone win32 wp_8.1 
call:CopyOggFiles WindowsPhone arm wp_8.1

echo Ogg build complete.

goto:eof

:CopyOggFiles   
set INDIR=temp\libogg\win32\VS2013\%~2\Release\libOgg.%~1
set OUTDIR=install\%~3-specific\OggDecoder\prebuilt\%~2

echo INDIR=%INDIR%
echo OUTDIR=%OUTDIR%
xcopy "%INDIR%\libogg.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libogg.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\libvorbis\win32\VS2013\%~2\Release\libvorbis.%~1
echo INDIR=%INDIR%

xcopy "%INDIR%\libvorbis.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libvorbis.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\libvorbis\win32\VS2013\%~2\Release\libvorbisfile.%~1
echo INDIR=%INDIR%

xcopy "%INDIR%\libvorbisfile.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libvorbisfile.dll" "%OUTDIR%\*" /iycq
goto:eof

:CopyOggWin10Files   
set INDIR=temp\libogg\win32\VS2015\%~1\Release\libogg-win10-universal
set OUTDIR=install\win10-specific\OggDecoder\prebuilt\%~1

echo INDIR=%INDIR%
echo OUTDIR=%OUTDIR%
xcopy "%INDIR%\libogg.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libogg.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\libvorbis\win32\VS2015\%~1\Release\libvorbis-win10-universal
echo INDIR=%INDIR%

xcopy "%INDIR%\libvorbis.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libvorbis.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\libvorbis\win32\VS2015\%~1\Release\libvorbisfile-win10-universal
echo INDIR=%INDIR%

xcopy "%INDIR%\libvorbisfile.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\libvorbisfile.dll" "%OUTDIR%\*" /iycq

goto:eof


