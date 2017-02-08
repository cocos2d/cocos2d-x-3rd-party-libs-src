@echo off

echo Downloading zlib...


set VERSION="1.2.8"
set URL=http://downloads.sourceforge.net/project/libpng/zlib/%VERSION%/zlib-%VERSION%.tar.gz

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp
	if not exist zlib-%VERSION%.tar.gz (
		curl -O -L %URL%
	)

	echo Decompressing zlib...
	tar -xzf zlib-%VERSION%.tar.gz
	mv zlib-%VERSION% zlib
popd

echo Download complete.




