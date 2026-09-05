// EmojiPicker — PHASE2 emoji picker modal.
//
// Category sections + glyph grid over qml/data/emojis.json; search
// filters by name across all categories. Picking copies via wl-copy,
// flashes the cell, updates the persisted recents list and auto-closes.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 480

    // ── Data ────────────────────────────────────────────────────────────
    FileView {
        id: emojiFile

        path: Qt.resolvedUrl("../data/emojis.json")
        blockLoading: true
        watchChanges: false
    }

    // Recents persisted as a JSON array of glyphs in the shell state dir.
    FileView {
        id: recentsFile

        path: Quickshell.statePath("mdo-emoji-recents.json")
        blockLoading: true
        printErrors: false
        watchChanges: false
    }

    readonly property var _cats: ["smileys", "gestures", "people", "animals", "food", "activity", "travel", "objects", "symbols"]

    property var _entries: []
    property var _recents: []
    property string _query: ""
    property string _flash: ""

    // Browse mode: recents + one section per category. Search mode: one
    // flat section. Glyphs are plain strings so every section renders
    // with the same cell delegate.
    readonly property var _sections: {
        if (root._query !== "")
            return [{ header: "Results", glyphs: root._searchResults().map(e => e.e) }];

        const sections = [];
        if (root._recents.length > 0)
            sections.push({ header: "Recent", glyphs: root._recents });
        for (const cat of root._cats) {
            const items = root._byCat(cat);
            if (items.length > 0)
                sections.push({ header: cat, glyphs: items.map(e => e.e) });
        }
        return sections;
    }

    function _loadEntries() {
        if (root._entries.length > 0)
            return;
        try {
            const parsed = JSON.parse(emojiFile.text());
            if (Array.isArray(parsed))
                root._entries = parsed;
        } catch (e) {
            console.warn("[mdo] emoji: failed to load emoji data:", e);
        }
    }

    function _loadRecents() {
        try {
            const parsed = JSON.parse(recentsFile.text());
            if (Array.isArray(parsed))
                root._recents = parsed.slice(0, 16);
        } catch (e) {
            root._recents = [];
        }
    }

    function _pushRecent(glyph) {
        root._recents = [glyph].concat(root._recents.filter(r => r !== glyph)).slice(0, 16);
        recentsFile.setText(JSON.stringify(root._recents));
    }

    function _byCat(cat) {
        return root._entries.filter(e => e.c === cat);
    }

    function _searchResults() {
        const q = root._query;
        return root._entries.filter(e => e.n.toLowerCase().includes(q));
    }

    function _pick(glyph) {
        Quickshell.execDetached(["wl-copy", glyph]);
        root._pushRecent(glyph);
        root._flash = glyph;
        flashTimer.restart();
    }

    onOpened: {
        root._loadEntries();
        root._loadRecents();
        searchInput.text = "";
        root._query = "";
        root._flash = "";
        gridScroll._y = 0;
        searchInput.forceActiveFocus();
    }

    Timer {
        id: flashTimer

        interval: 380
        onTriggered: {
            root._flash = "";
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
                text: "Search emojis…"
                font.family: Theme.fonts.sans
                font.pixelSize: Theme.fonts.size.md
                color: Theme.comment
            }

            onTextChanged: root._query = text.toLowerCase()
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Grid ────────────────────────────────────────────────────────────
    ScrollableList {
        id: gridScroll

        width: parent.width
        maxHeight: 380

        Column {
            width: parent.width
            spacing: Theme.spacing.sm

            Repeater {
                model: root._sections

                delegate: Column {
                    id: section

                    required property var modelData

                    width: parent.width
                    spacing: Theme.spacing.sm

                    SectionHeader {
                        text: section.modelData.header
                    }

                    Flow {
                        width: parent.width
                        spacing: 4

                        Repeater {
                            model: section.modelData.glyphs

                            delegate: Rectangle {
                                id: cell

                                required property var modelData

                                readonly property bool flashing: root._flash === cell.modelData

                                width: 40
                                height: 40
                                radius: Theme.radius.sm

                                color: {
                                    if (cell.flashing)
                                        return Theme.accentWash;
                                    if (mouse.containsMouse)
                                        return Theme.wash;
                                    return "transparent";
                                }

                                border.width: cell.flashing ? 1 : 0
                                border.color: Theme.accent

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.duration.fast
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: cell.modelData
                                    font.family: Theme.fonts.sans
                                    font.pixelSize: 20
                                }

                                MouseArea {
                                    id: mouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root._pick(cell.modelData)
                                }

                                Accessible.role: Accessible.Button
                                Accessible.name: cell.modelData
                            }
                        }
                    }
                }
            }

            Text {
                visible: root._query !== "" && root._searchResults().length === 0
                text: "No emojis match"
                font.family: Theme.fonts.sans
                font.pixelSize: Theme.fonts.size.sm
                color: Theme.fgDark
            }
        }
    }
}
