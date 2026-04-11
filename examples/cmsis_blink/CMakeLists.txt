cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/niiet_gcc.cmake)

project(cmsis_blink C ASM)

niiet_fetch_cmsis(K1921)

find_package(CMSIS COMPONENTS K1921VG015 REQUIRED)

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
