# stygianet-astra-sim

This repository is a fork from the original [astra-sim](https://astra-sim.github.io/). We've replaced the ns3 network backend [astra-network-ns3](https://github.com/astra-sim/astra-network-ns3/tree/astra-sim) with our version of ns3 [astra-ns3-datacenter](https://github.com/STyGIANet/astra-ns3-datacenter) which is in turn an extension from the original backend and our prior work [ns3-datacenter](https://github.com/inet-tub/ns3-datacenter). The [ns3-datacenter](https://github.com/inet-tub/ns3-datacenter) repository and hence this repository, additionally implement the algorithms from the following papers:

- [PowerTCP](https://www.usenix.org/conference/nsdi22/presentation/addanki) (TBA)
- [ABM](https://dl.acm.org/doi/abs/10.1145/3544216.3544252) (TBA)
- [Reverie](https://www.usenix.org/conference/nsdi24/presentation/addanki-reverie) (TBA)
- [Credence](https://www.usenix.org/conference/nsdi24/presentation/addanki-credence) (TBA)
- [Ethereal](https://arxiv.org/abs/2407.00550) (In progress)

In addition, we've made minor changes to non-critical files in astra-sim to resolve compilation errors with newer versions of gcc. Further, we mainly intend to use this repository for research on distributed training, and will push any new network protocols/algorithms in the near-future.

**Please refer to the original repository [astra-sim](https://astra-sim.github.io/) for installation instructions and any questions regarding astra-sim.** Nevertheless, we remain committed to help you out regarding any of the algorithms and protocols originating primarily from this fork. 


The following congestion control, buffer sharing algorithms, have been inherited from the historical version of ns3 used in this repository.

- DCTCP
- DCQCN
- Timely
- HPCC
- Dynamic Thresholds
- Everything from NS3 release versions

What this fork mainly offers is a set of new protocols and algorithms from research and scripts to run large scale evaluations. All our scripts can be found in the [acad](https://github.com/STyGIANet/astra-sim/tree/dev/acad) directory.

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

# Tested OS (Ubuntu 24.04)

```
$ uname -a
Linux berlin 6.11.0-26-generic #26~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Apr 17 19:20:47 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

$ gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/libexec/gcc/x86_64-linux-gnu/13/lto-wrapper
OFFLOAD_TARGET_NAMES=nvptx-none:amdgcn-amdhsa
OFFLOAD_TARGET_DEFAULT=1
Target: x86_64-linux-gnu
Configured with: ../src/configure -v --with-pkgversion='Ubuntu 13.3.0-6ubuntu2~24.04' --with-bugurl=file:///usr/share/doc/gcc-13/README.Bugs --enable-languages=c,ada,c++,go,d,fortran,objc,obj-c++,m2 --prefix=/usr --with-gcc-major-version-only --program-suffix=-13 --program-prefix=x86_64-linux-gnu- --enable-shared --enable-linker-build-id --libexecdir=/usr/libexec --without-included-gettext --enable-threads=posix --libdir=/usr/lib --enable-nls --enable-bootstrap --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=new --enable-libstdcxx-backtrace --enable-gnu-unique-object --disable-vtable-verify --enable-plugin --enable-default-pie --with-system-zlib --enable-libphobos-checking=release --with-target-system-zlib=auto --enable-objc-gc=auto --enable-multiarch --disable-werror --enable-cet --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m32,m64,mx32 --enable-multilib --with-tune=generic --enable-offload-targets=nvptx-none=/build/gcc-13-fG75Ri/gcc-13-13.3.0/debian/tmp-nvptx/usr,amdgcn-amdhsa=/build/gcc-13-fG75Ri/gcc-13-13.3.0/debian/tmp-gcn/usr --enable-offload-defaulted --without-cuda-driver --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu --with-build-config=bootstrap-lto-lean --enable-link-serialization=2
Thread model: posix
Supported LTO compression algorithms: zlib zstd
gcc version 13.3.0 (Ubuntu 13.3.0-6ubuntu2~24.04)
```

To install the dependencies, use the following script

```
./acad/scripts/ubuntu-dependencies.sh
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

# Notes

[Astra-sim commit](https://github.com/astra-sim/astra-sim/commit/0ea03a36887adcb50bfa12a58cb7c023710d584b) when they moved to chakra execution traces.

[iterate_hybrid_parallel_Transformer_fwd_in_bckwd](https://github.com/astra-sim/astra-sim/blob/e135b2f3b73f3be4372c98fe031801b8d00b37a7/astra-sim/workload/Workload.cc#L106C1-L107C1)

This doesn't exist anymore in Chakra's [text converter](https://github.com/mlcommons/chakra/blob/92474895d7ad0c736fe7468d5704cac052c28fd7/src/converter/text_converter.py#L131).