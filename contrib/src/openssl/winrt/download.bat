@echo off

set branch=remotes/origin/OpenSSL_1_0_2_WinRT-stable
set URL=https://github.com/Microsoft/openssl.git

echo Cloning OpenSSL source code from %URL%...

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp
	git clone %URL%
	cd openssl
	echo Checking out git branch %BRANCH%...
	git checkout %BRANCH%
popd

echo Download complete.
