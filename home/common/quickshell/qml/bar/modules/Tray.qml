// Tray — system tray items with activation + menus.
//
// Left click activates the item; right click opens its menu as a
// popover (QsMenuOpener over item.menu, rendered as MenuRows — check
// state, separators, disabled entries). If the menu handle yields
// nothing renderable, the platform menu (item.display(null, 0, 0)) is
// used as a fallback. Wheel events scroll the item. Hidden until
// items exist.

import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import qs
import qs.components

BarWidget {
    id: root

    property var hub: null

    interactive: false
    padH: 4
    contentSpacing: 6

    readonly property var items: SystemTray.items ? (SystemTray.items.values ?? []) : []

    visible: root.items.length > 0

    function openMenu(item, owner) {
        trayMenu.currentItem = item;
        if (root.hub)
            root.hub.openPopover(trayMenu, owner);
        else
            trayMenu.toggleFor(owner);
    }

    Repeater {
        model: root.items

        delegate: Item {
            id: trayIcon

            required property var modelData

            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter

            // IconImage (Quickshell.Widgets) resolves tray icon names as
            // well as image:// URLs; a plain Image only understands URLs,
            // which is why it is not the primary choice here.
            IconImage {
                anchors.fill: parent

                source: trayIcon.modelData.icon
                sourceSize.width: 16
                sourceSize.height: 16
                asynchronous: true
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton) {
                        if (trayIcon.modelData.hasMenu)
                            root.openMenu(trayIcon.modelData, trayIcon);
                        else
                            trayIcon.modelData.display(null, 0, 0);
                        return;
                    }
                    trayIcon.modelData.activate();
                }

                onWheel: wheel => trayIcon.modelData.scroll(wheel.angleDelta.y > 0 ? 1 : -1, true)
            }
        }
    }

    Popover {
        id: trayMenu

        popWidth: 220

        property var currentItem: null

        function popoverOpened() {
            // Menus populate asynchronously — if nothing renderable
            // shows up, defer to the platform menu.
            fallbackTimer.restart();
        }

        function popoverClosed() {
            fallbackTimer.stop();
            trayMenu.currentItem = null;
        }

        function _trigger(entry) {
            // QsMenuEntry activation is its triggered() signal invoked
            // as a function; guard defensively anyway.
            if (typeof entry.triggered === "function")
                entry.triggered();
            else if (typeof entry.clicked === "function")
                entry.clicked();
        }

        function _hasEntries() {
            return menuOpener.children ? (menuOpener.children.values ?? []).length > 0 : false;
        }

        Timer {
            id: fallbackTimer

            interval: 250
            onTriggered: {
                if (trayMenu.visible && !trayMenu._hasEntries()) {
                    const item = trayMenu.currentItem;
                    if (item && typeof item.display === "function")
                        item.display(null, 0, 0);
                    trayMenu.dismiss();
                }
            }
        }

        QsMenuOpener {
            id: menuOpener

            menu: trayMenu.currentItem ? trayMenu.currentItem.menu : null
        }

        Repeater {
            model: menuOpener.children

            delegate: Column {
                id: menuEntry

                required property var modelData

                width: parent.width

                Rectangle {
                    width: parent.width
                    height: 1
                    visible: menuEntry.modelData.isSeparator === true
                    color: Theme.hairline
                }

                MenuRow {
                    width: parent.width
                    visible: menuEntry.modelData.isSeparator !== true

                    icon: menuEntry.modelData.checked === true ? Theme.icons.check : ""
                    label: String(menuEntry.modelData.text ?? "")
                    showChevron: menuEntry.modelData.hasChildren === true
                    opacity: menuEntry.modelData.enabled === false ? 0.4 : 1

                    onActivated: {
                        if (menuEntry.modelData.enabled === false)
                            return;
                        if (menuEntry.modelData.hasChildren === true)
                            return; // submenu traversal not rendered
                        trayMenu._trigger(menuEntry.modelData);
                        trayMenu.dismiss();
                    }
                }
            }
        }
    }
}
