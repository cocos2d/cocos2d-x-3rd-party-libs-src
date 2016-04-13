@echo off

set VERSION=3120100
set PHONE_URL=https://www.sqlite.org/2016/sqlite-wp81-winrt-%VERSION%.vsix
set WINRT_URL=https://www.sqlite.org/2016/sqlite-winrt81-%VERSION%.vsix
set WIN10_URL=https://www.sqlite.org/2016/sqlite-uwp-%VERSION%.vsix


if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp
	if not exist sqlite-winrt81-%VERSION%.vsix (
		curl -O -L %WINRT_URL%
	)
	
	if not exist sqlite-wp81-winrt-%VERSION%.vsix (
		curl -O -L %PHONE_URL%
	)
	
	if not exist sqlite-uwp-%VERSION%.vsix (
		curl -O -L %WIN10_URL%
	)

	unzip sqlite-winrt81-%VERSION%.vsix -d winrt_8.1
	unzip sqlite-wp81-winrt-%VERSION%.vsix	-d wp_8.1
	unzip sqlite-uwp-%VERSION%.vsix	-d win10
popd

echo Installing sqlite...

set INDIR=temp\wp_8.1\

set OUTDIR=install\sqlite3\libraries\wp_8.1\win32
xcopy "%INDIR%\DesignTime\Retail\x86\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\x86\sqlite3.dll" "%OUTDIR%\*" /iycq

set OUTDIR=install\sqlite3\libraries\wp_8.1\arm
xcopy "%INDIR%\DesignTime\Retail\ARM\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\ARM\sqlite3.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\winrt_8.1\

set OUTDIR=install\sqlite3\libraries\winrt_8.1\win32
xcopy "%INDIR%\DesignTime\Retail\x86\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\x86\sqlite3.dll" "%OUTDIR%\*" /iycq

set OUTDIR=install\sqlite3\libraries\winrt_8.1\arm
xcopy "%INDIR%\DesignTime\Retail\ARM\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\ARM\sqlite3.dll" "%OUTDIR%\*" /iycq

set INDIR=temp\win10\

set OUTDIR=install\sqlite3\libraries\win10\win32
xcopy "%INDIR%\DesignTime\Retail\x86\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\x86\sqlite3.dll" "%OUTDIR%\*" /iycq

set OUTDIR=install\sqlite3\libraries\win10\arm
xcopy "%INDIR%\DesignTime\Retail\ARM\sqlite3.lib" "%OUTDIR%\*" /iycq
xcopy "%INDIR%\Redist\Retail\ARM\sqlite3.dll" "%OUTDIR%\*" /iycq

echo sqlite build complete.





