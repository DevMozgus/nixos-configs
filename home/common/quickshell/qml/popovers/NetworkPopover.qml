// NetworkPopover — Wi-Fi + wired control (Quickshell.Networking).
//
// Networks come from the wifi device's ObjectModel — quickshell has NO
// scan-start API, so the "Refresh" row shells out to
// `nmcli d wifi rescan` behind a 4s cooldown. Connecting follows the
// NoSecrets flow: connect() first; when the profile needs a passphrase
// the field reveals inline under its row and connectWithPsk() finishes.
// The Wi-Fi Toggle sits as an overlay sibling (not in MenuRow's
// trailing slot) because MenuRow's internal MouseArea would swallow
// clicks aimed at the Toggle.

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Networking

import qs
import qs.components

Popover {
    id: root

    popWidth: 300

    // ── Data ────────────────────────────────────────────────────────────
    readonly property var wifiDevice: root._findDevice(true)
    readonly property var wiredDevice: root._findDevice(false)

    readonly property var networks: root._sortedNetworks(root.wifiDevice)

    // Network waiting for its passphrase (revealed under its row).
    property var pendingConnect: null
    // Network we asked to connect (spinner until state confirms).
    property var connectingNet: null

    function popoverClosed() {
        root.pendingConnect = null;
        root.connectingNet = null;
    }

    function _isWifi(dev) {
        // DeviceType is a module-level enum in Quickshell.Networking
        // (members: None, Wifi, Wired) — stable across 0.3.x.
        return dev.type === DeviceType.Wifi;
    }

    function _findDevice(wantWifi) {
        const devices = Networking.devices ? (Networking.devices.values ?? []) : [];
        return devices.find(d => root._isWifi(d) === wantWifi) ?? null;
    }

    // Connected first, then known, then signal strength descending.
    function _sortedNetworks(dev) {
        const list = dev && dev.networks ? (dev.networks.values ?? []) : [];
        return list.slice().sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.known !== b.known)
                return a.known ? -1 : 1;
            return (b.signalStrength ?? 0) - (a.signalStrength ?? 0);
        });
    }

    // Bars filled from signalStrength (0.0–1.0) percent brackets.
    function _bars(strength) {
        const p = Math.round((strength ?? 0) * 100);
        if (p >= 75)
            return 4;
        if (p >= 50)
            return 3;
        if (p >= 25)
            return 2;
        if (p > 0)
            return 1;
        return 0;
    }

    // WifiSecurityType is an enum, not a bool: anything that is not the
    // explicit open value counts as secured (WpaPsk / Wpa2Psk / Sae …).
    function _isSecure(net) {
        const s = net.security;
        if (s === undefined || s === null)
            return false;
        if (WifiSecurityType.None !== undefined)
            return s !== WifiSecurityType.None;
        return true;
    }

    function _isConnecting(net) {
        if (net.state !== undefined && ConnectionState.Connecting !== undefined)
            return net.state === ConnectionState.Connecting;
        return root.connectingNet === net;
    }

    function _deviceConnecting(dev) {
        if (dev && dev.state !== undefined && ConnectionState.Connecting !== undefined)
            return dev.state === ConnectionState.Connecting;
        return false;
    }

    function _connect(net) {
        root.connectingNet = net;
        net.connect();
    }

    function _submitPsk(field) {
        const net = root.pendingConnect;
        if (!net || field.text === "")
            return;
        net.connectWithPsk(field.text);
        root.pendingConnect = null;
        field.text = "";
    }

    // ── Inline bits ─────────────────────────────────────────────────────
    component SignalBars: Row {
        id: bars

        property real strength: 0

        readonly property int filled: root._bars(strength)

        spacing: 1

        Repeater {
            model: 4

            Rectangle {
                required property int index

                width: 3
                height: 5 + index * 3
                radius: 1
                anchors.bottom: parent.bottom
                color: index < bars.filled ? Theme.fg : Theme.selection
            }
        }
    }

    component PulseDot: Rectangle {
        id: dot

        property bool active: false

        width: 8
        height: 8
        radius: 4
        visible: active
        color: Theme.warning

        SequentialAnimation on opacity {
            running: dot.active
            loops: Animation.Infinite

            NumberAnimation {
                to: 0.25
                duration: Theme.duration.slow
            }
            NumberAnimation {
                to: 1
                duration: Theme.duration.slow
            }
        }
    }

    // ── Wi-Fi section ───────────────────────────────────────────────────
    SectionHeader {
        text: "Network"
    }

    Item {
        width: parent.width
        height: 34

        MenuRow {
            anchors.fill: parent

            icon: Theme.icons.wifi
            label: "Wi-Fi"

            onActivated: Networking.wifiEnabled = !Networking.wifiEnabled
        }

        Toggle {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.sm
            anchors.verticalCenter: parent.verticalCenter

            checked: Networking.wifiEnabled
            onToggled: checked => Networking.wifiEnabled = checked
        }
    }

    MenuRow {
        width: parent.width
        visible: Networking.wifiEnabled

        label: "Refresh"
        readout: refreshCooldown.running ? "…" : ""

        onActivated: {
            if (refreshCooldown.running)
                return;
            // No scan API in Quickshell.Networking — poke nmcli instead.
            Quickshell.execDetached(["nmcli", "d", "wifi", "rescan"]);
            refreshCooldown.restart();
        }

        Timer {
            id: refreshCooldown

            interval: 4000
        }
    }

    ScrollableList {
        width: parent.width
        maxHeight: 240
        visible: Networking.wifiEnabled

        Repeater {
            model: root.networks

            delegate: Column {
                id: netEntry

                required property var modelData

                width: parent.width
                spacing: 2

                MenuRow {
                    width: parent.width

                    icon: root._isSecure(netEntry.modelData) ? Theme.icons.lock : Theme.icons.wifi
                    label: netEntry.modelData.name !== "" ? netEntry.modelData.name : "(hidden network)"
                    selected: netEntry.modelData.connected

                    // Non-interactive trailing visuals are safe inside
                    // the trailing slot (no MouseAreas involved).
                    SignalBars {
                        anchors.verticalCenter: parent.verticalCenter
                        strength: netEntry.modelData.signalStrength
                    }

                    PulseDot {
                        anchors.verticalCenter: parent.verticalCenter
                        active: root._isConnecting(netEntry.modelData)
                    }

                    onActivated: {
                        if (netEntry.modelData.connected) {
                            netEntry.modelData.disconnect();
                            return;
                        }
                        root._connect(netEntry.modelData);
                    }

                    // Saved profile without stored secrets → reveal the
                    // passphrase field below this row. In 0.3.x there is no
                    // NoSecrets signal; connect() emits connectionFailed()
                    // with ConnectionFailReason.NoSecrets instead.
                    Connections {
                        target: netEntry.modelData

                        function onConnectionFailed(reason) {
                            if (reason === ConnectionFailReason.NoSecrets
                                && root.connectingNet === netEntry.modelData)
                                root.pendingConnect = netEntry.modelData;
                        }
                    }
                }

                Row {
                    width: parent.width
                    spacing: Theme.spacing.sm
                    visible: root.pendingConnect === netEntry.modelData

                    TextField {
                        id: pskField

                        width: parent.width - 28 - parent.spacing
                        height: 30

                        echoMode: TextInput.Password
                        font.family: Theme.fonts.mono
                        font.pixelSize: Theme.fonts.size.sm
                        color: Theme.fgBright
                        placeholderText: "Passphrase"
                        selectionColor: Theme.accent
                        verticalAlignment: TextInput.AlignVCenter

                        background: Rectangle {
                            radius: Theme.radius.sm
                            color: Theme.withAlpha(Theme.bg, 0.6)
                            border.width: 1
                            border.color: pskField.activeFocus ? Theme.accent : Theme.hairline
                        }

                        onAccepted: root._submitPsk(pskField)
                    }

                    IconButton {
                        anchors.verticalCenter: parent.verticalCenter

                        icon: Theme.icons.check
                        accent: true

                        onActivated: root._submitPsk(pskField)
                    }
                }
            }
        }
    }

    // ── Wired section ───────────────────────────────────────────────────
    Rectangle {
        width: parent.width
        height: 1
        visible: root.wiredDevice !== null
        color: Theme.hairline
    }

    MenuRow {
        width: parent.width
        visible: root.wiredDevice !== null

        icon: Theme.icons.ethernet
        label: "Wired"
        readout: root.wiredDevice !== null && root.wiredDevice.connected ? "Connected" : "Down"
        selected: root.wiredDevice !== null && root.wiredDevice.connected

        PulseDot {
            anchors.verticalCenter: parent.verticalCenter
            active: root._deviceConnecting(root.wiredDevice)
        }
    }
}
