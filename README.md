# ch32v307_sdk
To build the example you need to bring your own clang and lld, also you need wchisp. I used clang 23.
cd example/cmake/blink
cmake -B build -G Ninja -DCMAKE_TOOLCHAIN_FILE="./toolchains"
cmake --build build
llvm-objcopy -O binary   --only-section=.init   --only-section=.vector   --only-section=.text   --only-section=.fini   --only-section=.preinit_array   --only-section=.init_array   --only-section=.fini_array   --only-section=.ctors   --only-section=.dtors   --only-section=.dlalign   --only-section=.data   --only-section=.got   build/main ./build/main.bin
sudo /home/mccakit/dev/tooling/wchisp/bin/wchisp flash build/main.bin

SDK files(Drivers link scripts etc) are from https://github.com/openwch/ch32v307 so is the FreeRTOS


LLVM libc, compiler-rt and libcxx is built in the sdk and distributed in binary form
