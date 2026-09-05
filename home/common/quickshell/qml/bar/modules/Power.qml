// Power — opens the power menu popover.
// Real actions live in PowerMenu (lock/logout/suspend/reboot/shutdown).

import QtQuick

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    readonly property alias menu: powerMenu

    checked: powerMenu.visible

    onClicked: {
        if (root.hub)
            root.hub.openPopover(powerMenu, root);
        else
            powerMenu.toggleFor(root);
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icons.power
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.contentColor
    }

    PowerMenu {
        id: powerMenu
    }
}
