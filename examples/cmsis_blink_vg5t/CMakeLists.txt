cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/niiet_gcc.cmake)

project(cmsis_blink_vg5t C ASM)

niiet_fetch_cmsis(K1921VG5T)

find_package(CMSIS COMPONENTS K1921VG5T REQUIRED)

# NIIET-MINI-K1921VG5T: кварц 16 МГц, SystemInit поднимает PLL до 100 МГц
target_compile_definitions(cmsis_k1921vg5t PRIVATE
    HSECLK_VAL=16000000
    SYSCLK_PLL
    CKO_NONE
)

add_executable(cmsis_blink_vg5t src/main.c)

target_link_libraries(cmsis_blink_vg5t PRIVATE
    CMSIS::K1921VG5T
    NIIET::Nano
    NIIET::NoSys
)

niiet_k1921vg5t_target_link_flash(cmsis_blink_vg5t)

niiet_print_size_of_target(cmsis_blink_vg5t)
niiet_generate_hex_file(cmsis_blink_vg5t)
niiet_generate_binary_file(cmsis_blink_vg5t)
