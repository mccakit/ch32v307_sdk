cmake_minimum_required(VERSION 4.2)
project(
    hello_mcu
    VERSION 0.0.0
    DESCRIPTION "placeholder"
    LANGUAGES C ASM CXX
)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(SDK_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
set(MCU_LIBDIR ${SDK_DIR}/CH32V307VCT6)
add_executable(main
    main.cpp
    libc_malloc.c
    libcxx_new.cpp
    llvm_libc_shim.c
    "${MCU_LIBDIR}/Startup/startup_ch32v30x_D8C.S"
    "${MCU_LIBDIR}/User/system_ch32v30x.c"
)
target_link_options(main PUBLIC -T ${MCU_LIBDIR}/Ld/Link.ld)

file(GLOB CH32V30X_SOURCES
    "${MCU_LIBDIR}/Peripheral/src/*.c"
    "${MCU_LIBDIR}/Core/*.c"
    "${MCU_LIBDIR}/Debug/Debug/*.c"
)
add_library(ch32v30x STATIC ${CH32V30X_SOURCES})
target_include_directories(ch32v30x PUBLIC
    "${MCU_LIBDIR}/Peripheral/inc"
    "${MCU_LIBDIR}/Core/"
    "${MCU_LIBDIR}/Debug"
    "${MCU_LIBDIR}/User"
)

set(FREERTOS_ROOT "${SDK_DIR}/FreeRTOS")
set(FREERTOS_PORT_DIR "${FREERTOS_ROOT}/portable/GCC/RISC-V")

# --- 1. GLOB FreeRTOS Core (tasks.c, list.c, etc.) ---
file(GLOB FREERTOS_CORE_SOURCES "${FREERTOS_ROOT}/*.c")

# --- 2. GLOB The WCH Port Files ---
file(GLOB FREERTOS_PORT_SOURCES
    "${FREERTOS_PORT_DIR}/port.c"
    "${FREERTOS_PORT_DIR}/portASM.S"
)

# --- 3. Pick a Heap (You NEED this for xTaskCreate to work) ---
# Most people use heap_4.c for general purpose
set(FREERTOS_HEAP_SOURCE "${FREERTOS_ROOT}/portable/MemMang/heap_4.c")

# --- 4. Define the Library ---
add_library(freertos STATIC
    ${FREERTOS_CORE_SOURCES}
    ${FREERTOS_PORT_SOURCES}
    ${FREERTOS_HEAP_SOURCE}
)
target_link_libraries(freertos PUBLIC ch32v30x)

# --- 5. Include "All The Things" ---
target_include_directories(freertos PUBLIC
    ${FREERTOS_ROOT}/include
    ${FREERTOS_PORT_DIR}
    ${FREERTOS_PORT_DIR}/chip_specific_extensions/RV32I_PFIC_no_extensions
    ${SDK_DIR}
)


target_link_libraries(main PUBLIC ch32v30x freertos)
