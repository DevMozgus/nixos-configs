// IconButton — small square glyph button with hover/press wash.
// Glyphs are Nerd Font codepoints rendered with the mono font.

import QtQuick

import qs

Rectangle {
    id: root

    property string icon: ""
    property int iconSize: 14
    property bool danger: false
    property bool accent: false

    signal activated()

    implicitWidth: 28
    implicitHeight: 28
    radius: Theme.radius.sm

    color: {
        if (mouse.pressed)
            return Theme.washStrong;
        if (mouse.containsMouse)
            return Theme.wash;
        return "transparent";
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration.fast
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.icon
        font.family: Theme.fonts.mono
        font.pixelSize: root.iconSize
        color: {
            if (root.danger)
                return Theme.danger;
            if (root.accent)
                return Theme.accent;
            return mouse.containsMouse ? Theme.fgBright : Theme.fg;
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

    Accessible.role: Accessible.Button
    Accessible.name: root.icon
}
