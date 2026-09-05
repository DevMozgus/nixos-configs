// BluetoothPopover — adapter + device control (Quickshell.Bluetooth).
//
// Adapter toggle + state caption; device list sorted connected →
// paired → name. Clicking a device toggles its connection; unpaired
// devices get a pair button (pair() + trusted = true); paired devices
// get a two-step armed "forget" (MenuRow armedLabel pattern). The
// per-device controls sit as overlay siblings because MenuRow's
// internal MouseArea would swallow clicks in its trailing slot — the
// row reserves matching room there instead.
//
// quickshell exposes NO scan-start API (adapter.discovering is
// read-only) — the "Scan" row shells out to bluetoothctl and switches
// scanning back off after 10s.

import QtQuick
import Quickshell
import Quickshell.Bluetooth

import qs
import qs.components

Popover {
    id: root

    popWidth: 300

    // ── Data ────────────────────────────────────────────────────────────
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: root._sortedDevices()

    property string armedForget: ""   // address of the device pending forget

    function popoverClosed() {
        root.armedForget = "";
    }

    Timer {
        id: disarmTimer

        interval: 4000
        onTriggered: root.armedForget = ""
    }

    Timer {
        id: scanOffTimer

        interval: 10000
        onTriggered: Quickshell.execDetached(["bluetoothctl", "scan", "off"])
    }

    Timer {
        id: scanCooldown

        interval: 12000
    }

    function _scan() {
        if (scanCooldown.running)
            return;
        // No scan-start API on the adapter (discovering is read-only).
        Quickshell.execDetached(["bluetoothctl", "scan", "on"]);
        scanOffTimer.restart();
        scanCooldown.restart();
    }

    function _name(d) {
        // name is rw and may be "" → fall back to the remote device name.
        return d.name && d.name !== "" ? d.name : String(d.deviceName ?? "Unknown device");
    }

    // Connected first, then paired, then by name.
    function _sortedDevices() {
        const list = root.adapter && root.adapter.devices ? (root.adapter.devices.values ?? []) : [];
        return list.slice().sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;
            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;
            return root._name(a).localeCompare(root._name(b));
        });
    }

    function _stateCaption() {
        const a = root.adapter;
        if (!a)
            return "No adapter";
        // Defensive: BluetoothAdapterState members have varied; fall
        // back to the enabled flag.
        if (BluetoothAdapterState.Enabling !== undefined) {
            switch (a.state) {
            case BluetoothAdapterState.Blocked:
                return "Blocked";
            case BluetoothAdapterState.Enabled:
                return "Enabled";
            case BluetoothAdapterState.Disabled:
                return "Disabled";
            case BluetoothAdapterState.Enabling:
                return "Enabling…";
            case BluetoothAdapterState.Disabling:
                return "Disabling…";
            }
        }
        return a.enabled ? "Enabled" : "Disabled";
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

    // ── Adapter section ─────────────────────────────────────────────────
    Item {
        width: parent.width
        height: 34
        visible: root.adapter !== null

        MenuRow {
            anchors.fill: parent

            icon: Theme.icons.bluetooth
            label: "Bluetooth"

            onActivated: {
                if (root.adapter)
                    root.adapter.enabled = !root.adapter.enabled;
            }
        }

        Toggle {
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.sm
            anchors.verticalCenter: parent.verticalCenter

            checked: root.adapter !== null && root.adapter.enabled
            onToggled: checked => {
                if (root.adapter)
                    root.adapter.enabled = checked;
            }
        }
    }

    MenuRow {
        width: parent.width
        visible: root.adapter === null

        icon: Theme.icons.bluetooth
        label: "No Bluetooth adapter"

        onActivated: root.dismiss()
    }

    Text {
        width: parent.width
        visible: root.adapter !== null

        text: root._stateCaption()
        font.family: Theme.fonts.sans
        font.pixelSize: Theme.fonts.size.xs
        color: Theme.fgDark
    }

    MenuRow {
        width: parent.width
        visible: root.adapter !== null

        label: "Scan"
        readout: root.adapter !== null && root.adapter.discovering ? "scanning…" : (scanCooldown.running ? "…" : "")

        onActivated: root._scan()
    }

    // ── Devices ─────────────────────────────────────────────────────────
    SectionHeader {
        text: "Devices"
        visible: root.devices.length > 0
    }

    ScrollableList {
        width: parent.width
        maxHeight: 240
        visible: root.devices.length > 0

        Repeater {
            model: root.devices

            delegate: Item {
                id: devEntry

                required property var modelData

                readonly property bool forgetArmed: root.armedForget === modelData.address

                width: parent.width
                height: 34

                MenuRow {
                    anchors.fill: parent

                    icon: Theme.icons.bluetooth
                    label: root._name(devEntry.modelData)
                    readout: devEntry.modelData.connected && devEntry.modelData.batteryAvailable ? Math.round(devEntry.modelData.battery * 100) + "%" : ""
                    selected: devEntry.modelData.connected
                    danger: devEntry.forgetArmed
                    armed: devEntry.forgetArmed
                    armedLabel: "Forget this device?"

                    // Reserve room for the overlay controls on the right
                    // (label elides ahead of them).
                    Item {
                        implicitWidth: 92
                        implicitHeight: 28
                    }

                    onActivated: {
                        if (devEntry.forgetArmed) {
                            root.armedForget = "";
                            return;
                        }
                        if (devEntry.modelData.connected)
                            devEntry.modelData.disconnect();
                        else
                            devEntry.modelData.connect();
                    }

                    // Paired devices are trusted so they reconnect
                    // without a pairing prompt next time.
                    Connections {
                        target: devEntry.modelData

                        function onPairedChanged() {
                            if (devEntry.modelData.paired && !devEntry.modelData.trusted)
                                devEntry.modelData.trusted = true;
                        }
                    }
                }

                // Overlay controls (siblings on top of the row).
                Row {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xs

                    Rectangle {
                        visible: devEntry.modelData.connected

                        width: 8
                        height: 8
                        radius: 4
                        anchors.verticalCenter: parent.verticalCenter
                        color: Theme.success
                    }

                    PulseDot {
                        anchors.verticalCenter: parent.verticalCenter
                        active: devEntry.modelData.pairing
                    }

                    IconButton {
                        visible: !devEntry.modelData.paired
                        anchors.verticalCenter: parent.verticalCenter

                        icon: Theme.icons.bolt
                        accent: true

                        onActivated: {
                            devEntry.modelData.pair();
                            devEntry.modelData.trusted = true;
                        }
                    }

                    IconButton {
                        visible: devEntry.modelData.paired
                        anchors.verticalCenter: parent.verticalCenter

                        icon: Theme.icons.close
                        danger: true

                        onActivated: {
                            if (root.armedForget !== devEntry.modelData.address) {
                                root.armedForget = devEntry.modelData.address;
                                disarmTimer.restart();
                                return;
                            }
                            devEntry.modelData.forget();
                            root.armedForget = "";
                        }
                    }
                }
            }
        }
    }

    Text {
        width: parent.width
        visible: root.adapter !== null && root.devices.length === 0

        text: "No devices"
        font.family: Theme.fonts.sans
        font.pixelSize: Theme.fonts.size.sm
        color: Theme.comment
    }
}
