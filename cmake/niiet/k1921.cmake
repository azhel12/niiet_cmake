# K1921 (K1921VG015) device support shared by FindCMSIS and FindNIIET.
# CMSIS here means "device register headers + optional startup", same role as stm32-cmake CMSIS.

include_guard(GLOBAL)

if(NOT NIIET_RISCV_SDK_PATH)
    message(FATAL_ERROR "niiet/k1921.cmake: NIIET_RISCV_SDK_PATH is not set.")
endif()

set(_NIIET_SDK "${NIIET_RISCV_SDK_PATH}")
set(_NIIET_K1921_DEV "${_NIIET_SDK}/platform/Device/K1921VG015")
set(_NIIET_K1921_PLIB "${_NIIET_SDK}/platform/plib015")

function(niiet_k1921_ensure_cpuflags)
    if(NOT TARGET NIIET::K1921VG015::CpuFlags)
        add_library(niiet_k1921vg015_cpuflags INTERFACE)
        add_library(NIIET::K1921VG015::CpuFlags ALIAS niiet_k1921vg015_cpuflags)
        target_compile_options(niiet_k1921vg015_cpuflags INTERFACE
            -march=rv32imfc_zicsr
            -mabi=ilp32f
            -Wall
            -ffunction-sections
            -fdata-sections
            -fno-common
            -fno-builtin
        )
        target_compile_definitions(niiet_k1921vg015_cpuflags INTERFACE
            K1921VG015
        )
        target_link_options(niiet_k1921vg015_cpuflags INTERFACE
            -march=rv32imfc_zicsr
            -mabi=ilp32f
            -Wl,--gc-sections
        )
    endif()
endfunction()

# Headers (+ arch flags). No startup / system / irq sources — own bootloader or tests.
function(niiet_k1921_ensure_cmsis_k1921)
    niiet_k1921_ensure_cpuflags()
    if(NOT TARGET CMSIS::K1921)
        add_library(cmsis_k1921 INTERFACE)
        add_library(CMSIS::K1921 ALIAS cmsis_k1921)
        target_include_directories(cmsis_k1921 INTERFACE "${_NIIET_K1921_DEV}/include")
        target_link_libraries(cmsis_k1921 INTERFACE NIIET::K1921VG015::CpuFlags)
    endif()
endfunction()

# Full device: CMSIS::K1921 + startup, system, PLIC, mtimer, …
function(niiet_k1921_ensure_cmsis_k1921vg015)
    niiet_k1921_ensure_cmsis_k1921()
    if(NOT TARGET CMSIS::K1921VG015)
        set(_dev_src
            ${_NIIET_K1921_DEV}/source/system_k1921vg015.c
            ${_NIIET_K1921_DEV}/source/sys_init.c
            ${_NIIET_K1921_DEV}/source/startup_k1921vg015.S
            ${_NIIET_K1921_DEV}/source/riscv-irq.c
            ${_NIIET_K1921_DEV}/source/plic.c
            ${_NIIET_K1921_DEV}/source/mtimer.c
        )
        add_library(cmsis_k1921vg015 STATIC ${_dev_src})
        add_library(CMSIS::K1921VG015 ALIAS cmsis_k1921vg015)
        target_link_libraries(cmsis_k1921vg015 PUBLIC CMSIS::K1921)
        set_target_properties(cmsis_k1921vg015 PROPERTIES C_STANDARD 99)
        target_compile_options(cmsis_k1921vg015 PRIVATE $<$<COMPILE_LANGUAGE:C>:-Wno-int-conversion>)
    endif()
    # ALIAS of an ALIAS is invalid; point at the real static library target.
    if(NOT TARGET NIIET::K1921VG015::Device)
        add_library(NIIET::K1921VG015::Device ALIAS cmsis_k1921vg015)
    endif()
endfunction()

# PLIB015 for K1921VG015 → PLIB::NIIET::K1921VG015 (shared by FindPLIB / FindNIIET).
function(niiet_k1921_ensure_plib_k1921vg015 _NIIET_MODULE_DIR)
    niiet_k1921_ensure_cpuflags()
    if(NOT TARGET niiet_k1921vg015_plib015)
        file(GLOB _plib_src ${_NIIET_K1921_PLIB}/src/*.c)
        add_library(niiet_k1921vg015_plib015 STATIC ${_plib_src})
        add_library(PLIB::NIIET::K1921VG015 ALIAS niiet_k1921vg015_plib015)
        add_library(NIIET::K1921VG015::PLIB015 ALIAS niiet_k1921vg015_plib015)
        target_include_directories(niiet_k1921vg015_plib015 PUBLIC
            ${_NIIET_K1921_PLIB}/inc
            ${_NIIET_K1921_DEV}/include
        )
        target_link_libraries(niiet_k1921vg015_plib015 PUBLIC NIIET::K1921VG015::CpuFlags)
        set_target_properties(niiet_k1921vg015_plib015 PROPERTIES C_STANDARD 99)
    endif()
endfunction()

if(NOT NIIET_K1921VG015_FLASH_LD)
    set(NIIET_K1921VG015_FLASH_LD "${_NIIET_K1921_DEV}/ldscripts/k1921vg015_flash.ld" CACHE FILEPATH "K1921VG015 flash linker script")
endif()

function(niiet_k1921vg015_target_link_flash TARGET)
    target_link_options(${TARGET} PRIVATE -nostartfiles)
    niiet_add_linker_script(${TARGET} PRIVATE "${NIIET_K1921VG015_FLASH_LD}")
endfunction()
