current_dir=`pwd`
library_name=png
rm -rf $library_name
# build for armv7
arch=armv7
./build.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib$library_name.a $library_name/prebuilt/lib$library_name-$arch.a
cp -r $top_dir/contrib/install-ios-Os/$arch/include/png*.h  $library_name/include/

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch

# build for i386
arch=i386
./build.sh -s -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-Simulator/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-Simulator
rm -rf $top_dir/contrib/iPhoneSimulator-$arch

#build for x86_64
arch=x86_64
./build.sh -s -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-Simulator/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-Simulator/
rm -rf $top_dir/contrib/iPhoneSimulator-$arch

#build for arm64
arch=arm64
./build.sh -a $arch -l $library_name
top_dir=$current_dir/../..

cd $current_dir
mkdir -p $library_name/prebuilt/
mkdir -p $library_name/include/

cp $top_dir/contrib/install-ios-OS/$arch/lib/lib${library_name}.a $library_name/prebuilt/lib$library_name-$arch.a

echo "cleaning up"
rm -rf $top_dir/contrib/install-ios-OS
rm -rf $top_dir/contrib/iPhoneOS-$arch


#strip & create fat library
LIPO="xcrun -sdk iphoneos lipo"
STRIP="xcrun -sdk iphoneos strip"

$LIPO -create $library_name/prebuilt/lib$library_name-armv7.a \
      $library_name/prebuilt/lib$library_name-i386.a \
      $library_name/prebuilt/lib$library_name-arm64.a \
      $library_name/prebuilt/lib$library_name-x86_64.a \
      -output $library_name/prebuilt/lib$library_name.a

rm $library_name/prebuilt/lib$library_name-armv7.a
rm $library_name/prebuilt/lib$library_name-i386.a
rm $library_name/prebuilt/lib$library_name-arm64.a
rm $library_name/prebuilt/lib$library_name-x86_64.a


#remove debugging info
$STRIP -S $library_name/prebuilt/lib$library_name.a
$LIPO -info $library_name/prebuilt/lib$library_name.a


