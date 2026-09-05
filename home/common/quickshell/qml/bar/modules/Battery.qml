// Battery — laptop battery pill, live from Quickshell.Services.UPower.
//
// Icon by level bracket; a bolt in success green while charging, danger
// tint when low while discharging. Readout shows the percent while
// charging, otherwise the runtime estimate ("1h37") when the device
// reports one. Hidden on desktops and until the display device is ready.

import QtQuick
import Quickshell.Services.UPower

import qs
import qs.components

BarWidget {
    id: root

    property var hub: null

    // ── Data (UPower display device; guard until ready) ─────────────────
    readonly property var device: UPower.displayDevice
    readonly property bool present: root.device ? root.device.ready : false

    readonly property real percentage: root.present ? root.device.percentage * 100 : 0
    readonly property bool charging: root.present && root.device.state === UPowerDeviceState.Charging
    readonly property bool discharging: root.present && root.device.state === UPowerDeviceState.Discharging
    readonly property int timeToEmpty: root.present ? root.device.timeToEmpty : 0

    visible: Theme.isLaptop && root.present

    readonly property bool low: root.discharging && root.percentage < 20

    readonly property string batteryIcon: {
        if (root.charging)
            return Theme.icons.bolt;
        if (root.percentage >= 87.5)
            return Theme.icons.batteryFull;
        if (root.percentage >= 62.5)
            return Theme.icons.batteryThreeQuarters;
        if (root.percentage >= 37.5)
            return Theme.icons.batteryHalf;
        if (root.percentage >= 12.5)
            return Theme.icons.batteryQuarter;
        return Theme.icons.batteryEmpty;
    }

    // Seconds → "1h37"; minutes only under a full hour.
    function _formatRemaining(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        return h > 0 ? h + "h" + m : m + "m";
    }

    readonly property string readout: root.discharging && root.timeToEmpty > 0 ? root._formatRemaining(root.timeToEmpty) : Math.round(root.percentage) + "%"

    // Phase2 seam: battery popover (percentage, health, power profiles).
    // Non-interactive until that popover exists.
    interactive: false

    contentSpacing: 6

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.batteryIcon
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.charging ? Theme.success : (root.low ? Theme.danger : root.contentColor)

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.readout
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: root.charging ? Theme.success : (root.low ? Theme.danger : root.contentColor)

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }
}
