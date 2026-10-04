cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/niiet_gcc.cmake)

project(cmsis_blink C ASM)

niiet_fetch_cmsis(K1921)

find_package(CMSIS COMPONENTS K1921VG015 REQUIRED)

# IRIS UNO-VG015: кварц 12 МГц, SystemInit поднимает PLL0 до 50 МГц
target_compile_definitions(cmsis_k1921vg015 PRIVATE
    HSECLK_VAL=12000000
    SYSCLK_PLL
    CKO_NONE
)

add_executable(cmsis_blink src/main.c)

target_link_libraries(cmsis_blink PRIVATE
    CMSIS::K1921VG015
    NIIET::Nano
    NIIET::NoSys
)

niiet_k1921vg015_target_link_flash(cmsis_blink)

niiet_print_size_of_target(cmsis_blink)
niiet_generate_hex_file(cmsis_blink)
niiet_generate_binary_file(cmsis_blink)
