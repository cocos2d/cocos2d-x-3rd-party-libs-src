@echo off

SET START_DIR=%cd%
SET INSTALL_DIR=%cd%\..\contrib\install-win10
echo Install dir: %INSTALL_DIR%

if "%1"=="clean" (
	if exist %INSTALL_DIR (
		rm -rf %INSTALL_DIR%
	)
) else (
	if exist %INSTALL_DIR%\external (
		rm -rf %INSTALL_DIR%\external
	)
)

if not exist %INSTALL_DIR% (
	mkdir %INSTALL_DIR%
	if %ERRORLEVEL% NEQ 0 goto:error_exit
)

pushd %INSTALL_DIR%
	mkdir external
	
	if not exist vcpkg-cocos2d-x (
		git clone https://github.com/stammen/vcpkg-cocos2d-x.git
		if %ERRORLEVEL% neq 0 goto:error_exit
	)

	pushd vcpkg-cocos2d-x
		echo A | powershell -exec bypass scripts\bootstrap.ps1
		vcpkg install cocos2d-x-deps:x86-uwp
		if %ERRORLEVEL% neq 0 goto:error_exit

		vcpkg install cocos2d-x-deps:x64-uwp
		if %ERRORLEVEL% neq 0 goto:error_exit

		vcpkg install cocos2d-x-deps:arm-uwp
		if %ERRORLEVEL% neq 0 goto:error_exit

		xcopy packages\cocos2d-x-deps %INSTALL_DIR%\external /iycqs
		if %ERRORLEVEL% neq 0 goto:error_exit
	popd
popd

echo cocos2d-x win10 external dependencies are in %INSTALL_DIR%\external
goto:eof

:error_exit
echo win10 build error: %ERRORLEVEL%
cd %START_DIR%

