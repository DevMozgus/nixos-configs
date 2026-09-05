// PowerMenu — FULLY FUNCTIONAL exemplar.
//
// Lock / Logout / Suspend fire immediately; Reboot / Shutdown are
// destructive and use two-step confirmation: the first click arms the row
// (danger wash + confirm label), the second click within 4s fires. Arming
// clears on dismiss, on firing, and when another row is armed.

import QtQuick
import Quickshell

import qs
import qs.components

Popover {
    id: root

    popWidth: 240

    property string armedAction: ""

    function popoverClosed() {
        root.armedAction = "";
    }

    Timer {
        id: disarmTimer

        interval: 4000
        onTriggered: root.armedAction = ""
    }

    function _arm(action) {
        root.armedAction = action;
        disarmTimer.restart();
    }

    function _run(command) {
        root.armedAction = "";
        Quickshell.execDetached(command);
        root.dismiss();
    }

    function _activate(action, command, destructive) {
        if (destructive && root.armedAction !== action) {
            root._arm(action);
            return;
        }
        root._run(command);
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.lock
        label: "Lock"
        onActivated: root._activate("lock", ["hyprlock"], false)
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.logout
        label: "Logout"
        onActivated: root._activate("logout", ["hyprctl", "dispatch", "exit"], false)
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.moon
        label: "Suspend"
        onActivated: root._activate("suspend", ["systemctl", "suspend"], false)
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.reboot
        label: "Reboot"
        danger: true
        armed: root.armedAction === "reboot"
        armedLabel: "Click to confirm"
        onActivated: root._activate("reboot", ["systemctl", "reboot"], true)
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.power
        label: "Shutdown"
        danger: true
        armed: root.armedAction === "shutdown"
        armedLabel: "Click to confirm"
        onActivated: root._activate("shutdown", ["systemctl", "poweroff"], true)
    }
}
