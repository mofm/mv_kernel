#!/bin/bash

# This script is used to build the kernel for microvm (x86_64 and aarch64)

KERNEL_URL_BASE="https://cdn.kernel.org/pub/linux/kernel"

die() {
    echo "[ERROR] $1" >&2
    echo "$USAGE" >&2 # To be filled by the caller.
    # Kill the caller.
    if [ -n "$TOP_PID" ]; then kill -s TERM "$TOP_PID"; else exit 1; fi
}

pushd_quiet() {
    pushd "$1" &>/dev/null || die "Failed to enter $1."
}

popd_quiet() {
    popd &>/dev/null || die "Failed to exit directory."
}

# Usage:
#   extract_kernel_srcs kernel_version
extract_kernel_srcs() {
    kernel_version="$1"

    [ -z "$kernel_version" ] && die "Kernel version not specified."

    # This magic trick gets the major component of the version number.
    kernel_major="${kernel_version%%.*}"
    kernel_archive="linux-$kernel_version.tar.xz"
    kernel_url="$KERNEL_URL_BASE/v$kernel_major.x/$kernel_archive"

    echo "Starting kernel build."
    # Download kernel sources.
    echo "Downloading kernel from $kernel_url"
    [ -f "$kernel_archive" ] || curl "$kernel_url" > "$kernel_archive"
    echo "Extracting kernel sources..."
    tar --skip-old-files -xf "$kernel_archive"
}

# Usage:
#   make_kernel_config /path/to/source/config /path/to/kernel
make_kernel_config() {
    # Copy base kernel config.
    kernel_config="$1"
    kernel_dir="$2"

    [ -z "$kernel_config" ] && die "Kernel config file not specified."
    [ ! -f "$kernel_config" ] && die "Kernel config file not found."
    [ -z "$kernel_dir" ] && die "Kernel directory not specified."
    [ ! -d "$kernel_dir" ] && die "Kernel directory not found."

    echo "Copying kernel config..."
    cp "$kernel_config" "$kernel_dir/.config"
    pushd_quiet "$kernel_dir"
    echo "Making kernel config..."
    make olddefconfig
    popd_quiet
}

kernel_target() {
    arch=$(uname -m)
    case "$arch" in
        x86_64) echo "bzImage" ;;
        aarch64) echo "Image" ;;
        *) die "Unsupported architecture: $arch" ;;
    esac
}

# Usage: kernel_binary
# Prints the name of the generated kernel binary.
kernel_binary() {
    arch=$(uname -m)

    if [ $arch = "x86_64" ]; then
        echo "arch/x86_64/boot/bzImage"
    elif [ $arch = "aarch64" ]; then
        echo "arch/arm64/boot/Image"
    else
        die "Unsupported architecture!"
    fi
}

# Usage:
#   make_kernel
#       /path/to/kernel/dir \
#       [/path/to/kernel/destination]
make_kernel() {
    kernel_dir="$1"
    dst="$2"

    [ -z "$kernel_dir" ] && die "Kernel directory not specified."
    [ ! -d "$kernel_dir" ] && die "Kernel directory not found."

    target=$(kernel_target)
    nprocs=$(nproc)
    kernel_binary=$(kernel_binary)

    # Move to the directory with the kernel sources.
    pushd_quiet "$kernel_dir"

    # Build kernel.
    echo "Building kernel..."
    make -j "$nprocs" $target

    if [ -n "$dst" ] && [ "$kernel_binary" != "$dst" ]; then
        echo "Copying kernel binary to $dst"
        # Copy to destination.
        cp -v "$kernel_binary" "$dst"
    fi

    # Return to previous directory.
    popd_quiet
}

clean_kernel_srcs() {
    kernel_dir="$1"

    [ -z "$kernel_dir" ] && die "Kernel directory not specified."
    [ ! -d "$kernel_dir" ] && die "Kernel directory not found."

    # Move to the directory with the kernel sources.
    pushd_quiet "$kernel_dir"

    # Clean kernel sources.
    echo "Cleaning kernel sources..."
    make clean && make mrproper

    # Return to previous directory.
    popd_quiet
}