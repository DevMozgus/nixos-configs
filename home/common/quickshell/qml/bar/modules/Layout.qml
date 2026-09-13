// Layout — Hyprland tiling layout indicator + switcher.
//
// Shows the current general:layout (polled via hyprctl getoption; there
// is no socket2 event for it) and opens a popover to switch between
// dwindle and master. Switching dispatches the keyword and updates the
// label optimistically — the poll reconciles external changes.

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import qs
import qs.components

BarWidget {
    id: root

    property var hub: null

    property string currentLayout: "dwindle"

    checked: layoutPopover.visible

    onClicked: {
        if (root.hub)
            root.hub.openPopover(layoutPopover, root);
        else
            layoutPopover.toggleFor(root);
    }

    // Safe on startup — pulls the initial layout value.
    Component.onCompleted: pollProcess.running = true

    Timer {
        interval: 2000
        repeat: true
        running: true

        onTriggered: pollProcess.running = true
    }

    Process {
        id: pollProcess

        command: ["hyprctl", "getoption", "general:layout", "-j"]

        stdout: StdioCollector {
            id: layoutOut

            onStreamFinished: {
                try {
                    const parsed = JSON.parse(layoutOut.text);
                    if (parsed.str !== undefined && parsed.str !== null)
                        root.currentLayout = parsed.str;
                } catch (e) {
                    // Keep the previous value on malformed output.
                }
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: root.currentLayout
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: root.contentColor
    }

    Popover {
        id: layoutPopover

        popWidth: 200

        MenuRow {
            width: parent.width
            icon: Theme.icons.layoutDwindle
            label: "Dwindle"
            selected: root.currentLayout === "dwindle"

            onActivated: {
                Hyprland.dispatch("keyword general:layout dwindle");
                root.currentLayout = "dwindle";
                layoutPopover.dismiss();
            }
        }

        MenuRow {
            width: parent.width
            icon: Theme.icons.layoutMaster
            label: "Master"
            selected: root.currentLayout === "master"

            onActivated: {
                Hyprland.dispatch("keyword general:layout master");
                root.currentLayout = "master";
                layoutPopover.dismiss();
            }
        }
    }
}
