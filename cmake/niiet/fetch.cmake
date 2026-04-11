include(FetchContent)

# Umbrella SDK (K1921VG015 platform, plib015, middleware, templates, tools/OpenOCD, SVD).
# See: https://gitflic.ru/project/niiet/niiet_riscv_sdk
FetchContent_Declare(
    niiet_riscv_sdk
    GIT_REPOSITORY https://gitflic.ru/project/niiet/niiet_riscv_sdk.git
    GIT_TAG        master
    GIT_SHALLOW    TRUE
)

function(_niiet_fetch_riscv_sdk_once)
    if(NIIET_RISCV_SDK_PATH)
        return()
    endif()
    FetchContent_MakeAvailable(niiet_riscv_sdk)
    set(NIIET_RISCV_SDK_PATH "${niiet_riscv_sdk_SOURCE_DIR}" CACHE PATH
        "Root of NIIET RISC-V SDK (from FetchContent or override with -DNIIET_RISCV_SDK_PATH=)" FORCE)
endfunction()

# Fetch SDK content needed for CMSIS-style device packages (headers, startup, …).
function(niiet_fetch_cmsis FAMILY)
    string(TOUPPER "${FAMILY}" _F)
    if(_F STREQUAL "K1921")
        _niiet_fetch_riscv_sdk_once()
    else()
        message(FATAL_ERROR "niiet_fetch_cmsis: unknown family '${FAMILY}' (supported: K1921)")
    endif()
endfunction()

# Fetch SDK content needed for K1921 peripheral library (plib015). Same umbrella repo as CMSIS for now.
function(niiet_fetch_plib FAMILY)
    string(TOUPPER "${FAMILY}" _F)
    if(_F STREQUAL "K1921")
        _niiet_fetch_riscv_sdk_once()
    else()
        message(FATAL_ERROR "niiet_fetch_plib: unknown family '${FAMILY}' (supported: K1921)")
    endif()
endfunction()

function(niiet_fetch_riscv_sdk)
    _niiet_fetch_riscv_sdk_once()
endfunction()
