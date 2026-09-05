// Workspaces — Hyprland workspaces as clickable chips.
//
// Live from Quickshell.Hyprland: one chip per real workspace (id > 0;
// named/special workspaces have negative ids and are skipped). The
// focused chip gets the accent/selected style, active-but-unfocused
// ones stay bright, urgent workspaces tint danger. Click → ws.activate().

import QtQuick
import Quickshell.Hyprland

import qs
import qs.components

BarWidget {
    id: root

    property var hub: null

    interactive: false
    padH: 6
    contentSpacing: 4

    // Safe on startup — pulls the initial workspace list.
    Component.onCompleted: Hyprland.refreshWorkspaces()

    readonly property var workspaces: Hyprland.workspaces.values.filter(ws => ws.id > 0)

    Repeater {
        model: root.workspaces

        delegate: Rectangle {
            id: chip

            required property var modelData

            readonly property bool focused: modelData.focused
            readonly property bool active: modelData.active
            readonly property bool urgent: modelData.urgent

            width: 24
            height: 22
            anchors.verticalCenter: parent.verticalCenter
            radius: Theme.radius.xs

            color: {
                if (chip.focused)
                    return Theme.accent;
                if (mouse.containsMouse)
                    return Theme.wash;
                if (chip.urgent)
                    return Theme.dangerWash;
                return chip.active ? Theme.selection : "transparent";
            }

            Behavior on color {
                ColorAnimation {
                    duration: Theme.duration.fast
                }
            }

            Text {
                anchors.centerIn: parent
                text: chip.modelData.name !== "" ? chip.modelData.name : chip.modelData.id
                font.family: Theme.fonts.mono
                font.pixelSize: Theme.fonts.size.sm
                font.weight: chip.focused ? Font.Bold : Font.Medium
                color: {
                    if (chip.focused)
                        return Theme.bg;
                    if (chip.urgent)
                        return Theme.danger;
                    if (chip.active || mouse.containsMouse)
                        return Theme.fgBright;
                    return Theme.comment;
                }
            }

            MouseArea {
                id: mouse

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onClicked: chip.modelData.activate()
            }
        }
    }
}
