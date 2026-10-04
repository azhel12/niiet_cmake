/* PA12 (светодиод NIIET-MINI-K1921VG5T, активный низкий): прямой доступ к регистрам. */

#include <K1921VG5T.h>
#include <stdint.h>
#include <system_k1921vg5t.h>

#define LED_PIN_PA12 (1u << 12)

static void delay_busy(void)
{
    volatile uint32_t i;
    volatile uint32_t j;

    for (i = 0; i < 400u; i++) {
        for (j = 0; j < 8000u; j++) {
            __asm volatile("nop");
        }
    }
}

static void led_init(void)
{
    RCU->CGCFGAHB_bit.GPIOAEN = 1;
    RCU->RSTDISAHB_bit.GPIOAEN = 1;
    GPIOA->DATAOUTSET = LED_PIN_PA12; /* погашен */
    GPIOA->OUTENSET = LED_PIN_PA12;
}

int main(void)
{
    SystemInit();
    SystemCoreClockUpdate();
    led_init();

    while (1) {
        GPIOA->DATAOUTTGL = LED_PIN_PA12;
        delay_busy();
    }
}
