#!/bin/bash

set -x -euo pipefail

BPFTRACE_VERSION=${BPFTRACE_VERSION:-0.22.1}
BUILD_BPFTRACE=${BUILD_BPFTRACE:-}

BIN_DIR=/usr/local/bin
sudo mkdir -p $BIN_DIR

if [[ -n "$BUILD_BPFTRACE" ]]; then
    # see https://github.com/bpftrace/bpftrace/blob/master/docker/Dockerfile.ubuntu
    sudo apt-get install -y \
         asciidoctor binutils-dev bison build-essential clang cmake flex git libbpf-dev \
         libbpfcc-dev libcereal-dev libelf-dev libiberty-dev libpcap-dev llvm-dev liblldb-dev \
         libclang-dev systemtap-sdt-dev zlib1g-dev
    git clone --depth 1 -b v${BPFTRACE_VERSION} https://github.com/bpftrace/bpftrace
    cd bpftrace/src
    cmake -B build -DBUILD_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DLLVM_DIR=$(llvm-config --prefix)/lib/cmake/llvm
    make -C build -j$(nproc)
    cd -
    sudo mv bpftrace/src/build/bpftrace $BIN_DIR/bpftrace
else # download AppImage
    sudo curl -L -o $BIN_DIR/bpftrace https://github.com/bpftrace/bpftrace/releases/download/v${BPFTRACE_VERSION}/bpftrace
fi

sudo chmod +x $BIN_DIR/bpftrace

# mount tracefs to avoid warnings from bpftrace
grep -q tracefs /proc/mounts || mount -t tracefs tracefs /sys/kernel/tracing

# sanity check
bpftrace --version

