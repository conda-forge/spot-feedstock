#!/bin/sh
set -e -x # abort on error

# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# for an explanation of -D_LIBCPP_DISABLE_AVAILABILITY
./configure --prefix=$PREFIX --disable-devel --enable-optimizations CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
make -j${CPU_COUNT:-2}
# We use travis to build aarch64/ppc64le builds, but the time limit is too small for the test suite
case $BUILD_PLATFORM in
    *aarch64*) ;;
    *ppc64le*) ;;
    # Only run the test when not cross-compiling
    *) if [ "${CONDA_BUILD_CROSS_COMPILATION:0}" != 1 ] || [ "${CROSSCOMPILING_EMULATOR:0}" != "" ]; then
            make check -j${CPU_COUNT:-2} || { cat buddy/src/test-suite.log; cat tests/test-suite.log; exit 1; }
        fi;;
esac
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
