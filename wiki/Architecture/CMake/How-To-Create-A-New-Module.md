This guide explains **how to add a new Feature module** (example: `Map`) so it can be imported in QML as `App.Features.Map`. It also clarifies why each step exists, so future modules follow the same pattern consistently.

[[_TOC_]]

## 1 | Create the module folder (TitleCase)

Use `TitleCase` for public modules to mirror the **import URI** and to distinguish them from internal folders.

```
App/
└─ Features/
   └─ Map/
```

The folder name becomes the last segment of the QML import (`App.Features.Map`). Matching names keeps imports predictable and avoids build errors. For more information, check [Writing QML Modules](https://doc.qt.io/qt-6/qtqml-writing-a-module.html).

## 2 | Create `App/Features/Map/CMakeLists.txt`

Next, we declare the QML module so it can be imported as `App.Features.Map`, and explicitly list its QML/C++ files. We keep file lists explicit to keep builds deterministic, and singletons must be marked so the engine treats them correctly.

To create a CMakeLists.txt file, in **Qt Creator**, right-click the **Features** folder, choose **Add New...**, then under **General** select **Empty File**. Click **Choose**, name it `CMakeLists.txt`, and in the **Add to project** step select **None** before finishing.

If you accidentally added it to another project (for example under `App/CMakeLists.txt`), open that `CMakeLists.txt` and remove the accidental entry `RESOURCES Features/Map/CMakeLists.txt` since CMake files should not be treated as resources. 

```cmake
# App/Features/Map/CMakeLists.txt

set(qml_files
    # Public QML files
)

set(qml_singletons
    # QML singletons
)

set(cpp_files
    # C++ sources/headers, if any
)

# Mark QML singletons only if present
set_source_files_properties(${qml_singletons}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE)
endif()

qt_add_qml_module(app_features_map
    URI App.Features.Map
    VERSION 1.0
    QML_FILES
        ${qml_files}
        ${qml_singletons}
    SOURCES
        ${cpp_files}
    RESOURCE_PREFIX "/"
)

target_link_libraries(app_features_map
    PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        # Link more libraries here as necessary but you might
        # need to set them in find_package() in the root CMakeLists first.
)
```

If you don’t have singletons, you can remove or keep the `set_source_files_properties` block inside the `if(qml_singletons)` guard as shown. Finally, always keep the target and URI aligned: the folder `Map/` in TitleCase corresponds to the URI segment `Map`, which allows the import `App.Features.Map`.

Notice the line `RESOURCE_PREFIX "/"`, that is needed to align with our Qt imports of `qrc:/` instead of `qrc:/qt/qml` and to be able to load QML files such as when dynamically loading `SidePanel`'s content. Also, **make sure to link the module inside `App/Features/CMakeLists.txt`.** (You'll find a comment there regarding module imports with qrc.)

## 3 | Register the subdirectory

Wire the module into the build by adding its folder to the parent CMake.

```cmake
# App/Features/CMakeLists.txt
add_subdirectory(Map)
...
```

Without this, CMake won’t descend into `Map/`, so the QML module won’t be generated.

**Note:** Ensure `App/CMakeLists.txt` already has `add_subdirectory(Features)`, which it should have already.

## 4 | Importing the module

Once you've added files into the module, you can use its files through:

```qml
import App.Features.Map 1.0
```

For more information on how to structure your files in CMake, check the source code for `App/Themes/CMakeLists.txt`.

## 5 | Common pitfalls (avoid these)

- **Case mismatch**: `Map` vs `map`.
- **Forgetting `add_subdirectory(Map)`**: module never built.
- **Not listing files in CMake**: module builds but contains nothing.
- **Singletons not marked**: `pragma Singleton` is needed on top of singleton QMLs files.

**Notes:** Keep TitleCase for public modules.