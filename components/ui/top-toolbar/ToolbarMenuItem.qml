import QtQuick 6.8
import QtQuick.Controls 6.8
import QtQuick.Layouts 6.8

ToolbarItem {
    id: toolBtn

    // Use onPressed for now to stop the flickering to previous tool bug
    // Check ToolbarItem's onPressed
    onPressed: {
        menu.open()
    }

    StyledMenu {
        id: menu
        y: toolBtn.height + 2
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        onClosed: {
            toolbar.setCurrentTool(toolbar.previousToolId)
        }

        Instantiator {
            model: tool.menu
            delegate: Loader {
                // sometimes modelData does not exist (sometimes it gives '0' as the first element)
                sourceComponent: {
                    if (!tool) return
                    if (tool.menu.get(index) === 0) return
                    if (tool.menu.get(index).separator) return sectionTitleComponent
                    return subMenuComponent
                }

                onLoaded: {
                    item.item = tool.menu.get(index)
                    if (tool.menu.get(index).separator) menu.insertItem(index, item)
                    else menu.insertMenu(index, item)
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

                Instantiator {
                    model: item.values
                    delegate: StyledMenuItem {
                        text: item ? item.values.get(index).value : undefined

                        onTriggered: {
                            toolbar.onPoiSelect(tool.id, item, item.values.get(index))
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
            }
        }
    }
}
