# Common settings and helpers (stm32-cmake style, NIIET RISC-V).

if(NOT NIIET_TOOLCHAIN_PATH)
    if(DEFINED ENV{NIIET_TOOLCHAIN_PATH})
        message(STATUS "NIIET_TOOLCHAIN_PATH from environment: $ENV{NIIET_TOOLCHAIN_PATH}")
        set(NIIET_TOOLCHAIN_PATH $ENV{NIIET_TOOLCHAIN_PATH})
    else()
        if(NOT CMAKE_C_COMPILER)
            set(NIIET_TOOLCHAIN_PATH "/usr")
            message(STATUS "No NIIET_TOOLCHAIN_PATH specified, using default: ${NIIET_TOOLCHAIN_PATH}")
        else()
            get_filename_component(NIIET_TOOLCHAIN_PATH ${CMAKE_C_COMPILER} DIRECTORY)
            get_filename_component(NIIET_TOOLCHAIN_PATH ${NIIET_TOOLCHAIN_PATH} DIRECTORY)
        endif()
    endif()
    file(TO_CMAKE_PATH "${NIIET_TOOLCHAIN_PATH}" NIIET_TOOLCHAIN_PATH)
endif()

if(NOT NIIET_TARGET_TRIPLET)
    if(DEFINED ENV{NIIET_TARGET_TRIPLET})
        message(STATUS "NIIET_TARGET_TRIPLET from environment: $ENV{NIIET_TARGET_TRIPLET}")
        set(NIIET_TARGET_TRIPLET $ENV{NIIET_TARGET_TRIPLET})
    else()
        set(NIIET_TARGET_TRIPLET "riscv-none-elf")
        message(STATUS "No NIIET_TARGET_TRIPLET specified, using default: ${NIIET_TARGET_TRIPLET}")
    endif()
endif()
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)

set(TOOLCHAIN_SYSROOT "${NIIET_TOOLCHAIN_PATH}/${NIIET_TARGET_TRIPLET}")
if(EXISTS "${NIIET_TOOLCHAIN_PATH}/bin")
    set(TOOLCHAIN_BIN_PATH "${NIIET_TOOLCHAIN_PATH}/bin")
else()
    set(TOOLCHAIN_BIN_PATH "")
endif()
set(TOOLCHAIN_INC_PATH "${NIIET_TOOLCHAIN_PATH}/${NIIET_TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_PATH "${NIIET_TOOLCHAIN_PATH}/${NIIET_TARGET_TRIPLET}/lib")

# Only if the tree exists (e.g. NIIET_TOOLCHAIN_PATH points at the unpacked toolchain root).
# If tools live only on PATH under /usr/local, a bogus /usr/riscv-none-elf would break libc/newlib.
if(IS_DIRECTORY "${TOOLCHAIN_SYSROOT}")
    set(CMAKE_SYSROOT "${TOOLCHAIN_SYSROOT}")
endif()

find_program(CMAKE_OBJCOPY NAMES ${NIIET_TARGET_TRIPLET}-objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${NIIET_TARGET_TRIPLET}-objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${NIIET_TARGET_TRIPLET}-size HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_DEBUGGER NAMES ${NIIET_TARGET_TRIPLET}-gdb HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CPPFILT NAMES ${NIIET_TARGET_TRIPLET}-c++filt HINTS ${TOOLCHAIN_BIN_PATH})

function(niiet_print_size_of_target TARGET)
    add_custom_target(${TARGET}_always_display_size
        ALL COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
        COMMENT "Target Sizes: "
        DEPENDS ${TARGET}
    )
endfunction()

function(_niiet_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
    get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
    if(TARGET_OUTPUT_NAME)
        set(OUTPUT_FILE_NAME "${TARGET_OUTPUT_NAME}.${OUTPUT_EXTENSION}")
    else()
        set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")
    endif()

    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if(RUNTIME_OUTPUT_DIRECTORY)
        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
    else()
        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
    endif()

    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_PATH}
        BYPRODUCTS ${OUTPUT_FILE_PATH}
        COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
    )
endfunction()

function(niiet_generate_binary_file TARGET)
    _niiet_generate_file(${TARGET} "bin" "binary")
endfunction()

function(niiet_generate_srec_file TARGET)
    _niiet_generate_file(${TARGET} "srec" "srec")
endfunction()

function(niiet_generate_hex_file TARGET)
    _niiet_generate_file(${TARGET} "hex" "ihex")
endfunction()

function(niiet_add_linker_script TARGET VISIBILITY SCRIPT)
    get_filename_component(SCRIPT "${SCRIPT}" ABSOLUTE)
    get_filename_component(_NIIET_LD_SCRIPT_DIR "${SCRIPT}" DIRECTORY)
    # So INCLUDE "foo.lds" from the same folder resolves (GNU ld searches -L for script includes).
    target_link_options(${TARGET} ${VISIBILITY} "-L${_NIIET_LD_SCRIPT_DIR}")
    target_link_options(${TARGET} ${VISIBILITY} -T "${SCRIPT}")

    get_target_property(TARGET_TYPE ${TARGET} TYPE)
    if(TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        set(INTERFACE_PREFIX "INTERFACE_")
    endif()

    get_target_property(LINK_DEPENDS ${TARGET} ${INTERFACE_PREFIX}LINK_DEPENDS)
    if(LINK_DEPENDS)
        list(APPEND LINK_DEPENDS "${SCRIPT}")
    else()
        set(LINK_DEPENDS "${SCRIPT}")
    endif()

    set_target_properties(${TARGET} PROPERTIES ${INTERFACE_PREFIX}LINK_DEPENDS "${LINK_DEPENDS}")
endfunction()

if(NOT (TARGET NIIET::NoSys))
    add_library(NIIET::NoSys INTERFACE IMPORTED)
    target_compile_options(NIIET::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
    target_link_options(NIIET::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
endif()

if(NOT (TARGET NIIET::Nano))
    add_library(NIIET::Nano INTERFACE IMPORTED)
    target_compile_options(NIIET::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
    target_link_options(NIIET::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
endif()
