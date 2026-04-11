/* PC10: прямой доступ к регистрам (CMSIS / device headers). */

#include <K1921VG015.h>
#include <stdint.h>
#include <system_k1921vg015.h>

#define LED_PIN_PC10 (1u << 10)

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
    RCU->CGCFGAHB_bit.GPIOCEN = 1;
    RCU->RSTDISAHB_bit.GPIOCEN = 1;
    GPIOC->OUTENSET = LED_PIN_PC10;
    GPIOC->DATAOUTCLR = LED_PIN_PC10;
}

int main(void)
{
    SystemInit();
    SystemCoreClockUpdate();
    led_init();

    while (1) {
        GPIOC->DATAOUTTGL = LED_PIN_PC10;
        delay_busy();
    }
}
