@echo off

SET INSTALL_DIR=%cd%\..\contrib\install-winrt
echo Install dir: %INSTALL_DIR%

if exist %INSTALL_DIR% (
	rm -rf %INSTALL_DIR%
)

mkdir %INSTALL_DIR%

rem zlib and openssl must be built first!
call:winrt_build zlib
call:winrt_install zlib

call:winrt_build openssl
rem don't install openssl

call:winrt_build angle
call:winrt_install angle

call:winrt_build chipmunk
call:winrt_install chipmunk

call:winrt_build curl
call:winrt_install curl

call:winrt_build freetype
call:winrt_install freetype

call:winrt_build ogg
call:winrt_install ogg

call:winrt_build sqlite
call:winrt_install sqlite

call:winrt_build websockets
call:winrt_install websockets

goto:eof

:winrt_build  
pushd ..\contrib\src\%~1\winrt
echo Building %~1...
start /wait cmd /c "dobuild.bat"
popd
goto:eof

:winrt_install  
pushd ..\contrib\src\%~1\winrt
echo Installing %~1...
xcopy install %INSTALL_DIR% /iycqs
popd
goto:eof

