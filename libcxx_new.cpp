#include "FreeRTOS.h"
#include <stddef.h>

void* operator new(size_t size)                     { return pvPortMalloc(size); }
void* operator new[](size_t size)                   { return pvPortMalloc(size); }
void  operator delete(void* ptr) noexcept           { vPortFree(ptr); }
void  operator delete[](void* ptr) noexcept         { vPortFree(ptr); }
void  operator delete(void* ptr, size_t) noexcept   { vPortFree(ptr); }
void  operator delete[](void* ptr, size_t) noexcept { vPortFree(ptr); }
