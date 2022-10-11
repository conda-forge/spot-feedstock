#!/bin/sh
set -e -x # abort on error
# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# for an explanation of -D_LIBCPP_DISABLE_AVAILABILITY
./configure --prefix=$PREFIX --disable-devel --enable-optimizations CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
make
make check
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
