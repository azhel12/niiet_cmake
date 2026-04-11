# niiet_cmake

CMake-тулчейн для микроконтроллеров **НИИЭТ** (в первую очередь **K1921VG015**) в духе [stm32-cmake](https://github.com/ObKo/stm32-cmake), [wch-cmake](https://github.com/azhel12/wch_cmake).

Проект почти полностью получен вайбкодинком, так как нужно было быстро поднять окружение для разработки под К1921ВГ015.

## Что нужно

- **CMake** ≥ 3.16  
- **Кросс-компилятор** GCC для RISC-V с префиксом вроде `riscv-none-elf-` (проверено на xPack)
- **Git**, если SDK подтягивается через `FetchContent`, подтягивается репозиторий [niiet_riscv_sdk](https://gitflic.ru/project/niiet/niiet_riscv_sdk)

## Минимальный `CMakeLists.txt`

Укажите тулчейн **до** `project()`:

```cmake
cmake_minimum_required(VERSION 3.16)
set(CMAKE_TOOLCHAIN_FILE /path/to/niiet_cmake/cmake/niiet_gcc.cmake)

project(prj_name C ASM)

# SDK с gitflic (или задать -DNIIET_RISCV_SDK_PATH=... к локальной копии)
niiet_fetch_cmsis(K1921)

# Найти CMSIS
find_package(CMSIS COMPONENTS K1921VG015 REQUIRED)

add_executable(prj_name src/main.c)

target_link_libraries(prj_name PRIVATE
    CMSIS::K1921VG015
    NIIET::Nano
    NIIET::NoSys
)

# Линковка для прошивки во флеш-память
niiet_k1921vg015_target_link_flash(prj_name)

# Печать размеров
niiet_print_size_of_target(prj_name)
# Генерация HEX
niiet_generate_hex_file(prj_name)
# Генерация BIN
niiet_generate_binary_file(prj_name)
```

## Переменные окружения (опционально)


| Переменная              | Назначение                                         |
| ----------------------- | -------------------------------------------------- |
| `NIIET_TARGET_TRIPLET`  | Префикс тулчейна, по умолчанию `riscv-none-elf`    |
| `NIIET_TOOLCHAIN_PATH`  | Корень установки GCC, если не в стандартном `PATH` |
| `NIIET_OPENOCD_SCRIPTS` | Каталог `scripts` OpenOCD из SDK                   |


## Примеры

В каталоге `**examples/**`:

- `examples/cmsis_blink` — моргание PC10 через регистры  
- `examples/plib_blink` — то же через PLIB015

Проверено на отладочной плате [Ирис UNO К1921ВГ015](https://gitflic.ru/project/mikhvad/irisuno-vg015).

Сборка:

```bash
cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

