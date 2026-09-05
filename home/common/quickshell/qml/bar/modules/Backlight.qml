// Backlight — laptop-only brightness pill, wired to brightnessctl.
//
// Reads the level via `brightnessctl -m -c backlight` (machine format
// "device,current,max,percent"). Wheel anywhere on the pill steps ±5%
// (same delta as the XF86MonBrightness binds); click opens
// BacklightPopover with a slider.
//
// Note: reading /sys/class/backlight through a FileView was skipped on
// purpose — the device directory is a wildcard path (e.g.
// intel_backlight) that FileView cannot resolve; brightnessctl resolves
// the device for us.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    visible: Theme.isLaptop

    // Current level, 0..100 (optimistic on wheel; corrected by re-read).
    property int percent: 0
    readonly property real level: root.percent / 100

    contentSpacing: 6

    checked: backlightPopover.visible

    Component.onCompleted: if (Theme.isLaptop) root.refresh()

    function refresh() {
        readProcess.exec();
    }

    function _parse(output) {
        const line = output.trim().split("\n")[0] ?? "";
        const cols = line.split(",");
        // Machine format: device,current,max,percent (percent carries "%").
        const parsed = parseInt(cols[3]);
        if (!isNaN(parsed))
            root.percent = Math.max(0, Math.min(100, parsed));
    }

    function _set(pct) {
        const clamped = Math.max(0, Math.min(100, pct));
        root.percent = clamped;
        Quickshell.execDetached(["brightnessctl", "set", clamped + "%"]);
        // The write runs detached — re-read shortly after so the pill and
        // the popover slider converge on the real value.
        writeRefresh.restart();
    }

    Process {
        id: readProcess

        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    Timer {
        id: writeRefresh

        interval: 250
        onTriggered: root.refresh()
    }

    // Wheel scrub over the whole pill. The area lives in the content row,
    // so it anchors to the grandparent (the pill itself) — anchored items
    // are skipped by the Row layout. NoButton keeps clicks falling through
    // to the BarWidget mouse area; wheels propagate down to this area
    // because BarWidget's own MouseArea has no onWheel handler.
    MouseArea {
        anchors.fill: parent.parent
        acceptedButtons: Qt.NoButton

        onWheel: wheel => root._set(root.percent + (wheel.angleDelta.y > 0 ? 5 : -5))
    }

    onClicked: {
        if (root.hub)
            root.hub.openPopover(backlightPopover, root);
        else
            backlightPopover.toggleFor(root);
    }

    BacklightPopover {
        id: backlightPopover
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Theme.icons.sun
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.contentColor
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.level * 100) + "%"
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: root.contentColor
    }
}
