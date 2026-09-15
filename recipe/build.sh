#!/bin/sh
set -e -x # abort on error

# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# for an explanation of -D_LIBCPP_DISABLE_AVAILABILITY
./configure --prefix=$PREFIX --disable-devel --enable-optimizations CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
make -j${CPU_COUNT:-2}
# Only run the test suite when not cross-compiling: its Python tests cannot use
# target extension modules from the build-platform interpreter.
if [ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != 1 ]; then
    make check -j${CPU_COUNT:-2} || { cat buddy/src/test-suite.log; cat tests/test-suite.log; exit 1; }
fi
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
