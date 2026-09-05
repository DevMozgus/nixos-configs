// NotificationCenter — centered modal over the notification history.
//
// Built on ModalWindow (dim scrim + centered card, Esc/scrim close).
// The header carries the DND toggle; a danger-armed "Clear all" wipes
// the history; rows show app / summary / body with time-ago mono
// readouts and a close button. Rows whose notification is still live
// invoke their default action on click; entries restored from the
// state file can only be dismissed (the server-side object is gone).

import QtQuick

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 440

    // ── State ───────────────────────────────────────────────────────────
    property bool armedClear: false

    // Ticks the time-ago readouts while the center is open.
    property var now: new Date()

    Timer {
        id: disarmTimer

        interval: 4000
        onTriggered: root.armedClear = false
    }

    Timer {
        running: root.visible
        interval: 30000
        repeat: true
        onTriggered: root.now = new Date()
    }

    onOpened: {
        Store.markRead();
        root.armedClear = false;
    }

    // ── Helpers ─────────────────────────────────────────────────────────
    function _elapsed(ms) {
        const seconds = Math.max(0, Math.floor((root.now.getTime() - ms) / 1000));
        if (seconds < 60)
            return "now";
        const minutes = Math.floor(seconds / 60);
        if (minutes < 60)
            return minutes + "m";
        const hours = Math.floor(minutes / 60);
        if (hours < 24)
            return hours + "h";
        return Math.floor(hours / 24) + "d";
    }

    // Extra (non-default) actions that are still invokable — entries
    // restored from disk carry no live object and get no buttons.
    function _extraActions(record) {
        const live = Store._liveActions(record);
        if (live.length === 0)
            return [];
        return (record.actions ?? []).filter(a => a && a.identifier !== "default" && live.some(x => x.identifier === a.identifier));
    }

    function _invokeDefaultAndDismiss(record) {
        Store._invokeAction(record, "default");
        Store.dismiss(record.key);
    }

    // ── Header: title + DND toggle ──────────────────────────────────────
    Item {
        width: parent.width
        height: 28

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            text: "Notifications"
            font.family: Theme.fonts.sans
            font.pixelSize: Theme.fonts.size.lg
            font.weight: Font.DemiBold
            color: Theme.fgBright
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.sm

            Text {
                anchors.verticalCenter: parent.verticalCenter

                text: Store.dnd ? Theme.icons.bellSlash : Theme.icons.bell
                font.family: Theme.fonts.mono
                font.pixelSize: 14
                color: Store.dnd ? Theme.comment : Theme.accent

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.duration.fast
                    }
                }
            }

            Toggle {
                anchors.verticalCenter: parent.verticalCenter
                checked: Store.dnd
                onToggled: checked => Store.dnd = checked
            }
        }
    }

    // ── Clear all (two-step destructive) ────────────────────────────────
    MenuRow {
        width: parent.width
        visible: Store.history.length > 0

        icon: Theme.icons.close
        label: "Clear all"
        danger: true
        armed: root.armedClear
        armedLabel: "Click to confirm"

        onActivated: {
            if (!root.armedClear) {
                root.armedClear = true;
                disarmTimer.restart();
                return;
            }
            Store.clearAll();
            root.armedClear = false;
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        visible: Store.history.length > 0
        color: Theme.hairline
    }

    // ── History ─────────────────────────────────────────────────────────
    ScrollableList {
        width: parent.width
        maxHeight: 420
        visible: Store.history.length > 0

        Repeater {
            model: Store.history

            delegate: Rectangle {
                id: entry

                required property var modelData

                width: parent.width
                height: entryColumn.implicitHeight + Theme.spacing.sm * 2
                radius: Theme.radius.sm
                color: entryMouse.containsMouse ? Theme.wash : "transparent"

                Behavior on color {
                    ColorAnimation {
                        duration: Theme.duration.fast
                    }
                }

                // Declared before the content column so the close button
                // and action chips sit on top of the click-to-activate
                // area.
                MouseArea {
                    id: entryMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root._invokeDefaultAndDismiss(entry.modelData)
                }

                Column {
                    id: entryColumn

                    anchors.fill: parent
                    anchors.margins: Theme.spacing.sm
                    spacing: 2

                    Item {
                        width: parent.width
                        height: 20

                        Text {
                            anchors.left: parent.left
                            anchors.right: entryTime.left
                            anchors.rightMargin: Theme.spacing.sm
                            anchors.verticalCenter: parent.verticalCenter

                            text: entry.modelData.appName
                            elide: Text.ElideRight
                            font.family: Theme.fonts.sans
                            font.pixelSize: Theme.fonts.size.xs
                            color: Theme.fgDark
                        }

                        Text {
                            id: entryTime

                            anchors.right: entryClose.left
                            anchors.rightMargin: Theme.spacing.xs
                            anchors.verticalCenter: parent.verticalCenter

                            text: root._elapsed(entry.modelData.time)
                            font.family: Theme.fonts.mono
                            font.pixelSize: Theme.fonts.size.xs
                            color: Theme.fgDark
                        }

                        IconButton {
                            id: entryClose

                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter

                            implicitWidth: 20
                            implicitHeight: 20
                            icon: Theme.icons.close
                            iconSize: 10

                            onActivated: Store.dismiss(entry.modelData.key)
                        }
                    }

                    Text {
                        width: parent.width
                        visible: entry.modelData.summary !== ""
                        text: entry.modelData.summary
                        elide: Text.ElideRight
                        font.family: Theme.fonts.sans
                        font.pixelSize: Theme.fonts.size.md
                        font.weight: Font.DemiBold
                        color: Theme.fgBright
                    }

                    Text {
                        width: parent.width
                        visible: entry.modelData.body !== ""
                        text: entry.modelData.body
                        elide: Text.ElideRight
                        maximumLineCount: 2
                        wrapMode: Text.WordWrap
                        font.family: Theme.fonts.sans
                        font.pixelSize: Theme.fonts.size.sm
                        color: Theme.fg
                    }

                    // Extra action buttons (live notifications only).
                    Flow {
                        width: parent.width
                        visible: root._extraActions(entry.modelData).length > 0
                        spacing: Theme.spacing.xs

                        Repeater {
                            model: root._extraActions(entry.modelData)

                            delegate: Rectangle {
                                id: entryChip

                                required property var modelData

                                width: entryChipLabel.implicitWidth + Theme.spacing.sm * 2
                                height: 22
                                radius: Theme.radius.sm
                                color: entryChipMouse.containsMouse ? Theme.washStrong : Theme.wash

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.duration.fast
                                    }
                                }

                                Text {
                                    id: entryChipLabel

                                    anchors.centerIn: parent
                                    text: entryChip.modelData.text
                                    elide: Text.ElideRight
                                    font.family: Theme.fonts.sans
                                    font.pixelSize: Theme.fonts.size.sm
                                    color: entryChipMouse.containsMouse ? Theme.fgBright : Theme.fg
                                }

                                MouseArea {
                                    id: entryChipMouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Store._invokeAction(entry.modelData, entryChip.modelData.identifier);
                                        Store.dismiss(entry.modelData.key);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Empty state ─────────────────────────────────────────────────────
    Text {
        visible: Store.history.length === 0
        text: "No notifications"
        font.family: Theme.fonts.sans
        font.pixelSize: Theme.fonts.size.sm
        color: Theme.comment
    }
}
