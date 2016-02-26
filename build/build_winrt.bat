@echo off

SET INSTALL_DIR=%cd%\..\contrib\install-winrt
echo Install dir: %INSTALL_DIR%

if exist %INSTALL_DIR% (
	rm -rf %INSTALL_DIR%
)

mkdir %INSTALL_DIR%

call:winrt_build zlib
call:winrt_build angle
call:winrt_build chipmunk
call:winrt_build freetype
call:winrt_build ogg
call:winrt_build sqlite
call:winrt_build websockets
goto:eof

:winrt_build  
pushd ..\contrib\src\%~1\winrt
echo Building %~1...
call cmd /c "dobuild.bat"
echo Installing %~1...
xcopy install %INSTALL_DIR% /iycqs
popd
goto:eof

