// MenuRow — one popover menu row.
//
// icon + label + optional mono readout + optional trailing control
// (default property) + optional chevron. Hover/press wash; `danger` tints
// destructive rows; `armed` is the two-step destructive confirmation state.

import QtQuick

import qs

Rectangle {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    property string icon: ""
    property string label: ""
    property string readout: ""        // mono value on the right ("" hides)
    property bool showChevron: false
    property bool danger: false
    property bool armed: false         // destructive confirmation armed
    property string armedLabel: ""     // label shown while armed
    property bool selected: false      // accent highlight (e.g. active device)

    // Trailing control slot (Toggle, Slider, …).
    default property alias trailing: trailingSlot.data

    signal activated()

    // ── Visuals ─────────────────────────────────────────────────────────
    implicitHeight: 34
    radius: Theme.radius.sm

    color: {
        if (root.armed)
            return Theme.dangerWash;
        if (mouse.pressed)
            return Theme.washStrong;
        if (mouse.containsMouse)
            return Theme.wash;
        return "transparent";
    }

    border.width: root.armed ? 1 : 0
    border.color: Theme.withAlpha(Theme.danger, 0.5)

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration.fast
        }
    }

    Text {
        id: iconText

        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        width: 20
        visible: root.icon !== ""
        text: root.icon
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: {
            if (root.armed || root.danger)
                return Theme.danger;
            if (root.selected)
                return Theme.accent;
            return mouse.containsMouse ? Theme.fgBright : Theme.fgDark;
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    // Right cluster: readout → trailing slot → chevron.
    Row {
        id: rightCluster

        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.sm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.readout !== ""
            text: root.readout
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.sm
            color: Theme.fgDark
        }

        Item {
            id: trailingSlot

            anchors.verticalCenter: parent.verticalCenter
            implicitWidth: childrenRect.width
            implicitHeight: childrenRect.height
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showChevron
            text: Theme.icons.chevronRight
            font.family: Theme.fonts.mono
            font.pixelSize: 12
            color: Theme.comment
        }
    }

    Text {
        anchors.left: iconText.right
        anchors.leftMargin: root.icon !== "" ? Theme.spacing.sm : 0
        anchors.right: rightCluster.left
        anchors.rightMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        text: root.armed && root.armedLabel !== "" ? root.armedLabel : root.label
        elide: Text.ElideRight
        font.family: Theme.fonts.sans
        font.pixelSize: Theme.fonts.size.md
        color: {
            if (root.armed)
                return Theme.danger;
            if (root.selected || mouse.containsMouse)
                return Theme.fgBright;
            return Theme.fg;
        }

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: root.label
}
