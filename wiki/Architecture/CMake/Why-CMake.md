CMake is not a compiler, but a **build system generator**. In practice, it takes a high-level project description (called `CMakeLists.txt`) and produces the lower-level configuration files required by a specific build system, such as:

- **Makefiles** (for `make`)
- **Ninja build files** (for `ninja`)
- Project files for IDEs like Visual Studio, Xcode, and Qt Creator

From the official documentation:

_"CMake is a tool to manage building of source code."_ ([CMake Docs](https://cmake.org/cmake/help/latest/))

CMake is portable and widely supported across operating systems, compilers, and IDEs including **Qt Creator**, which has adopted CMake as its primary build system since Qt 6.

[[_TOC_]]

## Why use CMake in our project?

There are various reasons as why we would want to use CMake as our build system generator which are listed below:

### 1 | Qt 6 Standard

Qt itself is now built and maintained with CMake. While `.pro`/qmake files are still supported for legacy reasons, the official recommendation for new projects is to use CMake. This ensures long-term compatibility and alignment with the Qt ecosystem.

_"We recommend using CMake for all new projects. You can use an IDE such as Qt Creator to create Qt applications that use CMake as the build system, which can be built and run on multiple platforms."_ ([Building with Cmake: Getting Started with CMake and Qt, Qt Academy](https://www.qt.io/academy/course-catalog#-building-with-cmake:-getting-started-with-cmake-and-qt))

> The quote itself comes from the official Qt documentation to follow that course: [Getting started with CMake](https://doc.qt.io/qt-6/cmake-get-started.html)

### 2 | Maintainability through Modularity

With CMake, we can split the codebase into self-contained modules (e.g., `Themes`, `Features/Map`, `Features/SidePanel`) and each module has its own `CMakeLists.txt`, making it:

- Easier to **test** in isolation.
- Easier to **replace or refactor** without breaking unrelated parts.
- Easier to **extend** when adding new features.

At the root level, our main `CMakeLists.txt` simply pulls these modules together. This structure makes the project less monolithic and more like a set of Lego blocks that fit together.

### 3 | Cross-Platform and Toolchain Flexibility

Whether we build on Linux, Windows, or macOS, CMake handles the platform differences for us. It detects the available compilers and configures the project accordingly. Switching between `ninja` and `make`, or even generating IDE projects, becomes trivial.

### 4 | Integration with Testing and Packaging

CMake has first-class support for testing (via **CTest**) and packaging (via **CPack**). This means our build system can eventually cover not just compilation, but also automated testing pipelines and deployment packages with minimal setup.

### 5 | Community and Ecosystem Support

CMake is one of the most widely used build system generators in C++ and has extensive community support, tutorials, and tooling integrations (e.g., CLion, Visual Studio Code, Qt Creator). Using it aligns us with industry practice and makes onboarding new developers easier.

That being said, **if we use CMake as our build system generator but fail to leverage its full potential**, we undermine the very reason for choosing it. This section aims to provide clear, concise guidance on how to make effective use of CMake in our project.

In addition, we use Ninja instead of Make, as it offers significantly faster build times.

By using CMake, we are not just following Qt’s standard but we are setting up a **scalable, modular, and future-proof foundation**. It allows us to treat each feature (Themes, Map, SidePanel, etc.) as an independent module, which improves maintainability, testing, and long-term project health.
