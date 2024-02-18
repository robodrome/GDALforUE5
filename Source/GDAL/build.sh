#!/bin/sh

# Check for help argument
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  echo "Usage: $0 <install_path>"
  echo
  echo "CMAKE_INSTALL_PREFIX is the directory where GDAL will be installed."
  echo "Default is the current working directory. NOTE: No trailing slash!"
  echo
  echo "Make sure you have these packages installed: cmake, curl, jq, unzip"
  echo "You can install them like this: 'sudo apt install cmake curl jq unzip'"
  exit 0
fi

# Set default install path to current directory if not provided
INSTALL_PATH="${1:-$(pwd)}"
echo "Installing GDAL to $INSTALL_PATH"

downloadGDAL() {
    GDAL_url=$(curl -s https://api.github.com/repos/OSGeo/gdal/releases/latest | jq -s -r '.[0].assets[] | select(.content_type=="application/zip") | .browser_download_url')
    echo "Downloading $GDAL_url"
    curl -LO "$GDAL_url"
    unzip -q $(basename $GDAL_url)
    echo Extracted $(basename $GDAL_url) successfully!
    rm $(basename $GDAL_url)
}

compileGDAL() {
    GDAL_tar_name=$(curl -s https://api.github.com/repos/OSGeo/gdal/releases/latest | jq -s '.[0].assets[] | select(.content_type=="application/gzip")' | jq -s -r .[0].name)
    GDAL_dir="${GDAL_tar_name%%.tar.gz}"
    if [ ! -d "$GDAL_dir" ]; then
        echo "Error: GDAL directory does not exist."
        exit 1
    fi
    cd "$GDAL_dir" || exit
    echo Entering build directory "$GDAL_dir/build"
    mkdir -p build
    cd build || exit
    cmake -DCMAKE_INSTALL_PREFIX="$INSTALL_PATH" ..
    cmake --build . -j"$(nproc)"
    echo "Installing GDAL"
    cmake --build . --target install
    echo "Removing GDAL source and build directory"
    cd ../.. || exit
    rm -rf "$GDAL_dir"
    echo "Finished downloading and building GDAL with UE!"
}

downloadGDAL
compileGDAL
