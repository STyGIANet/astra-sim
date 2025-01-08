# stygianet-astra-sim

This repository is a fork from the original [astra-sim](https://astra-sim.github.io/). We've replaced the ns3 network backend [astra-network-ns3](https://github.com/astra-sim/astra-network-ns3/tree/astra-sim) with our version of ns3 [astra-ns3-datacenter](https://github.com/STyGIANet/astra-ns3-datacenter) which is in turn an extension from the original backend and our prior work [ns3-datacenter](https://github.com/inet-tub/ns3-datacenter). The [ns3-datacenter](https://github.com/inet-tub/ns3-datacenter) repository and hence this repository, additionally implement the algorithms from the following papers:

- [PowerTCP](https://www.usenix.org/conference/nsdi22/presentation/addanki) (TBA)
- [ABM](https://dl.acm.org/doi/abs/10.1145/3544216.3544252) (TBA)
- [Reverie](https://www.usenix.org/conference/nsdi24/presentation/addanki-reverie) (TBA)
- [Credence](https://www.usenix.org/conference/nsdi24/presentation/addanki-credence) (TBA)
- [Ethereal](https://arxiv.org/abs/2407.00550) (In progress)

In addition, we've made minor changes to non-critical files in astra-sim to resolve compilation errors with newer versions of gcc. Further, we mainly intend to use this repository for research on distributed training, and will push any new network protocols/algorithms in the near-future.

**Please refer to the original repository [astra-sim](https://astra-sim.github.io/) for installation instructions and any questions regarding astra-sim.** Nevertheless, we remain committed to help you out regarding any of the algorithms and protocols originating primarily from this fork.

**All our scripts can be found in the [acad](https://github.com/STyGIANet/astra-sim/tree/dev/acad) directory.**

The following congestion control, buffer sharing algorithms, have been inherited from the historical version of ns3 used in this repository.

- DCTCP
- DCQCN
- Timely
- HPCC
- Dynamic Thresholds
- Everything from NS3 release versions

What this fork mainly offers is a set of new protocols and algorithms from research and scripts to run large scale evaluations.

# Clone and Setup a Development Environment

## Git

```
git clone --recursive git@github.com:STyGIANet/astra-sim.git
cd astra-sim/
cd extern/network_backend/ns-3/
git checkout dev
git remote set-url git@github.com:STyGIANet/astra-sim.git # if you have access to push changes
cd -
git config --add submodule.recurse true
```

# Tested OS (Fedora)

```
$ uname -r
6.12.5-200.fc41.x86_64

$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-redhat-linux/13/lto-wrapper
Target: x86_64-redhat-linux
Configured with: ../configure --enable-bootstrap --enable-languages=c,c++,fortran,lto --prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info --with-bugurl=http://bugzilla.redhat.com/bugzilla --enable-shared --enable-threads=posix --enable-checking=release --disable-multilib --with-system-zlib --enable-__cxa_atexit --disable-libunwind-exceptions --enable-gnu-unique-object --enable-linker-build-id --with-gcc-major-version-only --enable-libstdcxx-backtrace --with-libstdcxx-zoneinfo=/usr/share/zoneinfo --with-linker-hash-style=gnu --enable-plugin --enable-initfini-array --without-isl --enable-gnu-indirect-function --enable-cet --with-tune=generic --with-arch_32=i686 --build=x86_64-redhat-linux --with-build-config=bootstrap-lto --enable-link-serialization=1
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 13.3.1 20240611 (Red Hat 13.3.1-2) (GCC)
```

To install the dependencies, use the following script

```
./fedora-dependencies.sh
```

For ubuntu:

```
./ubuntu-dependencies.sh
```
# Example

## Generate Leaf Spine Topology

```
cd acad/scripts/
python generate-topology.py -l 0.0005ms -nicbw 400Gbps -t1bw 400Gbps -g 256 -tors 16 -spines 16 -topo leafspine
```

## Generate k-ary FatTree Topology

```
cd acad/scripts/
python generate-topology.py -l 0.0005ms -nicbw 400Gbps -t1bw 1600Gbps -t2bw 1600Gbps -topo fattree -k 8 -os 4
cd -
```

## Build

Build the analytical framework first.

```
./build/astra_analytical/build.sh
```

Build NS3

```
./acad/scripts/build.sh -l
./acad/scripts/build.sh -c
```

# Apptainer

```
cd acad/scripts/
singularity build astra-sim.sif Singularity.def
```

# Critical Changes

TBA