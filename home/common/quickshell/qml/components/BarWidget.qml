// BarWidget — the unified bar pill.
//
// Every bar module builds on this: hover wash, press feedback, a
// `checked` selected state (accent hairline, e.g. while its popover is
// open), and a centered content row. Modules put icon/label Texts inside
// and anchor them vertically; content color follows `contentColor`.

import QtQuick

import qs

Rectangle {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    default property alias contentData: contentRow.data
    property alias contentSpacing: contentRow.spacing

    property int padH: 10

    // false → static indicator: no wash, no click cursor, no signal.
    property bool interactive: true

    // Selected / popover-open state.
    property bool checked: false

    readonly property bool hovered: root.interactive && mouse.containsMouse

    // Bind content Text colors to this so the whole bar brightens together.
    readonly property color contentColor: root.checked || root.hovered ? Theme.fgBright : Theme.fg

    signal clicked()

    // ── Visuals ─────────────────────────────────────────────────────────
    implicitWidth: contentRow.implicitWidth + root.padH * 2
    implicitHeight: Theme.barHeight - 6
    radius: Theme.radius.sm

    color: {
        if (!root.interactive)
            return "transparent";
        if (root.checked || mouse.pressed)
            return Theme.washStrong;
        if (mouse.containsMouse)
            return Theme.wash;
        return "transparent";
    }

    border.width: root.checked ? 1 : 0
    border.color: Theme.withAlpha(Theme.accent, 0.7)

    Behavior on color {
        ColorAnimation {
            duration: Theme.duration.fast
        }
    }

    Row {
        id: contentRow

        anchors.centerIn: parent
        spacing: 6
    }

    MouseArea {
        id: mouse

        anchors.fill: parent
        enabled: root.interactive
        hoverEnabled: true
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }
}
