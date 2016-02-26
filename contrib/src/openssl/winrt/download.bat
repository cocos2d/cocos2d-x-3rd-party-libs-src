@echo off

set SHA=b4da0d80af262ff0aa431fef88fc0c1ca76abac9
set URL=https://github.com/Microsoft/openssl/archive/%SHA%.tar.gz

if exist temp (
	rm -rf temp
)

if exist install (
	rm -rf install
)

mkdir temp
mkdir install

pushd temp
	if not exist %SHA%.tar.gz (
		curl -O -L %URL%
	)
	
	echo Decompressing source code...
	tar -xzf %SHA%.tar.gz
	mv openssl-%SHA% openssl
popd

echo Download complete.
