# 🪟 Windows Setup

To start developing with the project on Windows, we need to install Visual Studio for C++, Qt6, QtCreator, and the Qt6Mqtt module.

Install everything first before opening the project.

[[_TOC_]]

> 📸 **This guide could use some helpful screenshots!**  
>
> If you’ve gone through the setup and want to make this easier for others, PRs with images are very welcome! 🙌


## 1 | Installing Visual Studio

1. Download the Visual Studio installer (not Visual Studio Code) from their website: https://visualstudio.microsoft.com/

2. You will be asked to download which version, choose Community and the download will start automatically.

3. Open the installer and you will be asked which workloads to install, under "Desktop & Mobile", select "Desktop development with C++". And continue installing it.

## 2 | Installing Qt6 and QtCreator

1. Follow this page to download the installer: https://doc.qt.io/qt-6/qt-online-installation.html

2. Once you have downloaded the installer and opened it, go for "Custom Installation" and hit "Next".

3. Download the following components:

- Under Extensions:
  - Under Qt PDF: (lets us render and display PDF documents)
    - Under Qt 6.8.3:
      - Select MSVC 2022 x64
  - Under Qt WebEngine: (lets us interact with web content inside a Qt app)
    - Under Qt 6.8.3:
      - Select Debug Information Files (needed to debug WebEngine-related code)
      - Select MSVC 2022 x64
- Under Qt:
  - Under Qt 6.8.3:
    - Select MSVC 2022 64-bit (required to build using the MSVC compiler from Visual Studio)
    - Select Additional Libraries (includes Qt Location, Qt Positioning, etc.)
    - Select Qt Debug Information Files (enables proper debugging of Qt)
  - Under Build Tools:
    - Select CMake (used for generating build files)
    - Select Ninja (used for executing build files)
    - Under OpenSSL Toolkit
      - Select OpenSSL 64-bit binaries (used for SSL/TLS support)
- Under Qt Creator:
  - Select Qt Creator 17.0.0 (recommended IDE for Qt development, you can pick the latest version)
  - Select CDB Debugger Support (allows Qt Creator to use the CDB debugger with MSVC)
  - Select Debugging Tools for Windows (installs the actual CDB debugger)
  - Select Debug Symbols (for better debugging experience)

Versions may vary.

The project is set to work in Qt version 6.8.3. However, newer Qt versions can/may work since Qt is backward-compatible as per the docs. ([Import Statements | Module (Namespace) Imports](https://doc.qt.io/qt-6/qtqml-syntax-imports.html#module-namespace-imports))

You might have noticed there are a lot more modules under Qt 6.8.3 (or in another newer version if that's what you're installing), they're not needed and they just bloat Qt. For example, `Sources` if you're planning on contributing to Qt and others that are pretty self-explanatory like `Android`, `WebAssembly` etc. There's also `MinGW` which is another C++ compiler, however, MSVC is more optimized for Windows.

At the time of writing, the Qt PDF, Qt WebEngine, and Qt OpenSSL Toolkit modules are currently not used by the project but I have you installed them in the case that we do use them then.

## 3 | Installing and Setting Up Qt6Mqtt

1. Press Windows key and type for "x64 Native Tools for VS 2022" to open the developer command prompt.

2. Run `C:\Qt\6.8.3\msvc2022_64\bin\qtenv2.bat` to set the environment variables for using Qt tools from the command line.

> Ignore the warning `Remember to call vcvarsall.bat to complete environment setup!` if it logged.

3. Clone the Qt6's Mqtt repository: `git clone -b 6.8.3 https://code.qt.io/qt/qtmqtt.git`

> Again, your version may vary so checkout (which is denoted by `-b 6.8.3`) to the branch matching your installed version of Qt.

4. Go into that folder by: `cd qtmqtt`

5. Run the following command:

```cmd
cmake -B build -G "Ninja Multi-Config" -DCMAKE_PREFIX_PATH=C:\Qt\6.8.3\msvc2022_64 -DCMAKE_INSTALL_PREFIX=C:\Qt\6.8.3\msvc2022_64 -DQT_BUILD_TESTS=OFF -DQT_BUILD_EXAMPLES=OFF -DQT_FEATURE_ssl=ON .
```

Here’s what each flag does:

- `-B build`: Generate all build files (and later object/output files) inside the `build/` folder instead of mixing them with the sources.
- `-G "Ninja Multi-Config"`: Use the **Ninja Multi-Config** generator, so one build tree can hold Debug/Release/etc. side-by-side.
- `-DCMAKE_PREFIX_PATH=`: Tell CMake where to find Qt’s CMake packages (`Qt6Config.cmake`, etc.).
- `-DCMAKE_INSTALL_PREFIX=`: Where the built Qt modules will be installed.
- `-DQT_BUILD_TESTS=OFF`: Skip building Qt’s internal test suites.
- `-DQT_BUILD_EXAMPLES=OFF`: Skip building example projects.
- `-DQT_FEATURE_ssl=ON`: Force-enable Qt’s SSL support (so modules that depend on OpenSSL get built).
- `.`: Use the current directory as the source tree (where the top-level `CMakeLists.txt` is).

> Always check for your Qt installed version if it is different from 6.8.3.

6. After configuring with the command above, build and install the two following configurations (I suggest running each command below separately):

```cmd
cmake --build build --config RelWithDebInfo --target install
cmake --build build --config Debug          --target install
```

And here's what each flag does:

- `--build build`: Operate on the `build/` directory created earlier.
- `--config <name>`: Select which configuration to build (only works because of the multi-config generator).
- `--target install`: Run the install target, copying headers, libraries, and tools into `C:\Qt\6.8.3\msvc2022_64` for each configuration.

## 4 | Setting, Building, and Running the Project

1. Open Qt Creator.
2. Open the project by going to its directory and clicking on the `CMakeLists.txt` file.
3. You'll be asked to configure the project, you should automatically have MSVC selected. Proceed with that.
4. Then the project will open and will start setting itself up. Afterwards, you can then build the project by clicking on the hammer icon on the left then run it by clicking on the play button.
