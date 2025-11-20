# 🏗️ Deployment & Installer Creation (Windows)

[[_TOC_]]

This section explains how to configure, build, install, and package the application using **CMake**, **Ninja**, and **CPack** on Windows.

Make sure you have **NSIS** installed and added to your system **PATH**.
You can download it here: [https://nsis.sourceforge.io/Download](https://nsis.sourceforge.io/Download)

NSIS is the program used to generate Windows installers.

## 0. Prepare the environment

1. Press the Windows key and search for **x64 Native Tools for VS 2022** to open the developer command prompt.

2. Run `C:\Qt\6.8.3\msvc2022_64\bin\qtenv2.bat` to set the environment variables needed to use Qt tools from the command line.

> You can safely ignore the warning `Remember to call vcvarsall.bat to complete environment setup!` if it appears.

3. Cd to the project's repository.

## 1. Configure the project

Run CMake to configure the build directory and set up Qt paths:

```bash
cmake -S . -B build -G "Ninja Multi-Config" ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DCMAKE_TOOLCHAIN_FILE="C:\Qt\6.8.3\msvc2022_64\lib\cmake\Qt6\qt.toolchain.cmake" ^
  -DCMAKE_PREFIX_PATH="C:\Qt\6.8.3\msvc2022_64;C:\Qt\6.8.3\msvc2022_64\maplibre-native-qt\install" ^
  -DCMAKE_INSTALL_PREFIX=".\install"
```

> If you installed MapLibre in a different location, **remember** to update the path `C:\Qt\6.8.3\msvc2022_64\maplibre-native-qt\install` inside `DCMAKE_PREFIX_PATH`.

## 2. Build the application

```bash
cmake --build build --config Release
```

## 3. Install the built files

```bash
cmake --install build --config Release
```

## 4. Generate the installer

Run inside the **build/** directory:

```bash
cpack -C Release
```

This generates an installer executable (`.exe`) inside **build/**, which developers can distribute directly.
