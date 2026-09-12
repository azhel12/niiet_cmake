# find_package(CMSIS COMPONENTS K1921 | K1921VG015 | K1921VG5T | K1921VG7T)
#
# Same idea as stm32-cmake CMSIS::
#   CMSIS::K1921       — device headers + CPU/arch flags only (no startup, no system_*.c).
#   CMSIS::K1921VG015  — full chip: CMSIS::K1921 plus startup, system/PLIC/mtimer/irq sources.
#   CMSIS::K1921VG5T   — full chip (headers target: CMSIS::K1921VG5T::Headers).
#   CMSIS::K1921VG7T   — full chip (headers target: CMSIS::K1921VG7T::Headers).
#
# K1921VG015 comes from the umbrella SDK (NIIET_RISCV_SDK_PATH, niiet_fetch_cmsis(K1921));
# the SCR4 chips have their own SDK repositories and use NIIET_<DEV>_SDK_PATH
# (niiet_fetch_cmsis(K1921VG5T) / niiet_fetch_cmsis(K1921VG7T)).
#
# Note: name "CMSIS" follows stm32-cmake; for RISC-V this is NIIET device headers, not ARM CMSIS.

if(NOT CMSIS_FIND_COMPONENTS)
    message(FATAL_ERROR "find_package(CMSIS) needs COMPONENTS, e.g. K1921 or K1921VG015")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/niiet/k1921vgxt.cmake")

# The umbrella-SDK module hard-fails when NIIET_RISCV_SDK_PATH is unset, so only
# pull it in for the components that actually come from that SDK.
foreach(_comp ${CMSIS_FIND_COMPONENTS})
    string(TOUPPER "${_comp}" _COMP)
    if(_COMP MATCHES "^K1921(VG015)?$")
        if(NOT NIIET_RISCV_SDK_PATH)
            message(FATAL_ERROR "find_package(CMSIS COMPONENTS ${_comp}): set NIIET_RISCV_SDK_PATH (e.g. niiet_fetch_cmsis(K1921)).")
        endif()
        include("${CMAKE_CURRENT_LIST_DIR}/niiet/k1921.cmake")
    endif()
endforeach()

foreach(_comp ${CMSIS_FIND_COMPONENTS})
    string(TOUPPER "${_comp}" _COMP)
    if(_COMP STREQUAL "K1921")
        niiet_k1921_ensure_cmsis_k1921()
        set(CMSIS_K1921_FOUND TRUE)
    elseif(_COMP STREQUAL "K1921VG015")
        niiet_k1921_ensure_cmsis_k1921vg015()
        set(CMSIS_K1921_FOUND TRUE)
        set(CMSIS_K1921VG015_FOUND TRUE)
    elseif(_COMP STREQUAL "K1921VG5T" OR _COMP STREQUAL "K1921VG7T")
        niiet_k1921vgxt_ensure_cmsis(${_COMP})
        set(CMSIS_${_COMP}_FOUND TRUE)
    else()
        message(FATAL_ERROR "Unknown CMSIS component: ${_comp}")
    endif()
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CMSIS HANDLE_COMPONENTS)
