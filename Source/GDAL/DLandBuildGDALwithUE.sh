#!/bin/sh
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: UE_ROOT=/your/UnrealEngine5.3/root/dir ./DLandBuildGDALwithUE.sh"
  echo
  echo "UE_ROOT is the root directory (containing 'Engine', 'FeaturePacks' etc.) of your UE source distribution"
  echo "No trailing slash in UE_ROOT!"
  echo
  echo "Make sure you have these packages installed: cmake, curl, jq, unzip"
  echo "You can install them like this: 'sudo apt install cmake curl jq unzip'"
  exit 1
fi


downloadGDAL() {
    GDAL_url=$(curl -s https://api.github.com/repos/OSGeo/gdal/releases/latest | jq -s -r '.[0].assets[] | select(.content_type=="application/zip") | .browser_download_url')
    echo "Downloading $GDAL_url"
    curl -LO "$GDAL_url"
    unzip -q $(basename $GDAL_url)
    echo Extracted $(basename $GDAL_url) successfully!
    rm $(basename $GDAL_url)
}

# Three paths are crucial:
# - UE_ROOT: UnrealEngine root directory (supplied as environment variable)
# - CMAKE_TOOLCHAIN_FILE: path to UE5ToolChain.cmake (that's also where this script lives)
# - CMAKE_INSTALL_PREFIX: installation path for GDAL (same as above, but the directory)
compile() {
    GDAL_tar_name=$(curl -s https://api.github.com/repos/OSGeo/gdal/releases/latest | jq -s '.[0].assets[] | select(.content_type=="application/gzip")' | jq -s -r .[0].name)
    GDAL_dir="${GDAL_tar_name%%.tar.gz}"
    cd $GDAL_dir || exit
    echo Entering build directory "$GDAL_dir/build"
    mkdir build
    cd build || exit
    cmake -DCMAKE_TOOLCHAIN_FILE=../../UE5ToolChain.cmake -DCMAKE_INSTALL_PREFIX=../../ -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DGDAL_USE_INTERNAL_LIBS=ON -DGDAL_USE_ZLIB=ON -DGDAL_USE_CURL=ON -DGDAL_USE_HEIF=OFF -DGDAL_USE_CRYPTOPP=OFF -DGDAL_USE_SPATIALITE=OFF -DGDAL_USE_HDF5=OFF -DGDAL_USE_WEBP=OFF -DGDAL_USE_FREEXL=OFF -DGDAL_USE_ARMADILLO=OFF -DGDAL_USE_HDF4=OFF -DGDAL_USE_OGDI=OFF -DGDAL_USE_OPENJPEG=OFF -DGDAL_USE_POPPLER=OFF -DGDAL_USE_JXL=OFF -DGDAL_USE_CFITSIO=OFF -DGDAL_USE_LIBKML=OFF -DGDAL_USE_MONGOCXX=OFF -DGDAL_USE_RASTERLITE2=OFF -DBUILD_JAVA_BINDINGS=OFF -DBUILD_CSHARP_BINDINGS=OFF -DBUILD_PYTHON_BINDINGS=OFF -DACCEPT_MISSING_SQLITE3_MUTEX_ALLOC=1 -DACCEPT_MISSING_SQLITE3_RTREE=1 -DOGR_ENABLE_DRIVER_ELASTIC=0 -DPROJ_LIBRARY_RELEASE="$UE_ROOT/Engine/Plugins/Runtime/GeoReferencing/Source/ThirdParty/vcpkg-installed/overlay-x64-linux/lib/libproj.a" -DPROJ_INCLUDE_DIR="$UE_ROOT/Engine/Plugins/Runtime/GeoReferencing/Source/ThirdParty/vcpkg-installed/overlay-x64-linux/include" -DSQLite3_LIBRARY="$UE_ROOT/Engine/Plugins/Runtime/GeoReferencing/Source/ThirdParty/vcpkg-installed/overlay-x64-linux/lib/libsqlite3.a" -DSQLite3_INCLUDE_DIR="$UE_ROOT/Engine/Plugins/Runtime/GeoReferencing/Source/ThirdParty/vcpkg-installed/overlay-x64-linux/include" -DTIFF_LIBRARY_RELEASE="$UE_ROOT/Engine/Source/ThirdParty/LibTiff/Lib/Unix/x86_64-unknown-linux-gnu/libtiff.a" -DTIFF_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/LibTiff/Source/Unix/x86_64-unknown-linux-gnu" -DGDAL_USE_ZLIB_INTERNAL=OFF -DZLIB_LIBRARY_RELEASE="$UE_ROOT/Engine/Source/ThirdParty/zlib/1.2.13/lib/Unix/x86_64-unknown-linux-gnu/Release/libz.a" -DZLIB_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/zlib/1.2.13/include" -DPNG_LIBRARY_RELEASE="$UE_ROOT/Engine/Source/ThirdParty/libPNG/libPNG-1.5.2/lib/Unix/x86_64-unknown-linux-gnu/libpng.a" -DPNG_PNG_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/libPNG/libPNG-1.5.2" -DJPEG_LIBRARY_RELEASE="$UE_ROOT/Engine/Source/ThirdParty/libjpeg-turbo/lib/Unix/x86_64-unknown-linux-gnu/libturbojpeg.a" -DJPEG_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/libjpeg-turbo/include" -DEXPAT_LIBRARY="$UE_ROOT/Engine/Source/ThirdParty/Expat/expat-2.2.10/Unix/x86_64-unknown-linux-gnu/Release/libexpat.a" -DEXPAT_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/Expat/expat-2.2.10/lib" -DCURL_USE_STATIC_LIBS=ON -DCURL_LIBRARY_RELEASE="$UE_ROOT/Engine/Source/ThirdParty/libcurl/8.4.0/lib/Unix/x86_64-unknown-linux-gnu/Release/libcurl.a" -DCURL_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/libcurl/8.4.0/include" -DLIBXML2_LIBRARY="$UE_ROOT/Engine/Source/ThirdParty/libxml2/libxml2-2.9.10/lib/x86_64-unknown-linux-gnu/libxml2.a" -DLIBXML2_INCLUDE_DIR="$UE_ROOT/Engine/Source/ThirdParty/libxml2/libxml2-2.9.10/include" -DOPENSSL_CRYPTO_LIBRARY=$UE_ROOT/Engine/Source/ThirdParty/OpenSSL/1.1.1t/lib/Unix/x86_64-unknown-linux-gnu/libcrypto.a -DOPENSSL_SSL_LIBRARY=$UE_ROOT/Engine/Source/ThirdParty/OpenSSL/1.1.1t/lib/Unix/x86_64-unknown-linux-gnu/libssl.a -DOPENSSL_INCLUDE_DIR=$UE_ROOT/Engine/Source/ThirdParty/OpenSSL/1.1.1t/include/Unix -DOPENSSL_USE_STATIC_LIBS=ON ..
    cmake --build .
    echo Installing GDAL
    cmake --build . --target install
    echo Removing GDAL source and build directory
    cd ../.. || exit
    rm -rf $GDAL_dir
    echo Finished downloading and building GDAL with UE!
}

downloadGDAL
compile