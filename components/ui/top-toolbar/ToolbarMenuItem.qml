import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

ToolbarItem {
    id: toolBtn

    property TopToolbar toolbar
    property var tool

    onPressed: {
        menu.open()
    }

    StyledMenu {
        id: menu
        y: toolBtn.height + 2
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        // RIMOSSO: background: Rectangle { ... } e il suo padding
        // RIMOSSO: contentItem: ColumnLayout { padding: 4; spacing: 2 }

        onClosed: {
            if (tool.id !== toolbar.currentToolId && tool.id !== toolbar.currentMode) {
                toolbar.setCurrentTool(toolbar.previousToolId)
            }
        }

        Instantiator {
            model: tool.menu
            delegate: Loader {
                sourceComponent: {
                    if (!tool) return null
                    if (tool.menu.get(index) === 0) return null
                    if (tool.menu.get(index).separator) return sectionTitleComponent
                    return subMenuComponent
                }

                onLoaded: {
                    if (item) {
                        item.item = tool.menu.get(index)
                        if (tool.menu.get(index).separator) menu.insertItem(index, item)
                        else menu.insertMenu(index, item)
                    }
                }

                Component.onDestruction: {
                    if (!item || !tool.menu) return

                    if (tool.menu.get(index).separator) menu.removeItem(item)
                    else menu.removeMenu(item)
                }
            }
        }

        Component {
            id: subMenuComponent

            StyledMenu {
                property var item

                id: subMenu
                title: item.name

                // RIMOSSO: background: Rectangle { ... } e il suo padding
                // RIMOSSO: contentItem: ColumnLayout { ... }

                Instantiator {
                    model: item.values
                    delegate: StyledMenuItem {
                        // RIMOSSO: contentItem: Text { ... } e il suo colore e font.
                        // RIMOSSO: background: Rectangle { ... }

                        text: item ? item.values.get(index).value : undefined

                        onTriggered: {
                            toolbar.onPoiSelect(tool.id, item, item.values.get(index))
                            menu.close()
                        }
                    }

                    onObjectAdded: (index, object) => subMenu.insertItem(index, object)
                    onObjectRemoved: (index, object) => subMenu.removeItem(object)
                }
            }
        }

        Component {
            id: sectionTitleComponent

            MenuSectionTitle {
                property var item
                text: item.label

                // RIMOSSO: color: "#CCCCCC"; font.family: "RobotoMedium"; font.pointSize: 10; padding: ...
            }
        }
    }
}
