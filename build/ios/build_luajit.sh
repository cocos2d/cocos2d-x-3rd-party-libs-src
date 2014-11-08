current_dir=`pwd`
library_name=luajit
# build for armv7
arch=armv7
./build_without_export.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib${library_name}*.a $library_name/prebuilt/lib$library_name-$arch.a
cp -r $top_dir/contrib/install-ios-Os/$arch/include/*.*  $library_name/include/

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch

# build for i386
arch=i386
./build_without_config.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib${library_name}*.a $library_name/prebuilt/lib$library_name-$arch.a
# cp -r $top_dir/contrib/install-ios-Os/$arch/include/*.*  $library_name/include/

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch


#strip & create fat library
LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

$LIPO -create $library_name/prebuilt/libluajit-armv7.a $library_name/prebuilt/libluajit-i386.a -output $library_name/prebuilt/libluajit.a

rm $library_name/prebuilt/libluajit-armv7.a
rm $library_name/prebuilt/libluajit-i386.a

#remove debugging info
$STRIP -S $library_name/prebuilt/libluajit.a
$LIPO -info $library_name/prebuilt/libluajit.a


