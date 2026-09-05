// Launcher — PHASE2 app launcher modal.
//
// Live-filtered search over DesktopEntries.applications (already excludes
// NoDisplay/Hidden): name startsWith ranks first, then alphabetical.
// Keyboard-first: type to filter, ↑↓ to move, ↵ to launch, esc to close.

import QtQuick
import Quickshell
import Quickshell.Widgets

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 560

    // ── State ───────────────────────────────────────────────────────────
    property string _query: ""
    property var _results: []
    property int _sel: 0

    onOpened: {
        searchInput.text = "";
        root._query = "";
        root._sel = 0;
        listWrap._y = 0;
        root._refresh();
        searchInput.forceActiveFocus();
    }

    // ── Filtering ───────────────────────────────────────────────────────
    function _refresh() {
        const q = root._query;
        const entries = DesktopEntries.applications.values;

        if (q === "") {
            // Empty search shows all apps, alphabetical.
            root._results = entries.slice().sort((a, b) =>
                a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
            return;
        }

        const matches = entries.filter(entry => {
            const fields = [entry.name, entry.genericName, entry.comment,
                            (entry.keywords || []).join(" ")];
            return fields
                .filter(f => typeof f === "string" && f.length > 0)
                .join(" ")
                .toLowerCase()
                .includes(q);
        });

        // Name-startsWith query first, then alphabetical.
        matches.sort((a, b) => {
            const an = a.name.toLowerCase();
            const bn = b.name.toLowerCase();
            const at = an.startsWith(q) ? 0 : 1;
            const bt = bn.startsWith(q) ? 0 : 1;
            if (at !== bt)
                return at - bt;
            return an.localeCompare(bn);
        });

        root._results = matches;
    }

    function _move(delta) {
        const n = root._results.length;
        if (n === 0)
            return;
        root._sel = (root._sel + delta + n) % n;
        listWrap._reveal(root._sel);
    }

    function _activate(i) {
        const entry = root._results[i];
        if (entry) {
            entry.execute();
            root.closeWindow();
        }
    }

    // ── Search ──────────────────────────────────────────────────────────
    Rectangle {
        id: searchBox

        width: parent.width
        height: 34
        radius: Theme.radius.sm
        color: Theme.selection

        TextInput {
            id: searchInput

            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            verticalAlignment: TextInput.AlignVCenter

            color: Theme.fgBright
            selectionColor: Theme.withAlpha(Theme.accent, 0.35)
            selectedTextColor: Theme.fgBright
            font.family: Theme.fonts.sans
            font.pixelSize: Theme.fonts.size.md
            clip: true

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: searchInput.text === ""
                text: "Search applications…"
                font.family: Theme.fonts.sans
                font.pixelSize: Theme.fonts.size.md
                color: Theme.comment
            }

            onTextChanged: {
                root._query = text.toLowerCase();
                root._sel = 0;
                listWrap._y = 0;
                root._refresh();
            }

            Keys.onUpPressed: root._move(-1)
            Keys.onDownPressed: root._move(1)
            Keys.onReturnPressed: root._activate(root._sel)
            Keys.onEnterPressed: root._activate(root._sel)
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Results ─────────────────────────────────────────────────────────
    // Local scroll (ScrollableList pattern) so keyboard selection can
    // programmatically reveal rows.
    Item {
        id: listWrap

        width: parent.width
        height: 420
        clip: true

        property real _y: 0

        Behavior on _y {
            NumberAnimation {
                duration: Theme.duration.instant
                easing.type: Theme.easing
            }
        }

        function _scroll(dy) {
            const total = Math.max(0, root._results.length * 46 - 2);
            listWrap._y = Math.min(Math.max(0, total - height), Math.max(0, listWrap._y + dy));
        }

        function _reveal(i) {
            const top = i * 46;
            const bottom = top + 44;
            if (top < listWrap._y)
                listWrap._y = top;
            else if (bottom > listWrap._y + height)
                listWrap._y = bottom - height;
        }

        Column {
            id: listColumn

            y: -listWrap._y
            width: parent.width
            spacing: 2

            Repeater {
                model: root._results

                delegate: Rectangle {
                    id: row

                    required property var modelData

                    width: parent.width
                    height: 44
                    radius: Theme.radius.sm

                    readonly property bool active: root._sel === index

                    color: {
                        if (row.active)
                            return Theme.washStrong;
                        if (mouse.containsMouse)
                            return Theme.wash;
                        return "transparent";
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.duration.fast
                        }
                    }

                    Item {
                        id: iconWrap

                        width: 24
                        height: 24
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter

                        // Glyph placeholder — covered when the themed icon resolves.
                        Text {
                            anchors.centerIn: parent
                            text: Theme.icons.chevronRight
                            font.family: Theme.fonts.mono
                            font.pixelSize: 12
                            color: Theme.comment
                        }

                        IconImage {
                            id: appIcon

                            // Covers the glyph placeholder only once the
                            // theme icon has actually resolved.
                            readonly property bool ready: status === Image.Ready

                            anchors.fill: parent
                            visible: appIcon.ready
                            source: Theme.iconSource(row.modelData.icon)
                        }
                    }

                    Text {
                        anchors.left: iconWrap.right
                        anchors.leftMargin: Theme.spacing.md
                        anchors.right: commentText.left
                        anchors.rightMargin: Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter

                        text: row.modelData.name
                        elide: Text.ElideRight
                        font.family: Theme.fonts.sans
                        font.pixelSize: Theme.fonts.size.md
                        color: row.active || mouse.containsMouse ? Theme.fgBright : Theme.fg

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.duration.fast
                            }
                        }
                    }

                    Text {
                        id: commentText

                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.min(implicitWidth, parent.width * 0.45)

                        text: row.modelData.comment
                        elide: Text.ElideRight
                        font.family: Theme.fonts.sans
                        font.pixelSize: Theme.fonts.size.sm
                        color: Theme.fgDark
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._activate(index)
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: root._results.length === 0
            text: "No applications found"
            font.family: Theme.fonts.sans
            font.pixelSize: Theme.fonts.size.sm
            color: Theme.fgDark
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => listWrap._scroll(wheel.angleDelta.y > 0 ? -44 : 44)
        }
    }

    // Footer key hints removed by user request (2026-09).
}
