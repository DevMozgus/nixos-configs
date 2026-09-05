// BacklightPopover — brightness slider for the laptop backlight.
//
// Slider 0..1 backed by the owning Backlight module (owner.percent —
// anchored and refreshed on open). Writes go through brightnessctl, the
// same command the XF86MonBrightness binds use, and are debounced: a
// drag fires one execDetached per 200ms and asks the module to re-read
// after each write. An optimistic value keeps the knob from snapping
// back while the read-back is in flight (mirrors AudioPopover's
// pending-id pattern).

import QtQuick
import Quickshell

import qs
import qs.components

Popover {
    id: root

    popWidth: 260

    // Last value written but not yet confirmed by the module's read-back.
    property real pendingPercent: -1
    readonly property real displayPercent: root.pendingPercent >= 0 ? root.pendingPercent : (root.owner && root.owner.percent !== undefined ? root.owner.percent : 0)

    function popoverOpened() {
        if (root.owner && root.owner.refresh)
            root.owner.refresh();
    }

    function _apply(value) {
        root.pendingPercent = Math.max(0, Math.min(100, Math.round(value * 100)));
        pendingReset.restart();
        applyDebounce.restart();
    }

    // Collapse a drag into one write per interval.
    Timer {
        id: applyDebounce

        interval: 200
        onTriggered: {
            Quickshell.execDetached(["brightnessctl", "set", Math.round(root.displayPercent) + "%"]);
            if (root.owner && root.owner.refresh)
                root.owner.refresh();
        }
    }

    // Drop the optimistic value once the read-back had time to land.
    Timer {
        id: pendingReset

        interval: 800
        onTriggered: root.pendingPercent = -1
    }

    SectionHeader {
        text: "Brightness"
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            text: Theme.icons.sun
            font.family: Theme.fonts.mono
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            color: Theme.fg
        }

        Slider {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 20 - 46 - parent.spacing * 2
            value: root.displayPercent / 100
            step: 0.05

            onMoved: value => root._apply(value)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 46
            text: Math.round(root.displayPercent) + "%"
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.sm
            color: Theme.fg
            horizontalAlignment: Text.AlignRight
        }
    }
}
