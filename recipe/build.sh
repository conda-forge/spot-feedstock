#!/bin/sh
set -e -x # abort on error

# See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
# for an explanation of -D_LIBCPP_DISABLE_AVAILABILITY
case "${target_platform:-}" in
    osx-*)
        # Diagnose the macOS failures without Spot's -O3/-ffast-math profile.
        ./configure --prefix=$PREFIX --disable-devel CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
        printf '%s\n' '=== macOS compiler and flags ==='
        "$CXX" --version
        printf 'CXXFLAGS=%s\nCPPFLAGS=%s\nLDFLAGS=%s\n' "$CXXFLAGS" "$CPPFLAGS" "$LDFLAGS"
        ;;
    *)
        ./configure --prefix=$PREFIX --disable-devel --enable-optimizations CPPFLAGS=-D_LIBCPP_DISABLE_AVAILABILITY
        ;;
esac
make -j${CPU_COUNT:-2}
# Only run the test suite when not cross-compiling: its Python tests cannot use
# target extension modules from the build-platform interpreter.
if [ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != 1 ]; then
    case "${target_platform:-}" in
        osx-*)
            # Restrict macOS runs to the failures under investigation.
            status=0
            make -C tests check TESTS='core/tgbagraph.test core/alternating.test python/alternating.py python/twagraph.py' || status=1
            if [ "$status" -ne 0 ]; then
                cat tests/test-suite.log
                printf '%s\n' '=== macOS dynamic library linkage ==='
                otool -L tests/core/tgbagraph
                find python -type f -name '*.so' -exec otool -L {} \;
                printf '%s\n' '=== lldb backtrace for tgbagraph ==='
                ./libtool e lldb --batch -o run -o bt -- tests/core/tgbagraph
                exit "$status"
            fi
            ;;
        *)
            make check -j${CPU_COUNT:-2} || { cat buddy/src/test-suite.log; cat tests/test-suite.log; exit 1; }
            ;;
    esac
fi
make install-strip
mkdir -p $PREFIX/share/doc/spot/examples
cp tests/python/[a-z]*.ipynb $PREFIX/share/doc/spot/examples
