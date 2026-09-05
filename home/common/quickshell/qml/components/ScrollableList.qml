// ScrollableList — wheel-scrollable clipping container.
//
// Children go into the default property; height follows content up to
// `maxHeight`, after which the wheel scrolls. No visible scrollbar —
// the mdo look stays quiet. Clicks pass through (NoButton area), so
// rows inside stay fully interactive.

import QtQuick

import qs

Item {
    id: root

    default property alias contentData: column.data
    property alias contentHeight: column.implicitHeight
    property int maxHeight: 400

    implicitWidth: 240
    implicitHeight: Math.min(column.implicitHeight, maxHeight)

    clip: true

    property real _y: 0

    Behavior on _y {
        NumberAnimation {
            duration: Theme.duration.instant
            easing.type: Theme.easing
        }
    }

    function _scroll(dy) {
        const maxScroll = Math.max(0, column.implicitHeight - root.height);
        root._y = Math.min(maxScroll, Math.max(0, root._y + dy));
    }

    Column {
        id: column

        y: -root._y
        width: root.width
        spacing: 2
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => root._scroll(wheel.angleDelta.y > 0 ? -44 : 44)
    }
}
