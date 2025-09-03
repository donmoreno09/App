add_subdirectory(Language)

# Core UIs
add_subdirectory(TitleBar)
add_subdirectory(SideRail)
add_subdirectory(SidePanel)
add_subdirectory(ContextPanel)
add_subdirectory(NotificationsBar)

# Modules need to be linked in order to be loaded using qrc.
# Also, make sure that the RESOURCE_PREFIX of the module is the same as App's (which is "/").
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        app_features_language

        # Core UIs
        app_features_titlebar
        app_features_siderail
        app_features_sidepanel
        app_features_contextpanel
        app_features_notificationsbar
)
