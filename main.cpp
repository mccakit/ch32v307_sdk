#include "ch32v30x.h"
#include "FreeRTOS.h"
#include "task.h"
#include <memory>
#include <stdlib.h>
#include <array>

static void LED_Init() {
    RCC->APB2PCENR |= RCC_APB2Periph_GPIOB;
    GPIOB->CFGLR &= ~(0xF << (4 * 4));
    GPIOB->CFGLR |=  (0x3 << (4 * 4));
}

static void vBlinkTask(void*) {
    // C++ heap: unique_ptr
    auto led_state = std::make_unique<bool>(false);

    // C heap: malloc/free
    int* counter = (int*)malloc(sizeof(int));
    *counter = 0;

    // C++ heap: array of unique_ptrs
    auto delays = std::make_unique<std::array<uint32_t, 4>>(
        std::array<uint32_t, 4>{100, 200, 400, 500}
    );

    LED_Init();

    while (true) {
        *led_state = !*led_state;
        (*counter)++;

        // pick delay based on counter, cycling through delays array
        uint32_t delay_ms = (*delays)[(*counter) % delays->size()];

        GPIOB->BSHR = *led_state ? (1 << 4) : (1 << 20);
        vTaskDelay(pdMS_TO_TICKS(delay_ms));
    }

    // never reached but good practice
    free(counter);
}

extern "C" {
int main() {
    SystemCoreClockUpdate();
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
    xTaskCreate(vBlinkTask, "Blink", 1024, nullptr, 1, nullptr);
    vTaskStartScheduler();
    while (true);
}
void vApplicationStackOverflowHook(TaskHandle_t, char*) { while(true); }
void vApplicationMallocFailedHook() { while(true); }
}
