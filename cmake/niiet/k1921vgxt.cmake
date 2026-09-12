# K1921VG5T / K1921VG7T device support (the "VGxT" RISC-V SCR4 line), shared by
# FindCMSIS and FindNIIET. Unlike K1921VG015 these chips ship as *separate* SDK
# repositories, each with its own platform/Device/<DEV> tree, so the paths are
# derived from NIIET_<DEV>_SDK_PATH rather than from the umbrella SDK.
#
# CMSIS here means "device register headers + optional startup", same role as in
# stm32-cmake.

include_guard(GLOBAL)

# CPU/arch flags for one device. SCR4 core: RV32IMFC with the Zicsr/Zifencei
# extensions, single-precision FP ABI (matches the NIIET SDK project files).
function(niiet_k1921vgxt_ensure_cpuflags DEV)
    string(TOLOWER "${DEV}" _dev)
    if(NOT TARGET NIIET::${DEV}::CpuFlags)
        add_library(niiet_${_dev}_cpuflags INTERFACE)
        add_library(NIIET::${DEV}::CpuFlags ALIAS niiet_${_dev}_cpuflags)
        target_compile_options(niiet_${_dev}_cpuflags INTERFACE
            -march=rv32imfc_zicsr_zifencei
            -mabi=ilp32f
            -Wall
            -ffunction-sections
            -fdata-sections
            -fno-common
            -fno-builtin
        )
        target_compile_definitions(niiet_${_dev}_cpuflags INTERFACE ${DEV})
        target_link_options(niiet_${_dev}_cpuflags INTERFACE
            -march=rv32imfc_zicsr_zifencei
            -mabi=ilp32f
            -Wl,--gc-sections
        )
    endif()
endfunction()

# Full device package: headers + startup, system, PLIC, mtimer, platform init.
function(niiet_k1921vgxt_ensure_cmsis DEV)
    string(TOLOWER "${DEV}" _dev)
    if(NOT NIIET_${DEV}_SDK_PATH)
        message(FATAL_ERROR "niiet/k1921vgxt.cmake: NIIET_${DEV}_SDK_PATH is not set (call niiet_fetch_cmsis(${DEV}) or pass -DNIIET_${DEV}_SDK_PATH=).")
    endif()

    set(_devdir "${NIIET_${DEV}_SDK_PATH}/platform/Device/${DEV}")
    niiet_k1921vgxt_ensure_cpuflags(${DEV})

    if(NOT TARGET CMSIS::${DEV}::Headers)
        add_library(cmsis_${_dev}_headers INTERFACE)
        add_library(CMSIS::${DEV}::Headers ALIAS cmsis_${_dev}_headers)
        target_include_directories(cmsis_${_dev}_headers INTERFACE "${_devdir}/include")
        target_link_libraries(cmsis_${_dev}_headers INTERFACE NIIET::${DEV}::CpuFlags)
    endif()

    if(NOT TARGET CMSIS::${DEV})
        set(_src
            ${_devdir}/source/system_${_dev}.c
            ${_devdir}/source/startup_${_dev}.S
            ${_devdir}/source/plic.c
            ${_devdir}/source/mtimer.c
        )
        # K1921VG5T ships the RISC-V trap dispatcher as a separate file.
        if(EXISTS "${_devdir}/source/riscv-irq.c")
            list(APPEND _src ${_devdir}/source/riscv-irq.c)
        endif()
        # The K1921VG7T copy of sys_init.c under platform/ includes plf_l1cache.h,
        # a header the public SDK does not ship; the copy in templates/ is the same
        # file with the L1/MPU init commented out and compiles as released.
        set(_sys_init "${_devdir}/source/sys_init.c")
        set(_sys_init_template "${NIIET_${DEV}_SDK_PATH}/templates/${_dev}-bare/platform/Device/${DEV}/source/sys_init.c")
        file(READ "${_sys_init}" _sys_init_text)
        if(_sys_init_text MATCHES "plf_l1cache.h" AND EXISTS "${_sys_init_template}")
            set(_sys_init "${_sys_init_template}")
        endif()
        list(APPEND _src ${_sys_init})

        add_library(cmsis_${_dev} STATIC ${_src})
        add_library(CMSIS::${DEV} ALIAS cmsis_${_dev})
        target_link_libraries(cmsis_${_dev} PUBLIC CMSIS::${DEV}::Headers)
        set_target_properties(cmsis_${_dev} PROPERTIES C_STANDARD 99)
        target_compile_options(cmsis_${_dev} PRIVATE $<$<COMPILE_LANGUAGE:C>:-Wno-int-conversion>)
    endif()

    if(NOT TARGET NIIET::${DEV}::Device)
        add_library(NIIET::${DEV}::Device ALIAS cmsis_${_dev})
    endif()
endfunction()

# Link a target against the device's flash linker script.
function(niiet_k1921vgxt_target_link_flash DEV TARGET)
    string(TOLOWER "${DEV}" _dev)
    if(NOT NIIET_${DEV}_FLASH_LD)
        set(NIIET_${DEV}_FLASH_LD
            "${NIIET_${DEV}_SDK_PATH}/platform/Device/${DEV}/ldscripts/${_dev}_flash.ld"
            CACHE FILEPATH "${DEV} flash linker script")
    endif()
    target_link_options(${TARGET} PRIVATE -nostartfiles)
    niiet_add_linker_script(${TARGET} PRIVATE "${NIIET_${DEV}_FLASH_LD}")
endfunction()

function(niiet_k1921vg5t_target_link_flash TARGET)
    niiet_k1921vgxt_target_link_flash(K1921VG5T ${TARGET})
endfunction()

function(niiet_k1921vg7t_target_link_flash TARGET)
    niiet_k1921vgxt_target_link_flash(K1921VG7T ${TARGET})
endfunction()
