// KeyCap — a single keyboard-keycap chip.
//
// The visual language of the keybinds cheat sheet: modifier keys render
// as solid selection-filled caps (they set the context), while the final
// key renders as an outlined cap with bright text (the key you actually
// press). Mono font, hairline border, radius.xs — one family with mdo.

import QtQuick

import qs

Rectangle {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    property string label: ""

    // true → modifier cap (solid, quiet); false → key cap (outlined, bright).
    property bool mod: false

    // ── Visuals ─────────────────────────────────────────────────────────
    implicitWidth: root.label === "" ? 0 : capText.implicitWidth + 10
    implicitHeight: 20
    radius: Theme.radius.xs

    color: root.mod ? Theme.selection : "transparent"
    border.width: root.mod ? 0 : 1
    border.color: Theme.hairline

    Text {
        id: capText

        anchors.centerIn: parent
        text: root.label
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.xs
        font.weight: root.mod ? Font.Medium : Font.DemiBold
        color: root.mod ? Theme.fg : Theme.fgBright
    }
}
