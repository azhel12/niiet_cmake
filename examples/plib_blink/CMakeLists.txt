cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/niiet_gcc.cmake)

project(plib_blink C ASM)

niiet_fetch_plib(K1921)

find_package(CMSIS COMPONENTS K1921VG015 REQUIRED)
find_package(PLIB COMPONENTS K1921VG015 REQUIRED)

add_executable(plib_blink src/main.c)

target_link_libraries(plib_blink PRIVATE
    CMSIS::K1921VG015
    PLIB::NIIET::K1921VG015
    NIIET::Nano
    NIIET::NoSys
)

niiet_k1921vg015_target_link_flash(plib_blink)

niiet_print_size_of_target(plib_blink)
niiet_generate_hex_file(plib_blink)
niiet_generate_binary_file(plib_blink)
