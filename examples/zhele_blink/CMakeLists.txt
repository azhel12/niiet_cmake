cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/niiet_gcc.cmake)

project(zhele_blink CXX C ASM)

# Zhele с GitHub (или задать -DZHELE_PATH=... к локальной копии)
include(FetchContent)
if(ZHELE_PATH)
    set(FETCHCONTENT_SOURCE_DIR_ZHELE ${ZHELE_PATH})
endif()
FetchContent_Declare(
    zhele
    GIT_REPOSITORY https://github.com/azhel12/Zhele.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
)
FetchContent_MakeAvailable(zhele)

niiet_fetch_cmsis(K1921)
niiet_fetch_cmsis(K1921VG5T)
find_package(CMSIS COMPONENTS K1921VG015 K1921VG5T REQUIRED)

# Один и тот же src/main.cpp собирается под оба чипа.

# K1921VG015 на IRIS UNO-VG015: кварц 12 МГц, ядро 50 МГц (PLL0)
target_compile_definitions(cmsis_k1921vg015 PRIVATE
    HSECLK_VAL=12000000
    SYSCLK_PLL
    CKO_NONE
)
add_executable(zhele_blink_vg015 src/main.cpp)
target_compile_definitions(zhele_blink_vg015 PRIVATE HSE_VALUE=12000000 F_CPU=50000000)
target_compile_options(zhele_blink_vg015 PRIVATE -fno-exceptions -fno-rtti)
target_link_libraries(zhele_blink_vg015 PRIVATE
    zhele::zhele
    CMSIS::K1921VG015
    NIIET::Nano
    NIIET::NoSys
)
niiet_k1921vg015_target_link_flash(zhele_blink_vg015)
niiet_print_size_of_target(zhele_blink_vg015)
niiet_generate_hex_file(zhele_blink_vg015)
niiet_generate_binary_file(zhele_blink_vg015)

# K1921VG5T на NIIET-MINI-K1921VG5T: кварц 16 МГц, ядро 100 МГц (PLL)
target_compile_definitions(cmsis_k1921vg5t PRIVATE
    HSECLK_VAL=16000000
    SYSCLK_PLL
    CKO_NONE
)
add_executable(zhele_blink_vg5t src/main.cpp)
target_compile_definitions(zhele_blink_vg5t PRIVATE HSE_VALUE=16000000 F_CPU=100000000)
target_compile_options(zhele_blink_vg5t PRIVATE -fno-exceptions -fno-rtti)
target_link_libraries(zhele_blink_vg5t PRIVATE
    zhele::zhele
    CMSIS::K1921VG5T
    NIIET::Nano
    NIIET::NoSys
)
niiet_k1921vg5t_target_link_flash(zhele_blink_vg5t)
niiet_print_size_of_target(zhele_blink_vg5t)
niiet_generate_hex_file(zhele_blink_vg5t)
niiet_generate_binary_file(zhele_blink_vg5t)
