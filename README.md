# aarch64-static-linux-musl

A toolchain designed for easy static build for aarch64! 🛠️

## Preparing Build Environment

Ubuntu 20.04 is recommended.

```bash
sudo apt update
sudo apt install gcc g++ make wget
```

## Step 1) Download All The Packages

```bash
make download
```

## Step 2) Build Toolchain

```bash
make toolchain
```

```
$ out/tools/bin/aarch64-static-linux-musl-gcc --version
aarch64-static-linux-musl-gcc (aarch64 2022.12) 11.2.0
Copyright (C) 2021 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

## Usage Example

For example, I wrote a static build of `fio`. It can be executed with `make example`, and the code is `scripts/example.sh`.

## Packages

- Autoconf 2.71
- Automake 1.16.4
- Binutils 2.37
- Bison 3.7.6
- Gawk 5.1.0
- Gcc 11.2.0
- Gmp 6.2.1
- Libtool 2.4.6
- Linux 5.4.228
- M4 1.4.19
- Mpc 1.2.1
- Mpfr 4.1.0
- Musl 1.2.3
- Pkgconf 1.8.0
- Zlib 1.2.11
