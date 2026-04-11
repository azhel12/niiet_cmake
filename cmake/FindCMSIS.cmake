# find_package(CMSIS COMPONENTS K1921 | K1921VG015)
#
# Same idea as stm32-cmake CMSIS::
#   CMSIS::K1921       — device headers + CPU/arch flags only (no startup, no system_*.c).
#   CMSIS::K1921VG015  — full chip: CMSIS::K1921 plus startup, system/PLIC/mtimer/irq sources.
#
# Requires NIIET_RISCV_SDK_PATH (niiet_fetch_cmsis(K1921), or -D).
#
# Note: name "CMSIS" follows stm32-cmake; for RISC-V this is NIIET device headers, not ARM CMSIS.

if(NOT NIIET_RISCV_SDK_PATH)
    message(FATAL_ERROR "find_package(CMSIS): set NIIET_RISCV_SDK_PATH (e.g. niiet_fetch_cmsis(K1921)).")
endif()

if(NOT CMSIS_FIND_COMPONENTS)
    message(FATAL_ERROR "find_package(CMSIS) needs COMPONENTS, e.g. K1921 or K1921VG015")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/niiet/k1921.cmake")

foreach(_comp ${CMSIS_FIND_COMPONENTS})
    string(TOUPPER "${_comp}" _COMP)
    if(_COMP STREQUAL "K1921")
        niiet_k1921_ensure_cmsis_k1921()
        set(CMSIS_K1921_FOUND TRUE)
    elseif(_COMP STREQUAL "K1921VG015")
        niiet_k1921_ensure_cmsis_k1921vg015()
        set(CMSIS_K1921_FOUND TRUE)
        set(CMSIS_K1921VG015_FOUND TRUE)
    else()
        message(FATAL_ERROR "Unknown CMSIS component: ${_comp}")
    endif()
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS HANDLE_COMPONENTS REQUIRED_VARS NIIET_RISCV_SDK_PATH)
