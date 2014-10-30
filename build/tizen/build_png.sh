current_dir=`pwd`
./build.sh -l png
top_dir=$current_dir/../..

cd $current_dir
mkdir -p png/prebuilt/tizen/arm/
mkdir -p png/include/tizen/

cp $top_dir/contrib/arm-linux-gnueabi-armv7a/lib/libpng.a png/prebuilt/tizen/arm/
cp $top_dir/contrib/arm-linux-gnueabi-armv7a/include/png*.h  png/include/tizen/
