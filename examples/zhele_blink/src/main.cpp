/* Моргание на Zhele: один исходник под оба чипа.
 *   K1921VG015 (IRIS UNO-VG015): светодиод PC10
 *   K1921VG5T (NIIET-MINI): светодиод PA12, активный низкий
 */

#include <zhele/delay.h>
#include <zhele/iopins.h>

#if defined(K1921VG015)
#include <system_k1921vg015.h>
using Led = Zhele::IO::Pc10;
#else
#include <system_k1921vg5t.h>
using Led = Zhele::IO::Pa12Inv; // Set() прижимает вывод к земле и зажигает светодиод
#endif

int main()
{
    SystemInit();

    Led::Port::Enable();
    Led::SetConfiguration<Led::Port::Configuration::Out>();
    Led::SetDriverType<Led::Port::DriverType::PushPull>();

    for (;;) {
        Led::Toggle();
        Zhele::delay_ms<500>();
    }
}
