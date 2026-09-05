// Toasts — bottom-right toast stack for live notifications.
//
// Official standalone layer-shell pattern: a plain PanelWindow (NOT a
// PopupWindow) anchored bottom+right with a negative exclusive zone; no
// WlrLayershell overrides (the Top/None defaults are correct). The
// window is created/destroyed via a Loader as toasts come and go.
//
// The mask keeps the rest of the screen click-through. An empty
// `Region {}` would make even the action buttons click-through, so the
// mask is bound to the card stack instead — identical net effect plus
// working buttons.
//
// Up to 3 toasts, newest first. Each auto-hides at its stored deadline:
// clamp(expireTimeout, 2, 30) seconds, <= 0 → 5s. Deadlines are absolute
// timestamps, so an update only restarts the updated toast's timer.
// The Store drives push()/pop(); its newToast() signal stays available
// for external listeners.

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

import qs
import qs.components

Item {
    id: root

    // Live toasts: { key, notif, critical, deadline }
    property var live: []

    function push(notif) {
        const key = String(notif.id);
        const timeout = notif.expireTimeout;
        const seconds = timeout <= 0 ? 5 : Math.min(30, Math.max(2, timeout));
        root.live = [{
                key: key,
                notif: notif,
                critical: notif.urgency === NotificationUrgency.Critical,
                deadline: Date.now() + seconds * 1000
            }].concat(root.live.filter(t => t.key !== key)).slice(0, 3);
    }

    function pop(key) {
        root.live = root.live.filter(t => t.key !== String(key));
    }

    Loader {
        active: root.live.length > 0
        sourceComponent: toastWindowComponent
    }

    Component {
        id: toastWindowComponent

        PanelWindow {
            id: toastWindow

            anchors {
                bottom: true
                right: true
            }

            margins.bottom: 80
            exclusiveZone: -1
            color: "transparent"

            // Input only over the cards; everything else click-through.
            mask: Region {
                item: stack
            }

            Column {
                id: stack

                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: Theme.spacing.sm

                Repeater {
                    model: root.live

                    delegate: Rectangle {
                        id: card

                        required property var modelData

                        readonly property var notif: modelData.notif
                        readonly property bool critical: modelData.critical

                        width: 340
                        height: cardColumn.implicitHeight + Theme.spacing.md * 2

                        radius: Theme.radius.lg
                        color: Theme.panelBg
                        border.width: 1
                        border.color: card.critical ? Theme.withAlpha(Theme.danger, 0.55) : Theme.hairline

                        // Auto-hide at the stored deadline.
                        Timer {
                            interval: Math.max(500, card.modelData.deadline - Date.now())
                            running: true
                            onTriggered: {
                                try {
                                    card.notif.expire();
                                } catch (e) {
                                    // already gone server-side
                                }
                                root.pop(card.modelData.key);
                            }
                        }

                        Column {
                            id: cardColumn

                            anchors.fill: parent
                            anchors.margins: Theme.spacing.md
                            spacing: Theme.spacing.xs

                            // ── Header: app icon + summary + close ────
                            Item {
                                width: parent.width
                                height: 20

                                Item {
                                    id: toastIcon

                                    readonly property bool ready: card.notif.appIcon !== "" && appImage.status === Image.Ready

                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 18
                                    height: 18

                                    Image {
                                        id: appImage

                                        anchors.fill: parent
                                        visible: toastIcon.ready
                                        source: card.notif.appIcon
                                        sourceSize.width: 18
                                        sourceSize.height: 18
                                        fillMode: Image.PreserveAspectFit
                                        smooth: true
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        visible: !toastIcon.ready
                                        text: card.critical ? Theme.icons.bolt : Theme.icons.bell
                                        font.family: Theme.fonts.mono
                                        font.pixelSize: 13
                                        color: card.critical ? Theme.danger : Theme.fgDark
                                    }
                                }

                                Text {
                                    anchors.left: toastIcon.right
                                    anchors.leftMargin: Theme.spacing.sm
                                    anchors.right: closeButton.left
                                    anchors.rightMargin: Theme.spacing.xs
                                    anchors.verticalCenter: parent.verticalCenter

                                    text: card.notif.summary !== "" ? card.notif.summary : card.notif.appName
                                    elide: Text.ElideRight
                                    font.family: Theme.fonts.sans
                                    font.pixelSize: Theme.fonts.size.md
                                    font.weight: Font.DemiBold
                                    color: card.critical ? Theme.danger : Theme.fgBright
                                }

                                IconButton {
                                    id: closeButton

                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter

                                    icon: Theme.icons.close
                                    iconSize: 12

                                    onActivated: {
                                        try {
                                            card.notif.dismiss();
                                        } catch (e) {
                                            // already gone server-side
                                        }
                                        root.pop(card.modelData.key);
                                    }
                                }
                            }

                            // ── Body ──────────────────────────────────
                            Text {
                                width: parent.width
                                visible: card.notif.body !== ""
                                text: card.notif.body
                                wrapMode: Text.WordWrap
                                elide: Text.ElideRight
                                maximumLineCount: 4
                                font.family: Theme.fonts.sans
                                font.pixelSize: Theme.fonts.size.sm
                                color: Theme.fg
                            }

                            // ── Actions ───────────────────────────────
                            Flow {
                                width: parent.width
                                visible: (card.notif.actions ?? []).length > 0
                                spacing: Theme.spacing.xs

                                Repeater {
                                    model: card.notif.actions ?? []

                                    delegate: Rectangle {
                                        id: actionChip

                                        required property var modelData

                                        width: actionLabel.implicitWidth + Theme.spacing.md * 2
                                        height: 24
                                        radius: Theme.radius.sm
                                        color: actionMouse.containsMouse ? Theme.washStrong : Theme.wash

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: Theme.duration.fast
                                            }
                                        }

                                        Text {
                                            id: actionLabel

                                            anchors.centerIn: parent
                                            text: actionChip.modelData.text !== "" ? actionChip.modelData.text : actionChip.modelData.identifier
                                            elide: Text.ElideRight
                                            font.family: Theme.fonts.sans
                                            font.pixelSize: Theme.fonts.size.sm
                                            color: actionMouse.containsMouse ? Theme.fgBright : Theme.fg
                                        }

                                        MouseArea {
                                            id: actionMouse

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor

                                            onClicked: {
                                                try {
                                                    actionChip.modelData.invoke();
                                                } catch (e) {
                                                    // action vanished
                                                }
                                                try {
                                                    card.notif.dismiss();
                                                } catch (e) {
                                                    // already gone server-side
                                                }
                                                root.pop(card.modelData.key);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
