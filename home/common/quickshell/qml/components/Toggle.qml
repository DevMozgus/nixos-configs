// Toggle — minimal switch.
//
// `checked` is externally bound and never written internally: interactions
// emit toggled(newState) so caller-side bindings (e.g. node.audio.muted)
// survive and optimistic state stays consistent.

import QtQuick

import qs

Rectangle {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: 34
    implicitHeight: 20
    radius: Theme.radius.pill

    color: root.checked ? Theme.accent : (mouse.containsMouse ? Theme.comment : Theme.selection)

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration.fast
        }
    }

    Rectangle {
        id: knob

        x: root.checked ? parent.width - width - 3 : 3
        anchors.verticalCenter: parent.verticalCenter

        width: 14
        height: 14
        radius: Theme.radius.pill
        color: root.checked ? Theme.white : Theme.fgDark

        Behavior on x {
            NumberAnimation {
                duration: Theme.duration.normal
                easing.type: Theme.easing
            }
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
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }

    Accessible.role: Accessible.CheckBox
    Accessible.checked: root.checked
}
