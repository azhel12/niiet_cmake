# find_package(PLIB COMPONENTS K1921VG015)
#
# Peripheral library (PLIB015) for K1921VG015 — same target as NIIET::… PLIB015:
#   PLIB::NIIET::K1921VG015
#
# Requires NIIET_RISCV_SDK_PATH (niiet_fetch_plib(K1921), or -D).

if(NOT NIIET_RISCV_SDK_PATH)
    message(FATAL_ERROR "find_package(PLIB): set NIIET_RISCV_SDK_PATH (e.g. niiet_fetch_plib(K1921)).")
endif()

if(NOT PLIB_FIND_COMPONENTS)
    message(FATAL_ERROR "find_package(PLIB) needs COMPONENTS, e.g. K1921VG015")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/niiet/k1921.cmake")

foreach(_comp ${PLIB_FIND_COMPONENTS})
    string(TOUPPER "${_comp}" _COMP)
    if(_COMP STREQUAL "K1921VG015")
        niiet_k1921_ensure_plib_k1921vg015("${CMAKE_CURRENT_LIST_DIR}")
        set(PLIB_K1921VG015_FOUND TRUE)
    else()
        message(FATAL_ERROR "Unknown PLIB component: ${_comp}")
    endif()
endforeach()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PLIB HANDLE_COMPONENTS REQUIRED_VARS NIIET_RISCV_SDK_PATH)
