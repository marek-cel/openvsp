#!/bin/bash

################################################################################
# OpenVSP Ubuntu 18.04 (LinuxMint 19.2) building script
################################################################################

BASE_NAME=OpenVSP
VERSION=3.16.2
FULL_NAME=$BASE_NAME-$VERSION

################################################################################
# INSTALLING DEPENDENCIES
################################################################################

sudo apt-get install \
    git \
    git-gui \
    cmake \
    libxml2-dev \
    libfltk1.3-dev \
    fluid \
    g++ \
    libcpptest-dev \
    libjpeg-dev \
    libglm-dev \
    libeigen3-dev \
    libcminpack-dev \
    libglew-dev \
    swig \
    doxygen

################################################################################
# CREATING BUILDING ENVIRONMENT
################################################################################

sudo rm -r -f temp

mkdir temp
cd temp

TEMP_DIR=${PWD}

mkdir build buildlibs

git clone https://github.com/OpenVSP/OpenVSP.git repo

################################################################################
# BUILDING LIBS
################################################################################

cd buildlibs

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DVSP_USE_SYSTEM_CPPTEST=false \
    -DVSP_USE_SYSTEM_LIBXML2=false \
    -DVSP_USE_SYSTEM_EIGEN=false \
    -DVSP_USE_SYSTEM_FLTK=false \
    -DVSP_USE_SYSTEM_GLM=false \
    -DVSP_USE_SYSTEM_GLEW=true \
    -DVSP_USE_SYSTEM_CMINPACK=true \
    -DVSP_USE_SYSTEM_CODEELI=false \
    -DVSP_USE_SYSTEM_LIBIGES=false \
    ../repo/Libraries
    
make -j8

BUILDLIBDS_DIR=${PWD}

cd ..

################################################################################
# CONFIGURING MAIN PROGRAM
################################################################################

cd build

echo $BUILDLIBDS_DIR

# FLTK issues fix

cp ../buildlibs/FLTK-prefix/bin/fluid ../repo/src/vsp_aero/viewer/
cp ../buildlibs/FLTK-prefix/bin/fluid ../repo/src/fltk_screens/

cmake \
    ../repo/src/ \
    -DVSP_LIBRARY_PATH=$BUILDLIBDS_DIR \
    -DCMAKE_BUILD_TYPE=Release

# LIBXML issues fix
echo -e "\e[1;33m"
echo "LIBXML fix"
echo ""
echo "In file $TEMP_DIR/build/CMakeCache.txt:"
echo "- replace line:"
echo "LIBXML2_INCLUDE_DIR:PATH=$TEMP_DIR/buildlibs/LIBXML2-prefix/include/libxml2"
echo "with the following one:"
echo "LIBXML2_INCLUDE_DIR:PATH=/usr/include/libxml2"
echo "- add line:"
echo "LIBXML2_LIBRARIES:FILEPATH=/usr/lib/x86_64-linux-gnu/libxml2.so"
echo "- do NOT replace the LIBXML2_LIBRARY path!"
echo -e "\e[0m"
echo ""
read -p "Press any key to continue ..." -n1 -s

################################################################################
# BUILDING MAIN PROGRAM
################################################################################

make -j 4

make package

################################################################################
