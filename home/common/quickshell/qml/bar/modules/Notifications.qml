// Notifications — bell pill: unread count badge, DND state.
//
// Click opens the NotificationCenter (owned by the qs.notifications
// Store singleton, along with the NotificationServer and the toast
// stack — this module is just the bar UI for it). Right-click toggles
// do-not-disturb: DND shows the slashed bell in comment color.

import QtQuick

import qs
import qs.components
import qs.notifications

BarWidget {
    id: root

    property var hub: null

    readonly property int unread: Store.unread
    readonly property bool dnd: Store.dnd

    contentSpacing: 6
    checked: Store.center.visible

    onClicked: Store.center.openWindow()
    onAltClicked: Store.toggleDnd()

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: root.dnd ? Theme.icons.bellSlash : Theme.icons.bell
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.dnd ? Theme.comment : root.contentColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.unread > 0

        text: root.unread > 99 ? "99+" : String(root.unread)
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: Theme.accent
    }
}
