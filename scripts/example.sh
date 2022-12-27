#!/bin/bash
#
# Example build script
# Optional parameteres below:
set -o nounset
set -o errexit

export LC_ALL=POSIX
export CONFIG_HOST=`echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/'`

export CC="$TOOLS_DIR/bin/$CONFIG_TARGET-gcc"
export CXX="$TOOLS_DIR/bin/$CONFIG_TARGET-g++"
export AR="$TOOLS_DIR/bin/$CONFIG_TARGET-ar"
export AS="$TOOLS_DIR/bin/$CONFIG_TARGET-as"
export LD="$TOOLS_DIR/bin/$CONFIG_TARGET-ld"
export RANLIB="$TOOLS_DIR/bin/$CONFIG_TARGET-ranlib"
export READELF="$TOOLS_DIR/bin/$CONFIG_TARGET-readelf"
export STRIP="$TOOLS_DIR/bin/$CONFIG_TARGET-strip"
export PATH="$TOOLS_DIR/bin:$TOOLS_DIR/sbin:$PATH"

# End of optional parameters

function step() {
  echo -e "\e[7m\e[1m>>> $1\e[0m"
}

function success() {
  echo -e "\e[1m\e[32m$1\e[0m"
}

function error() {
  echo -e "\e[1m\e[31m$1\e[0m"
}

function extract() {
  case $1 in
    *.tgz) tar -zxf $1 -C $2 ;;
    *.tar.gz) tar -zxf $1 -C $2 ;;
    *.tar.bz2) tar -jxf $1 -C $2 ;;
    *.tar.xz) tar -Jxf $1 -C $2 ;;
  esac
}

function check_environment {
  if ! [[ -d $SOURCES_DIR ]] ; then
    error "Please download tarball files!"
    error "Run 'make download'"
    exit 1
  fi
}

function check_tarballs {
    LIST_OF_TARBALLS="
      libaio-0.3.113.tar.gz
      fio-3.33.tar.gz
    "

    for tarball in $LIST_OF_TARBALLS ; do
        if ! [[ -f $SOURCES_DIR/$tarball ]] ; then
            error "Can't find '$tarball'!"
            exit 1
        fi
    done
}

function timer {
  if [[ $# -eq 0 ]]; then
    echo $(date '+%s')
  else
    local stime=$1
    etime=$(date '+%s')
    if [[ -z "$stime" ]]; then stime=$etime; fi
    dt=$((etime - stime))
    ds=$((dt % 60))
    dm=$(((dt / 60) % 60))
    dh=$((dt / 3600))
    printf '%02d:%02d:%02d' $dh $dm $ds
  fi
}

check_environment
check_tarballs
total_build_time=$(timer)

rm -rf $BUILD_DIR $ROOTFS_DIR
mkdir -pv $BUILD_DIR $ROOTFS_DIR

step "[1/2] libaio 0.3.113"
extract $SOURCES_DIR/libaio-0.3.113.tar.gz $BUILD_DIR
make -j$PARALLEL_JOBS -C $BUILD_DIR/libaio-0.3.113
make -j$PARALLEL_JOBS DESTDIR=$SYSROOT_DIR install -C $BUILD_DIR/libaio-0.3.113
rm -rf $BUILD_DIR/libaio-0.3.113

step "[2/2] fio 3.33"
extract $SOURCES_DIR/fio-3.33.tar.gz $BUILD_DIR
( cd $BUILD_DIR/fio-fio-3.33 && \
    LDFLAGS="--static" \
    libaio=yes \
    posix_aio=yes \
    posix_aio_lrt=yes \
    posix_aio_fsync=yes \
    $BUILD_DIR/fio-fio-3.33/configure \
    --prefix=/usr )
make -j$PARALLEL_JOBS -C $BUILD_DIR/fio-fio-3.33
make -j$PARALLEL_JOBS DESTDIR=$ROOTFS_DIR install -C $BUILD_DIR/fio-fio-3.33
rm -rf $BUILD_DIR/fio-fio-3.33

success "\nTotal build time: $(timer $total_build_time)\n"