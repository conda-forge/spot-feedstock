#!/bin/sh
set -e -x # abort on error
# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# for an explanation of -D_LIBCPP_DISABLE_AVAILABILITY
./configure --prefix=$PREFIX --disable-devel --enable-optimizations CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
make -j2
# We use travis to build aarch64/ppc64le builds, but the time limit is to small for the test suite
case $BUILD in
    *aarch64*) ;;
    *ppc64le*) ;;
    *) make check || { cat buddy/src/test-suite.log; cat tests/test-suite.log; exit 1; } ;;
esac
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
