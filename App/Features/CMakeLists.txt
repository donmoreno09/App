add_subdirectory(Language)
add_subdirectory(Mission)

# Core UIs
add_subdirectory(Map)
add_subdirectory(TitleBar)
add_subdirectory(SideRail)
add_subdirectory(SidePanel)
add_subdirectory(ContextPanel)
add_subdirectory(Notifications)
add_subdirectory(MapToolbar)
add_subdirectory(TrackPanel)
add_subdirectory(TruckArrivals)
add_subdirectory(TrailerPredictions)


# Modules need to be linked in order to be loaded using qrc.
# Also, make sure that the RESOURCE_PREFIX of the module is the same as App's (which is "/").
# Lastly, import the module in SidePanel.qml otherwise it still won't find the module.
target_link_libraries(${PROJECT_NAME}
    PRIVATE
        app_features_language
        app_features_mission

        # Core UIs
        app_features_map
        app_features_titlebar
        app_features_siderail
        app_features_sidepanel
        app_features_contextpanel
        app_features_notifications
        app_features_maptoolbar
        app_features_trackpanel
        app_features_truckarrivals
        app_features_trailerpredictions
)
