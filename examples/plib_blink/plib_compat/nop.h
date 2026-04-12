/* Injected before each PLIB .c (see CMakeLists -include): SDK uses __NOP(), not defined for GCC RISC-V. */
#ifndef PLIB_BLINK_COMPAT_NOP_H
#define PLIB_BLINK_COMPAT_NOP_H

#define __NOP() __asm__ volatile("nop")

#endif /* PLIB_BLINK_COMPAT_NOP_H */
