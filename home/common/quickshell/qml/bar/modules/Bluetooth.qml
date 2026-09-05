// Bluetooth — adapter status pill (Quickshell.Bluetooth).
//
// Bluetooth glyph, bright while the adapter is enabled, comment-colored
// when off; small success dot while any device is connected. Click opens
// BluetoothPopover through the hub.

import QtQuick
import Quickshell.Bluetooth

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabled: root.adapter !== null && root.adapter.enabled

    readonly property bool anyConnected: {
        if (!root.adapter || !root.adapter.devices)
            return false;
        return (root.adapter.devices.values ?? []).some(d => d.connected);
    }

    checked: bluetoothPopover.visible
    contentSpacing: 6

    onClicked: {
        if (root.hub)
            root.hub.openPopover(bluetoothPopover, root);
        else
            bluetoothPopover.toggleFor(root);
    }

    BluetoothPopover {
        id: bluetoothPopover
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: Theme.icons.bluetooth
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.enabled ? root.contentColor : Theme.comment

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.anyConnected

        width: 6
        height: 6
        radius: 3
        color: Theme.success
    }
}
