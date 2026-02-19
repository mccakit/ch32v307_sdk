#include <stddef.h>

/* Required by llvm-libc even when malloc is wrapped */
__attribute__((visibility("hidden")))
unsigned char __llvm_libc_heap_limit[0]
    __attribute__((section(".heap_end"), used));

/* IO stubs */
void* __llvm_libc_stdin_cookie = 0;
void* __llvm_libc_stdout_cookie = 0;
void* __llvm_libc_stderr_cookie = 0;
int __llvm_libc_errno = 0;

__attribute__((visibility("hidden")))
long __llvm_libc_stdio_write(void* cookie, const void* buf, size_t size) {
    (void)cookie; (void)buf;
    return (long)size;
}

__attribute__((visibility("hidden")))
long __llvm_libc_stdio_read(void* cookie, void* buf, size_t size) {
    (void)cookie; (void)buf; (void)size;
    return 0;
}
