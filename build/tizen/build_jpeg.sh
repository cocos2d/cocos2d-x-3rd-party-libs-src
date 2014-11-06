current_dir=`pwd`
library_name=jpeg
./build.sh -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/arm/
mkdir -p $library_name/include/

cp $top_dir/contrib/arm-linux-gnueabi-armv7a/lib/lib${library_name}.a $library_name/prebuilt/arm/
cp $top_dir/contrib/arm-linux-gnueabi-armv7a/include/*.h  $library_name/include/

echo "cleaning up"
rm -rf $top_dir/contrib/arm-linux-gnueabi-armv7a/
rm -rf $top_dir/contrib/tizen-armv7-a
