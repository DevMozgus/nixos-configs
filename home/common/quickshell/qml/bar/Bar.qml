// Bar — full-width classic top bar.
//
//   [left]   Workspaces · Layout · Recording indicator
//   [center] Clock
//   [right]  Battery Backlight (laptop only) · Audio Network Bluetooth
//            Notifications Tray Power
//
// Also the popover exclusivity hub: modules hand their popover to
// openPopover() so only one is on screen at a time.

import QtQuick
import Quickshell

import qs

import "modules"

PanelWindow {
    id: root

    required property var modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.barHeight
    exclusiveZone: Theme.barHeight
    color: "transparent"

    // ── Popover hub ─────────────────────────────────────────────────────
    property var activePopover: null

    function openPopover(popover, owner) {
        if (root.activePopover !== null && root.activePopover !== popover)
            root.activePopover.visible = false;

        popover.toggleFor(owner);
        root.activePopover = popover.visible ? popover : null;
    }

    // IPC entry point (qs -c mdo ipc call power open).
    function openPowerMenu() {
        root.openPopover(powerModule.menu, powerModule);
    }

    // ── Background + hairline ───────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Theme.barBg

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            height: 1
            color: Theme.hairline
        }
    }

    // ── Left cluster ────────────────────────────────────────────────────
    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.xs

        Workspaces {
            hub: root
        }

        Layout {
            hub: root
        }

        Recording {
            hub: root
        }
    }

    // ── Center cluster ──────────────────────────────────────────────────
    Clock {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        hub: root
    }

    // ── Right cluster ───────────────────────────────────────────────────
    Row {
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.xs

        Battery {
            hub: root
        }

        Backlight {
            hub: root
        }

        Audio {
            hub: root
        }

        Network {
            hub: root
        }

        Bluetooth {
            hub: root
        }

        Notifications {
            hub: root
        }

        Tray {
            hub: root
        }

        Power {
            id: powerModule
            hub: root
        }
    }
}
