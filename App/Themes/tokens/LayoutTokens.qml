/*!
    \qmltype Layout
    \inqmlmodule App.Themes
    \brief Defines standard layout tokens.

    The \c {Layout} token family centralizes layout values such as width and height.

    This token family contains semantic values, if you need primitive token values,
    take a look at \c {SpacingTokens} or \c {IconTokens}.
*/

import QtQuick 2.15

QtObject {
    // ApplicationWindow
    readonly property int appWindowWidth: 1400
    readonly property int appWindowHeight: 800

    // TitleBar
    readonly property int titleBarHeight: 68
    readonly property int searchBarWidth: 284
    readonly property int searchBarHeight: 32

    // SideRail
    readonly property int sideRailWidth: 80

    // SidePanel
    readonly property int sidePanelWidth: 490
    readonly property int panelTitleHeight: 68

    // NotificationsBar
    readonly property int notificationsBarWidth: 410
    readonly property int notificationsBarItemWidth: 18
    readonly property int notificationsBarItemHeight: notificationsBarItemWidth

    // ContextPanel
    readonly property int contextPanelWidth: 486
}
