// Clock — center pill: mono time over a small uppercase date line.
// Click opens the calendar popover.

import QtQuick

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    property var now: new Date()
    readonly property string timeText: Qt.formatDateTime(now, "HH:mm")
    readonly property string dateText: Qt.formatDateTime(now, "ddd d MMM").toUpperCase()

    checked: clockPopover.visible
    padH: 12

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }

    onClicked: {
        if (root.hub)
            root.hub.openPopover(clockPopover, root);
        else
            clockPopover.toggleFor(root);
    }

    ClockPopover {
        id: clockPopover
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 0

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.timeText
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.md
            font.weight: Font.DemiBold
            color: root.contentColor
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.dateText
            font.family: Theme.fonts.sans
            font.pixelSize: 9
            font.letterSpacing: 0.8
            color: Theme.withAlpha(root.contentColor, 0.75)
        }
    }
}
