// Slider — minimal horizontal slider (0..1).
//
// `value` is externally bound and never written internally: interactions
// emit moved() so caller-side bindings (e.g. node.audio.volume) survive.
// While dragging, the knob follows the scrub position; on release it
// snaps back to the (updated) bound value.

import QtQuick

import qs

Item {
    id: root

    property real value: 0
    property real step: 0.05
    readonly property bool pressed: area.pressed

    signal moved(real value)

    implicitWidth: 140
    implicitHeight: 24

    function _clamp(v) {
        return Math.min(1, Math.max(0, v));
    }

    function _seek(x) {
        const usable = Math.max(1, root.width - 12);
        const v = root._clamp((x - 6) / usable);
        root._scrub = v;
        root.moved(v);
    }

    property real _scrub: 0
    readonly property real _visual: area.pressed ? root._scrub : root._clamp(root.value)

    // Track
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        height: 4
        radius: 2
        color: Theme.selection

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            width: parent.width * root._visual
            radius: 2
            color: Theme.accent
        }
    }

    // Knob
    Rectangle {
        id: knob

        anchors.verticalCenter: parent.verticalCenter
        x: 6 + Math.max(1, root.width - 12) * root._visual - width / 2

        width: 12
        height: 12
        radius: 6
        color: Theme.white
        scale: area.pressed ? 1.15 : (area.containsMouse ? 1.1 : 1.0)

        Behavior on x {
            NumberAnimation {
                duration: root.pressed ? 0 : Theme.duration.fast
                easing.type: Theme.easing
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.duration.fast
                easing.type: Theme.easing
            }
        }
    }

    MouseArea {
        id: area

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: mouse => root._seek(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                root._seek(mouse.x);
        }
        onWheel: wheel => {
            const dir = wheel.angleDelta.y > 0 ? 1 : -1;
            root.moved(root._clamp(root.value + dir * root.step));
        }
    }

    Accessible.role: Accessible.Slider
    Accessible.name: Math.round(root.value * 100) + "%"
}
