// ClockPopover — month calendar built on pure JS Date.
//
// Reopens on the current month every time it is shown; today gets the
// accent circle; adjacent-month days are dimmed; chevrons navigate.

import QtQuick

import qs
import qs.components

Popover {
    id: root

    popWidth: 252

    property var today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth() // 0-based

    function popoverOpened() {
        root.today = new Date();
        root.viewYear = root.today.getFullYear();
        root.viewMonth = root.today.getMonth();
    }

    // First cell of the grid: the Sunday on/before the 1st of the month.
    readonly property date viewFirst: new Date(viewYear, viewMonth, 1)
    readonly property date gridStart: {
        const d = new Date(root.viewYear, root.viewMonth, 1);
        d.setDate(d.getDate() - d.getDay());
        return d;
    }
    readonly property string monthTitle: Qt.formatDateTime(viewFirst, "MMMM yyyy")

    function _go(delta) {
        const d = new Date(root.viewYear, root.viewMonth + delta, 1);
        root.viewYear = d.getFullYear();
        root.viewMonth = d.getMonth();
    }

    function _isToday(d) {
        return d.getFullYear() === root.today.getFullYear()
                && d.getMonth() === root.today.getMonth()
                && d.getDate() === root.today.getDate();
    }

    function _inMonth(d) {
        return d.getMonth() === root.viewMonth;
    }

    // ── Header ──────────────────────────────────────────────────────────
    Item {
        width: parent.width
        height: 28

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: root.monthTitle
            font.family: Theme.fonts.sans
            font.pixelSize: Theme.fonts.size.md
            font.weight: Font.DemiBold
            color: Theme.fgBright
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.spacing.xs

            IconButton {
                icon: Theme.icons.chevronLeft
                iconSize: 12
                onActivated: root._go(-1)
            }

            IconButton {
                icon: Theme.icons.chevronRight
                iconSize: 12
                onActivated: root._go(1)
            }
        }
    }

    // ── Weekday header (en_US: Sunday first) ────────────────────────────
    Row {
        id: weekRow

        width: parent.width
        spacing: 0

        Repeater {
            model: ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]

            delegate: Text {
                required property var modelData

                width: weekRow.width / 7
                horizontalAlignment: Text.AlignHCenter
                text: modelData
                font.family: Theme.fonts.sans
                font.pixelSize: 9
                font.weight: Font.DemiBold
                color: Theme.comment
            }
        }
    }

    // ── Day grid (6 weeks) ──────────────────────────────────────────────
    Item {
        id: grid

        width: parent.width
        height: 6 * 26

        Repeater {
            model: 42

            delegate: Item {
                id: cell

                required property int index

                width: grid.width / 7
                height: 26
                x: (cell.index % 7) * grid.width / 7
                y: Math.floor(cell.index / 7) * 26

                readonly property date day: {
                    const d = new Date(root.gridStart);
                    d.setDate(d.getDate() + cell.index);
                    return d;
                }
                readonly property bool isToday: root._isToday(day)
                readonly property bool inMonth: root._inMonth(day)

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: Theme.radius.pill
                    color: cell.isToday ? Theme.accent : (dayMouse.containsMouse ? Theme.wash : "transparent")

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.duration.fast
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: cell.day.getDate()
                    font.family: Theme.fonts.mono
                    font.pixelSize: Theme.fonts.size.sm
                    font.weight: cell.isToday ? Font.Bold : Font.Medium
                    color: {
                        if (cell.isToday)
                            return Theme.bg;
                        if (!cell.inMonth)
                            return Theme.comment;
                        return dayMouse.containsMouse ? Theme.fgBright : Theme.fg;
                    }
                }

                MouseArea {
                    id: dayMouse

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
