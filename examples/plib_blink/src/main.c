/* PC10: PLIB015 GPIO (аналог SPL). */

#include <stdint.h>
#include <system_k1921vg015.h>

#include <plib015_gpio.h>
#include <plib015_rcu.h>

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

int main(void)
{
    SystemInit();
    SystemCoreClockUpdate();

    RCU_AHBClkCmd(RCU_AHBClk_GPIOC, ENABLE);
    RCU_AHBRstCmd(RCU_AHBRst_GPIOC, ENABLE);

    GPIO_Init_TypeDef gpio = { 0 };
    GPIO_StructInit(&gpio);
    gpio.Pin = GPIO_Pin_10;
    gpio.Out = ENABLE;
    GPIO_Init(GPIOC, &gpio);
    GPIO_ClearBits(GPIOC, GPIO_Pin_10);

    while (1) {
        GPIO_ToggleBits(GPIOC, GPIO_Pin_10);
        delay_busy();
    }
}
