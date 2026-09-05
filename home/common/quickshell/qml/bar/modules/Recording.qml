// Recording — screen-recording indicator with click-to-stop.
//
// Wired via Quickshell.Io FileView existence of the recorder pid file
// (/tmp/screenrecord-pid). Hidden while idle; pulses while recording.
//
// Clicking the pill runs `stop-recording` — the same script the
// $mod SHIFT R keybind reaches through `toggle-recording`, which execs
// `stop-recording` whenever the pid file holds a live pid. The pill is
// only visible while that file exists, so the click matches the keybind
// behaviour exactly.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

BarWidget {
    id: root

    property var hub: null

    interactive: true
    contentSpacing: 6

    visible: recordingFile.text().trim() !== ""

    FileView {
        id: recordingFile

        path: "/tmp/screenrecord-pid"
        watchChanges: true
    }

    onClicked: Quickshell.execDetached(["stop-recording"])

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter

        width: 8
        height: 8
        radius: Theme.radius.pill
        color: Theme.danger

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: root.visible

            NumberAnimation {
                to: 0.35
                duration: 700
                easing.type: Theme.easing
            }
            NumberAnimation {
                to: 1
                duration: 700
                easing.type: Theme.easing
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: "REC"
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.xs
        font.weight: Font.DemiBold
        font.letterSpacing: 1
        color: Theme.danger
    }
}
