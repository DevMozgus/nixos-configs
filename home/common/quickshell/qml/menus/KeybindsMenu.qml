// KeybindsMenu — PHASE2 Hyprland keybind reference modal.
//
// Reads `hyprctl binds -j` on open and renders chord + description rows,
// searchable across every field. Chord decoding is defensive: unknown
// modmask bits are ignored, entries without key/keycode are skipped.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 520

    // ── Data ────────────────────────────────────────────────────────────
    property var _all: []
    property string _query: ""

    readonly property var _filtered: root._all.filter(row =>
        root._query === "" || row.search.includes(root._query))

    onOpened: {
        root._all = [];
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
            return {
                chord: mods.join("+") + (mods.length > 0 && key !== "" ? "+" : "") + key,
                desc: desc,
                search: [key, b.keycode, b.dispatcher, b.arg, b.description]
                    .filter(f => f !== undefined && f !== null).join(" ").toLowerCase()
            };
        }).filter(row => row.chord !== "");
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

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Bind rows ───────────────────────────────────────────────────────
    ScrollableList {
        id: bindsScroll

        width: parent.width
        maxHeight: 420

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: root._filtered

                delegate: Rectangle {
                    id: row

                    required property var modelData

                    width: parent.width
                    height: 34
                    radius: Theme.radius.sm
                    color: mouse.containsMouse ? Theme.wash : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.duration.fast
                        }
                    }

                    Text {
                        id: chordText

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        width: 170
                        text: row.modelData.chord
                        elide: Text.ElideRight
                        font.family: Theme.fonts.mono
                        font.pixelSize: Theme.fonts.size.sm
                        color: mouse.containsMouse ? Theme.fgBright : Theme.fg

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.duration.fast
                            }
                        }
                    }

                    Text {
                        anchors.left: chordText.right
                        anchors.leftMargin: Theme.spacing.md
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        text: row.modelData.desc
                        elide: Text.ElideRight
                        font.family: Theme.fonts.sans
                        font.pixelSize: Theme.fonts.size.md
                        color: Theme.fgDark
                    }

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                    }
                }
            }

            Text {
                visible: root._filtered.length === 0
                text: "No keybinds match"
                font.family: Theme.fonts.sans
                font.pixelSize: Theme.fonts.size.sm
                color: Theme.fgDark
            }
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Footer count ────────────────────────────────────────────────────
    Text {
        width: parent.width
        horizontalAlignment: Text.AlignHCenter

        text: root._filtered.length + " / " + root._all.length + " binds"
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.xs
        color: Theme.fgDark
    }
}
