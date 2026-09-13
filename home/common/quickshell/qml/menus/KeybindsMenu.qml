// KeybindsMenu — PHASE2 Hyprland keybind cheat sheet modal.
//
// Reads `hyprctl binds -j` on open and renders a keycap cheat sheet:
// chords as KeyCap chips, grouped into modifier families (Super,
// Super+Shift, Super+Alt, Ctrl+Alt, media keys, …) under SectionHeaders,
// two columns per group. Type-to-filter across chord + description;
// Escape closes (via ModalWindow). Chord decoding is defensive: unknown
// modmask bits are ignored, entries without key/keycode are skipped.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 640

    // ── Data ────────────────────────────────────────────────────────────
    property var _all: []
    property bool _loaded: false
    property string _query: ""

    readonly property var _filtered: root._all.filter(row =>
        root._query === "" || row.search.includes(root._query))

    // Modifier families in display order; anything else is appended,
    // sorted. "" = binds without modifiers (media keys, mouse binds).
    readonly property var _familyOrder: [
        "Super", "Super+Shift", "Super+Alt", "Super+Ctrl",
        "Super+Shift+Alt", "Super+Shift+Ctrl", "Super+Alt+Ctrl",
        "Ctrl+Alt", "Ctrl+Shift", "Ctrl", "Alt", "Shift", ""
    ]

    // Live regrouping of the filtered rows by modifier family.
    readonly property var _groups: {
        const byKey = {};
        for (let i = 0; i < root._filtered.length; i++) {
            const row = root._filtered[i];
            if (byKey[row.family] === undefined)
                byKey[row.family] = { label: row.familyLabel, rows: [] };
            byKey[row.family].rows.push(row);
        }
        const groups = [];
        for (const sig of root._familyOrder) {
            if (byKey[sig] !== undefined) {
                groups.push(byKey[sig]);
                delete byKey[sig];
            }
        }
        const rest = Object.keys(byKey).sort();
        for (const key of rest)
            groups.push(byKey[key]);
        return groups;
    }

    onOpened: {
        root._all = [];
        root._loaded = false;
        root._query = "";
        searchInput.text = "";
        bindsProc.running = true;
        bindsScroll._y = 0;
        searchInput.forceActiveFocus();
    }

    Process {
        id: bindsProc

        command: ["hyprctl", "binds", "-j"]

        stdout: StdioCollector {
            id: bindsOut

            onStreamFinished: root._loadBinds(bindsOut.text)
        }
    }

    // Modmask bits (defensive: anything unknown is skipped).
    function _mods(mask) {
        if (typeof mask !== "number" || mask <= 0)
            return [];
        const mods = [];
        if (mask & 64)
            mods.push("Super");
        if (mask & 1)
            mods.push("Shift");
        if (mask & 2)
            mods.push("CapsLock");
        if (mask & 4)
            mods.push("Ctrl");
        if (mask & 8)
            mods.push("Alt");
        return mods;
    }

    function _loadBinds(text) {
        let binds = [];
        try {
            const parsed = JSON.parse(text);
            if (Array.isArray(parsed))
                binds = parsed;
        } catch (e) {
            console.warn("[mdo] keybinds: failed to parse hyprctl output:", e);
        }

        root._all = binds.map(b => {
            const mods = root._mods(b.modmask);
            const key = typeof b.key === "string" && b.key.length > 0
                ? (b.key.length === 1 ? b.key.toUpperCase() : b.key)
                : (b.keycode ? "code:" + b.keycode : "");
            const desc = b.description ? b.description
                : (b.dispatcher || "") + (b.arg ? " " + b.arg : "");
            const chord = mods.join("+") + (mods.length > 0 && key !== "" ? "+" : "") + key;
            return {
                chord: chord,
                desc: desc,
                family: mods.join("+"),
                familyLabel: mods.length > 0 ? mods.join(" + ") : "Media & Misc",
                parts: mods.map(m => {
                    return { label: m, mod: true };
                }).concat(key === "" ? [] : [{ label: key, mod: false }]),
                search: [chord, key, b.keycode, b.dispatcher, b.arg, b.description]
                    .filter(f => f !== undefined && f !== null).join(" ").toLowerCase()
            };
        }).filter(row => row.chord !== "" && row.parts.length > 0);

        root._loaded = true;
    }

    // ── Title ───────────────────────────────────────────────────────────
    Item {
        width: parent.width
        height: 16

        SectionHeader {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Keyboard Shortcuts"
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: "hyprctl binds"
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.xs
            color: Theme.comment
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
                text: "Search keybinds…"
                font.family: Theme.fonts.sans
                font.pixelSize: Theme.fonts.size.md
                color: Theme.comment
            }

            onTextChanged: root._query = text.toLowerCase()
        }
    }

    // ── Grouped bind sheet ──────────────────────────────────────────────
    ScrollableList {
        id: bindsScroll

        width: parent.width
        maxHeight: 440

        Column {
            width: parent.width
            spacing: Theme.spacing.lg

            Repeater {
                model: root._groups

                delegate: Column {
                    id: group

                    required property var modelData

                    width: parent.width
                    spacing: Theme.spacing.sm

                    // Family header: SectionHeader + bind count.
                    Item {
                        width: parent.width
                        height: 22

                        SectionHeader {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            text: group.modelData.label
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: group.modelData.rows.length + (group.modelData.rows.length === 1 ? " bind" : " binds")
                            font.family: Theme.fonts.mono
                            font.pixelSize: Theme.fonts.size.xs
                            color: Theme.fgDark
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.withAlpha(Theme.hairline, 0.6)
                    }

                    // Two-column density.
                    Grid {
                        id: grid

                        width: parent.width
                        columns: 2
                        columnSpacing: Theme.spacing.sm
                        rowSpacing: 2

                        Repeater {
                            model: group.modelData.rows

                            delegate: Rectangle {
                                id: cell

                                required property var modelData

                                width: Math.floor((grid.width - grid.columnSpacing) / 2)
                                height: 28
                                radius: Theme.radius.sm
                                clip: true
                                color: mouse.containsMouse ? Theme.wash : "transparent"

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.duration.fast
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacing.sm
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacing.sm
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: Theme.spacing.sm

                                    // Chord: modifier caps + "+" separators + key cap.
                                    Row {
                                        id: capRow

                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 3

                                        Repeater {
                                            model: cell.modelData.parts

                                            delegate: Row {
                                                id: part

                                                required property var modelData
                                                required property int index

                                                spacing: 3

                                                Text {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    visible: part.index > 0
                                                    text: "+"
                                                    font.family: Theme.fonts.mono
                                                    font.pixelSize: Theme.fonts.size.xs
                                                    color: Theme.comment
                                                }

                                                KeyCap {
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    label: part.modelData.label
                                                    mod: part.modelData.mod
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: Math.max(0, parent.width - capRow.width - parent.spacing)
                                        text: cell.modelData.desc
                                        elide: Text.ElideRight
                                        font.family: Theme.fonts.sans
                                        font.pixelSize: Theme.fonts.size.sm
                                        color: Theme.fg
                                    }
                                }

                                MouseArea {
                                    id: mouse

                                    anchors.fill: parent
                                    hoverEnabled: true
                                }
                            }
                        }
                    }
                }
            }

            // Empty / loading state.
            Column {
                visible: root._groups.length === 0
                width: parent.width
                spacing: Theme.spacing.xs

                Item {
                    width: 1
                    height: 48
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: root._loaded ? "No keybinds match" : "Loading keybinds…"
                    font.family: Theme.fonts.sans
                    font.pixelSize: Theme.fonts.size.md
                    color: Theme.fg
                }

                Text {
                    visible: root._loaded
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: "Try a shorter query — e.g. \"launcher\""
                    font.family: Theme.fonts.sans
                    font.pixelSize: Theme.fonts.size.sm
                    color: Theme.fgDark
                }
            }
        }
    }

    // ── Footer: hint + count ────────────────────────────────────────────
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    Item {
        width: parent.width
        height: 14

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Type to filter · Esc to close"
            font.family: Theme.fonts.sans
            font.pixelSize: Theme.fonts.size.xs
            color: Theme.fgDark
        }

        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root._filtered.length + " / " + root._all.length + " binds"
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.xs
            color: Theme.fgDark
        }
    }
}
