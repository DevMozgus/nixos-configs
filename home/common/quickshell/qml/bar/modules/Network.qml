// Network — Wi-Fi / wired status pill (Quickshell.Networking).
//
// Wifi glyph while Wi-Fi is enabled or connected, ethernet otherwise;
// warning color while a connection is in progress; SSID readout when
// connected. Click opens NetworkPopover through the hub.

import QtQuick
import Quickshell.Networking

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    readonly property var wifiDevice: root._findDevice(true)
    readonly property var wiredDevice: root._findDevice(false)

    // Connected wifi network (its name is the readout).
    readonly property var activeNet: {
        const dev = root.wifiDevice;
        if (!dev || !dev.networks)
            return null;
        return (dev.networks.values ?? []).find(n => n.connected) ?? null;
    }

    readonly property bool connected: root.activeNet !== null || (root.wiredDevice !== null && root.wiredDevice.connected)

    readonly property bool connecting: root._deviceConnecting(root.wifiDevice)

    readonly property string netIcon: {
        if (root.activeNet !== null)
            return Theme.icons.wifi;
        if (root.wiredDevice !== null && root.wiredDevice.connected)
            return Theme.icons.ethernet;
        if (Networking.wifiEnabled)
            return Theme.icons.wifi;
        return Theme.icons.ethernet;
    }

    checked: networkPopover.visible
    contentSpacing: 6

    onClicked: {
        if (root.hub)
            root.hub.openPopover(networkPopover, root);
        else
            networkPopover.toggleFor(root);
    }

    NetworkPopover {
        id: networkPopover
    }

    function _isWifi(dev) {
        // Defensive: NetworkDeviceType member names have varied across
        // quickshell versions — fall back to the presence of the wifi
        // network model, which wired devices don't have.
        if (NetworkDeviceType.Wifi !== undefined)
            return dev.type === NetworkDeviceType.Wifi;
        return dev.networks !== undefined;
    }

    function _findDevice(wantWifi) {
        const devices = Networking.devices ? (Networking.devices.values ?? []) : [];
        return devices.find(d => root._isWifi(d) === wantWifi) ?? null;
    }

    function _deviceConnecting(dev) {
        if (dev && dev.state !== undefined && ConnectionState.Connecting !== undefined)
            return dev.state === ConnectionState.Connecting;
        return false;
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter

        text: root.netIcon
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.connecting ? Theme.warning : (root.connected ? Theme.fgBright : Theme.comment)

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        visible: root.activeNet !== null

        text: root.activeNet ? root.activeNet.name : ""
        width: Math.min(implicitWidth, 110)
        elide: Text.ElideRight
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: root.connecting ? Theme.warning : Theme.fgBright

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }
}
