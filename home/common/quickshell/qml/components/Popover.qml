// Popover — the ONE popup frame shared by every popover in the shell.
//
// Anchors below the owning bar widget, flips when out of room, closes on
// outside click (grabFocus). Subclasses set `popWidth` and declare their
// content as direct children (routed into the padded content column).

import QtQuick
import Quickshell

import qs

PopupWindow {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    // Subclass content lands here.
    default property alias contentData: contentColumn.data
    property alias contentSpacing: contentColumn.spacing

    // Frame width; height follows content.
    property int popWidth: 280
    property int popPadding: Theme.spacing.md

    // The bar widget this popover is anchored to (set via toggleFor).
    property Item owner: null

    // Subclass hooks — override in the derived file.
    function popoverOpened() {}
    function popoverClosed() {}

    // Open anchored to `item`, or close if already open for it.
    function toggleFor(item) {
        if (root.visible && root.owner === item) {
            root.visible = false;
            return;
        }
        root.owner = item;
        root.visible = true;
    }

    function dismiss() {
        root.visible = false;
    }

    // ── Window setup ────────────────────────────────────────────────────
    color: "transparent"
    implicitWidth: root.popWidth
    implicitHeight: frame.height
    grabFocus: true

    anchor {
        item: root.owner
        edges: Edges.Bottom
        gravity: Edges.Bottom | Edges.Right
        adjustment: PopupAdjustment.Flip
        margins.top: 6
    }

    onVisibleChanged: {
        if (visible) {
            root.popoverOpened();
            frame.opacity = 0;
            frame.scale = 0.97;
            popIn.restart();
        } else {
            root.popoverClosed();
        }
    }

    SequentialAnimation {
        id: popIn

        ParallelAnimation {
            NumberAnimation {
                target: frame
                property: "opacity"
                to: 1
                duration: Theme.duration.normal
                easing.type: Theme.easing
            }
            NumberAnimation {
                target: frame
                property: "scale"
                to: 1
                duration: Theme.duration.normal
                easing.type: Theme.easing
            }
        }
    }

    // ── Frame ───────────────────────────────────────────────────────────
    Rectangle {
        id: frame

        width: root.popWidth
        height: contentColumn.implicitHeight + root.popPadding * 2

        radius: Theme.radius.md
        color: Theme.panelBg
        border.width: 1
        border.color: Theme.hairline

        opacity: 0
        transformOrigin: Item.Top

        focus: true
        Keys.onEscapePressed: root.dismiss()

        Column {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: root.popPadding
            spacing: Theme.spacing.sm
        }
    }
}
