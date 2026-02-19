#include "FreeRTOS.h"
#include <stddef.h>

void* __wrap_malloc(size_t size) { return pvPortMalloc(size); }
void  __wrap_free(void* ptr)     { vPortFree(ptr); }
void* __wrap_calloc(size_t n, size_t size) {
    void* p = pvPortMalloc(n * size);
    if (p) __builtin_memset(p, 0, n * size);
    return p;
}
void* __wrap_realloc(void* ptr, size_t size) {
    void* p = pvPortMalloc(size);
    if (p && ptr) __builtin_memcpy(p, ptr, size);
    if (ptr) vPortFree(ptr);
    return p;
}
