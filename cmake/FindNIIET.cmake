# find_package(NIIET COMPONENTS K1921VG015_DEVICE K1921VG015_RETARGET ...)
# Requires NIIET_RISCV_SDK_PATH (niiet_fetch_cmsis/plib, niiet_fetch_riscv_sdk, or -D).

if(NOT NIIET_RISCV_SDK_PATH)
    message(FATAL_ERROR "NIIET_RISCV_SDK_PATH is not set. Call niiet_fetch_cmsis(K1921) / niiet_fetch_plib(K1921) or set the path manually.")
endif()

if(NOT NIIET_FIND_COMPONENTS)
    message(FATAL_ERROR "find_package(NIIET) needs COMPONENTS, e.g. K1921VG015_DEVICE K1921VG015_RETARGET")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/niiet/k1921.cmake")
niiet_k1921_ensure_cpuflags()

set(_NIIET_SDK "${NIIET_RISCV_SDK_PATH}")
set(_NIIET_K1921_DEV "${_NIIET_SDK}/platform/Device/K1921VG015")
set(_NIIET_K1921_PLIB "${_NIIET_SDK}/platform/plib015")

foreach(_comp ${NIIET_FIND_COMPONENTS})
    string(TOUPPER "${_comp}" _COMP)

    if(_COMP STREQUAL "K1921VG015_DEVICE")
        niiet_k1921_ensure_cmsis_k1921vg015()
        set(NIIET_K1921VG015_DEVICE_FOUND TRUE)

    elseif(_COMP STREQUAL "K1921VG015_RETARGET")
        if(NOT TARGET NIIET::K1921VG015::Retarget)
            set(_ret_src
                ${_NIIET_SDK}/platform/retarget/printf.c
                ${_NIIET_SDK}/platform/retarget/Template/K1921VG015/retarget.c
            )
            add_library(niiet_k1921vg015_retarget STATIC ${_ret_src})
            add_library(NIIET::K1921VG015::Retarget ALIAS niiet_k1921vg015_retarget)
            target_include_directories(niiet_k1921vg015_retarget PUBLIC
                ${_NIIET_SDK}/platform/retarget/Template/K1921VG015
                ${_NIIET_K1921_DEV}/include
            )
            target_link_libraries(niiet_k1921vg015_retarget PUBLIC NIIET::K1921VG015::CpuFlags)
            set_target_properties(niiet_k1921vg015_retarget PROPERTIES C_STANDARD 99)
        endif()
        set(NIIET_K1921VG015_RETARGET_FOUND TRUE)

    elseif(_COMP STREQUAL "K1921VG015_PLIB015")
        niiet_k1921_ensure_plib_k1921vg015("${CMAKE_CURRENT_LIST_DIR}")
        set(NIIET_K1921VG015_PLIB015_FOUND TRUE)

    elseif(_COMP STREQUAL "BSP_NIIET_DEV_K1921VG015")
        if(NOT TARGET NIIET::BSP::NIIET_DEV_K1921VG015)
            add_library(niiet_bsp_niiet_dev_k1921vg015 STATIC
                ${_NIIET_SDK}/hardware/bsp/NIIET-DEV-K1921VG015/bsp.c
            )
            add_library(NIIET::BSP::NIIET_DEV_K1921VG015 ALIAS niiet_bsp_niiet_dev_k1921vg015)
            target_include_directories(niiet_bsp_niiet_dev_k1921vg015 PUBLIC
                ${_NIIET_SDK}/hardware/bsp/NIIET-DEV-K1921VG015
                ${_NIIET_K1921_DEV}/include
            )
            target_link_libraries(niiet_bsp_niiet_dev_k1921vg015 PUBLIC NIIET::K1921VG015::CpuFlags)
        endif()
        set(NIIET_BSP_NIIET_DEV_K1921VG015_FOUND TRUE)

    elseif(_COMP STREQUAL "BSP_NIIET_MINI_K1921VG015")
        if(NOT TARGET NIIET::BSP::NIIET_MINI_K1921VG015)
            add_library(niiet_bsp_niiet_mini_k1921vg015 STATIC
                ${_NIIET_SDK}/hardware/bsp/NIIET-MINI-K1921VG015/bsp.c
            )
            add_library(NIIET::BSP::NIIET_MINI_K1921VG015 ALIAS niiet_bsp_niiet_mini_k1921vg015)
            target_include_directories(niiet_bsp_niiet_mini_k1921vg015 PUBLIC
                ${_NIIET_SDK}/hardware/bsp/NIIET-MINI-K1921VG015
                ${_NIIET_K1921_DEV}/include
            )
            target_link_libraries(niiet_bsp_niiet_mini_k1921vg015 PUBLIC NIIET::K1921VG015::CpuFlags)
        endif()
        set(NIIET_BSP_NIIET_MINI_K1921VG015_FOUND TRUE)

    else()
        message(FATAL_ERROR "Unknown NIIET component: ${_comp}")
    endif()
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NIIET DEFAULT_MSG NIIET_RISCV_SDK_PATH)
