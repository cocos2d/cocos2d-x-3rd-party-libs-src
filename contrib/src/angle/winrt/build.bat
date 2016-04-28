@echo off

set VERSION=2.1.8
set ANGLE_URL=http://api.nuget.org/packages/angle.windowsstore.%VERSION%.nupkg


if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp
	echo downloading ANGLE version %VERSION%
	if not exist angle.windowsstore.%VERSION%.nupkg (
		curl -O -L %ANGLE_URL%
	)
	

	unzip angle.windowsstore.%VERSION%.nupkg -d angle
popd

echo Installing ANGLE...

set INDIR=temp\angle\

set OUTDIR=install\win10-specific\angle\include
xcopy "%INDIR%\Include" "%OUTDIR%" /iycqs
set OUTDIR=install\win10-specific\angle\prebuilt
xcopy "%INDIR%\bin\UAP\Win32" "%OUTDIR%\win32" /iycqs
xcopy "%INDIR%\bin\UAP\ARM" "%OUTDIR%\arm" /iycqs

set OUTDIR=install\winrt_8.1-specific\angle\include
xcopy "%INDIR%\Include" "%OUTDIR%" /iycqs
set OUTDIR=install\winrt_8.1-specific\angle\prebuilt
xcopy "%INDIR%\bin\Windows\Win32" "%OUTDIR%\win32" /iycqs
xcopy "%INDIR%\bin\Windows\ARM" "%OUTDIR%\arm" /iycqs

set OUTDIR=install\wp_8.1-specific\angle\include
xcopy "%INDIR%\Include" "%OUTDIR%" /iycqs
set OUTDIR=install\wp_8.1-specific\angle\prebuilt
xcopy "%INDIR%\bin\Phone\Win32" "%OUTDIR%\win32" /iycqs
xcopy "%INDIR%\bin\Phone\ARM" "%OUTDIR%\arm" /iycqs

echo ANGLE build complete.





