/*

 * FreeRTOS Kernel V10.4.6

 * Copyright (C) 2021 Amazon.com, Inc. or its affiliates.  All Rights Reserved.

 *

 * SPDX-License-Identifier: MIT

 *

 * Permission is hereby granted, free of charge, to any person obtaining a copy of

 * this software and associated documentation files (the "Software"), to deal in

 * the Software without restriction, including without limitation the rights to

 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of

 * the Software, and to permit persons to whom the Software is furnished to do so,

 * subject to the following conditions:

 *

 * The above copyright notice and this permission notice shall be included in all

 * copies or substantial portions of the Software.

 *

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR

 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS

 * FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR

 * COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER

 * IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN

 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 *

 * https://www.FreeRTOS.org

 * https://github.com/FreeRTOS

 *

 */


/*

 * The FreeRTOS kernel's RISC-V port is split between the code that is

 * common across all currently supported RISC-V chips (implementations of the

 * RISC-V ISA), and code which tailors the port to a specific RISC-V chip:

 *

 * + The code that is common to all RISC-V chips is implemented in

 *   FreeRTOS\Source\portable\GCC\RISC-V-RV32\portASM.S.  There is only one

 *   portASM.S file because the same file is used no matter which RISC-V chip is

 *   in use.

 *

 * + The code that tailors the kernel's RISC-V port to a specific RISC-V

 *   chip is implemented in freertos_risc_v_chip_specific_extensions.h.  There

 *   is one freertos_risc_v_chip_specific_extensions.h that can be used with any

 *   RISC-V chip that both includes a standard CLINT and does not add to the

 *   base set of RISC-V registers.  There are additional

 *   freertos_risc_v_chip_specific_extensions.h files for RISC-V implementations

 *   that do not include a standard CLINT or do add to the base set of RISC-V

 *   registers.

 *

 * CARE MUST BE TAKEN TO INCLUDE THE CORRECT

 * freertos_risc_v_chip_specific_extensions.h HEADER FILE FOR THE CHIP

 * IN USE.  To include the correct freertos_risc_v_chip_specific_extensions.h

 * header file ensure the path to the correct header file is in the assembler's

 * include path.

 *

 * This freertos_risc_v_chip_specific_extensions.h is for use on RISC-V chips

 * that include a standard CLINT and do not add to the base set of RISC-V

 * registers.

 *

 */

#if __riscv_xlen == 64

    #define portWORD_SIZE 8

    #define store_x sd

    #define load_x ld

#elif __riscv_xlen == 32

    #define store_x sw

    #define load_x lw

    #define portWORD_SIZE 4

#else

    #error Assembler did not define __riscv_xlen

#endif


/* we define float registers at specific_extensions.h, V30x support hardware floating point unit

can be enable by defined ARCH_FPU*/

#include "freertos_risc_v_chip_specific_extensions.h"



/* Check the freertos_risc_v_chip_specific_extensions.h and/or command line

definitions. */

#if defined( portasmHAS_CLINT ) && defined( portasmHAS_MTIME )

    #error The portasmHAS_CLINT constant has been deprecated.  Please replace it with portasmHAS_MTIME.  portasmHAS_CLINT and portasmHAS_MTIME cannot both be defined at once.  See https://www.FreeRTOS.org/Using-FreeRTOS-on-RISC-V.html

#endif


#ifdef portasmHAS_CLINT

    #warning The portasmHAS_CLINT constant has been deprecated.  Please replace it with portasmHAS_MTIME and portasmHAS_SIFIVE_CLINT.  For now portasmHAS_MTIME and portasmHAS_SIFIVE_CLINT are derived from portasmHAS_CLINT.  See https://www.FreeRTOS.org/Using-FreeRTOS-on-RISC-V.html

    #define portasmHAS_MTIME portasmHAS_CLINT

    #define portasmHAS_SIFIVE_CLINT portasmHAS_CLINT

#endif


#ifndef portasmHAS_MTIME

    #error freertos_risc_v_chip_specific_extensions.h must define portasmHAS_MTIME to either 1 (MTIME clock present) or 0 (MTIME clock not present).  See https://www.FreeRTOS.org/Using-FreeRTOS-on-RISC-V.html

#endif


#ifndef portasmHANDLE_INTERRUPT /* don't need this define */

#    #error portasmHANDLE_INTERRUPT must be defined to the function to be called to handle external/peripheral interrupts.  portasmHANDLE_INTERRUPT can be defined on the assembler command line or in the appropriate freertos_risc_v_chip_specific_extensions.h header file.  https://www.FreeRTOS.org/Using-FreeRTOS-on-RISC-V.html

#endif


#ifndef portasmHAS_SIFIVE_CLINT

    #define portasmHAS_SIFIVE_CLINT 0

#endif


/* Only the standard core registers are stored by default.  Any additional

registers must be saved by the portasmSAVE_ADDITIONAL_REGISTERS and

portasmRESTORE_ADDITIONAL_REGISTERS macros - which can be defined in a chip

specific version of freertos_risc_v_chip_specific_extensions.h.  See the notes

at the top of this file. */

#define portCONTEXT_SIZE ( 30 * portWORD_SIZE )


.globl xPortStartFirstTask
.globl SW_Handler
.globl pxPortInitialiseStack

.extern pxCurrentTCB
.extern vTaskSwitchContext
.extern xISRStackTop

/*-----------------------------------------------------------*/

.align 8

SW_Handler:

    addi sp, sp, -portCONTEXT_SIZE

    store_x x1, 1 * portWORD_SIZE( sp )

    store_x x5, 2 * portWORD_SIZE( sp )

    store_x x6, 3 * portWORD_SIZE( sp )

    store_x x7, 4 * portWORD_SIZE( sp )

    store_x x8, 5 * portWORD_SIZE( sp )

    store_x x9, 6 * portWORD_SIZE( sp )

    store_x x10, 7 * portWORD_SIZE( sp )

    store_x x11, 8 * portWORD_SIZE( sp )

    store_x x12, 9 * portWORD_SIZE( sp )

    store_x x13, 10 * portWORD_SIZE( sp )

    store_x x14, 11 * portWORD_SIZE( sp )

    store_x x15, 12 * portWORD_SIZE( sp )

    store_x x16, 13 * portWORD_SIZE( sp )

    store_x x17, 14 * portWORD_SIZE( sp )

    store_x x18, 15 * portWORD_SIZE( sp )

    store_x x19, 16 * portWORD_SIZE( sp )

    store_x x20, 17 * portWORD_SIZE( sp )

    store_x x21, 18 * portWORD_SIZE( sp )

    store_x x22, 19 * portWORD_SIZE( sp )

    store_x x23, 20 * portWORD_SIZE( sp )

    store_x x24, 21 * portWORD_SIZE( sp )

    store_x x25, 22 * portWORD_SIZE( sp )

    store_x x26, 23 * portWORD_SIZE( sp )

    store_x x27, 24 * portWORD_SIZE( sp )

    store_x x28, 25 * portWORD_SIZE( sp )

    store_x x29, 26 * portWORD_SIZE( sp )

    store_x x30, 27 * portWORD_SIZE( sp )

    store_x x31, 28 * portWORD_SIZE( sp )


    csrr t0, mstatus                    /* Required for MPIE bit. */

    store_x t0, 29 * portWORD_SIZE( sp )


    portasmSAVE_ADDITIONAL_REGISTERS    /* Defined in freertos_risc_v_chip_specific_extensions.h to save any registers unique to the RISC-V implementation. */


    load_x  t0, pxCurrentTCB            /* Load pxCurrentTCB. */

    store_x  sp, 0( t0 )                /* Write sp to first TCB member. */


    csrr a1, mepc

    store_x a1, 0( sp )                    /* Save updated exception return address. */


    addi a1, x0, 0x20

    csrs 0x804, a1


    load_x sp, xISRStackTop                /* Switch to ISR stack before function call. */

    jal vTaskSwitchContext


processed_source:

    load_x  t1, pxCurrentTCB            /* Load pxCurrentTCB. */

    load_x  sp, 0( t1 )                     /* Read sp from first TCB member. */


    /* Load mret with the address of the next instruction in the task to run next. */

    load_x t0, 0( sp )

    csrw mepc, t0


    portasmRESTORE_ADDITIONAL_REGISTERS    /* Defined in freertos_risc_v_chip_specific_extensions.h to restore any registers unique to the RISC-V implementation. */


    /* Load mstatus with the interrupt enable bits used by the task. */

    load_x  t0, 29 * portWORD_SIZE( sp )

    csrw mstatus, t0                        /* Required for MPIE bit. */


    load_x  x1, 1 * portWORD_SIZE( sp )

    load_x  x5, 2 * portWORD_SIZE( sp )        /* t0 */

    load_x  x6, 3 * portWORD_SIZE( sp )        /* t1 */

    load_x  x7, 4 * portWORD_SIZE( sp )        /* t2 */

    load_x  x8, 5 * portWORD_SIZE( sp )        /* s0/fp */

    load_x  x9, 6 * portWORD_SIZE( sp )        /* s1 */

    load_x  x10, 7 * portWORD_SIZE( sp )    /* a0 */

    load_x  x11, 8 * portWORD_SIZE( sp )    /* a1 */

    load_x  x12, 9 * portWORD_SIZE( sp )    /* a2 */

    load_x  x13, 10 * portWORD_SIZE( sp )    /* a3 */

    load_x  x14, 11 * portWORD_SIZE( sp )    /* a4 */

    load_x  x15, 12 * portWORD_SIZE( sp )    /* a5 */

    load_x  x16, 13 * portWORD_SIZE( sp )    /* a6 */

    load_x  x17, 14 * portWORD_SIZE( sp )    /* a7 */

    load_x  x18, 15 * portWORD_SIZE( sp )    /* s2 */

    load_x  x19, 16 * portWORD_SIZE( sp )    /* s3 */

    load_x  x20, 17 * portWORD_SIZE( sp )    /* s4 */

    load_x  x21, 18 * portWORD_SIZE( sp )    /* s5 */

    load_x  x22, 19 * portWORD_SIZE( sp )    /* s6 */

    load_x  x23, 20 * portWORD_SIZE( sp )    /* s7 */

    load_x  x24, 21 * portWORD_SIZE( sp )    /* s8 */

    load_x  x25, 22 * portWORD_SIZE( sp )    /* s9 */

    load_x  x26, 23 * portWORD_SIZE( sp )    /* s10 */

    load_x  x27, 24 * portWORD_SIZE( sp )    /* s11 */

    load_x  x28, 25 * portWORD_SIZE( sp )    /* t3 */

    load_x  x29, 26 * portWORD_SIZE( sp )    /* t4 */

    load_x  x30, 27 * portWORD_SIZE( sp )    /* t5 */

    load_x  x31, 28 * portWORD_SIZE( sp )    /* t6 */

    addi sp, sp, portCONTEXT_SIZE


    mret
/*-----------------------------------------------------------*/

.align 8

xPortStartFirstTask:

    /* Switch to ISR stack and reserve space if needed */
    lw t0, xISRStackTop
    addi t0, t0, -512
    csrw mscratch, t0

    /* Load the top of the current TCB stack */
    load_x sp, pxCurrentTCB
    load_x sp, 0(sp)                 /* Read sp from first TCB member */

    /* Load return address for scheduler */
    load_x x1, 0(sp)

    portasmRESTORE_ADDITIONAL_REGISTERS /* Restore chip-specific registers if any */

    /* Restore task registers */
    load_x x6, 3 * portWORD_SIZE(sp)   /* t1 */
    load_x x7, 4 * portWORD_SIZE(sp)   /* t2 */
    load_x x8, 5 * portWORD_SIZE(sp)   /* s0/fp */
    load_x x9, 6 * portWORD_SIZE(sp)   /* s1 */
    load_x x10, 7 * portWORD_SIZE(sp)  /* a0 */
    load_x x11, 8 * portWORD_SIZE(sp)  /* a1 */
    load_x x12, 9 * portWORD_SIZE(sp)  /* a2 */
    load_x x13, 10 * portWORD_SIZE(sp) /* a3 */
    load_x x14, 11 * portWORD_SIZE(sp) /* a4 */
    load_x x15, 12 * portWORD_SIZE(sp) /* a5 */
    load_x x16, 13 * portWORD_SIZE(sp) /* a6 */
    load_x x17, 14 * portWORD_SIZE(sp) /* a7 */
    load_x x18, 15 * portWORD_SIZE(sp) /* s2 */
    load_x x19, 16 * portWORD_SIZE(sp) /* s3 */
    load_x x20, 17 * portWORD_SIZE(sp) /* s4 */
    load_x x21, 18 * portWORD_SIZE(sp) /* s5 */
    load_x x22, 19 * portWORD_SIZE(sp) /* s6 */
    load_x x23, 20 * portWORD_SIZE(sp) /* s7 */
    load_x x24, 21 * portWORD_SIZE(sp) /* s8 */
    load_x x25, 22 * portWORD_SIZE(sp) /* s9 */
    load_x x26, 23 * portWORD_SIZE(sp) /* s10 */
    load_x x27, 24 * portWORD_SIZE(sp) /* s11 */
    load_x x28, 25 * portWORD_SIZE(sp) /* t3 */
    load_x x29, 26 * portWORD_SIZE(sp) /* t4 */
    load_x x30, 27 * portWORD_SIZE(sp) /* t5 */
    load_x x31, 28 * portWORD_SIZE(sp) /* t6 */

    /* Set initial mstatus with interrupts enabled */
    load_x x5, 29 * portWORD_SIZE(sp)
    addi x5, x5, 0x08                /* Set MIE bit */
    csrrw x0, mstatus, x5

    load_x x5, 2 * portWORD_SIZE(sp)  /* Restore initial t0 (x5) */

    addi sp, sp, portCONTEXT_SIZE
    ret

/*-----------------------------------------------------------*/

.align 8

pxPortInitialiseStack:

    csrr t0, mstatus
    andi t0, t0, ~0x8                /* Disable interrupts temporarily */

    addi t1, x0, 0x788
    slli t1, t1, 4
    or t0, t0, t1                    /* Set MPIE, MPP, FS bits in mstatus */

    addi a0, a0, -portWORD_SIZE
    store_x t0, 0(a0)                /* Push mstatus */

    addi a0, a0, -(22 * portWORD_SIZE)
    store_x a2, 0(a0)                /* Push pvParameters (a2) into x10/a0 slot */

    addi a0, a0, -(6 * portWORD_SIZE)
    store_x x0, 0(a0)                /* Push return address placeholder (could be portTASK_RETURN_ADDRESS) */

    addi t0, x0, portasmADDITIONAL_CONTEXT_SIZE

chip_specific_stack_frame:
    beq t0, x0, 1f
    addi a0, a0, -portWORD_SIZE
    store_x x0, 0(a0)                /* Init chip-specific register */
    addi t0, t0, -1
    j chip_specific_stack_frame

1:
    addi a0, a0, -portWORD_SIZE
    store_x a1, 0(a0)                /* Push task function pointer (pxCode) */
    ret

/*-----------------------------------------------------------*/

