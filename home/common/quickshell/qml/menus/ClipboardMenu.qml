// ClipboardMenu — PHASE2 clipboard history modal (cliphist).
//
// Lists up to 30 cliphist entries on open; activating a row pipes the
// full cliphist line through cliphist decode | wl-copy. The raw line is
// handed to the shell via an environment variable — never interpolated
// into the command string. Image entries get a glyph but copy the same
// way. Two-step armed wipe at the bottom.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 420

    // Nerd Font picture glyph — Theme.icons has no image icon yet.
    readonly property string _imgGlyph: "\uF03E"

    property var _rows: []
    property bool _wipeArmed: false

    onOpened: {
        root._rows = [];
        root._wipeArmed = false;
        clipList.running = true;
        historyScroll._y = 0;
    }

    Process {
        id: clipList

        command: ["cliphist", "list"]

        stdout: StdioCollector {
            id: clipOut

            onStreamFinished: {
                const lines = clipOut.text.split("\n").filter(l => l.length > 0);
                root._rows = lines.slice(0, 30);
            }
        }
    }

    function _copyLine(line) {
        // The entry line travels via the environment — no shell quoting.
        Quickshell.execDetached({
            command: ["bash", "-c", "printf '%s\\n' \"$MDO_CLIP_LINE\" | cliphist decode | wl-copy"],
            environment: { MDO_CLIP_LINE: line }
        });
        root.closeWindow();
    }

    // ── History ─────────────────────────────────────────────────────────
    SectionHeader {
        text: "History"
    }

    ScrollableList {
        id: historyScroll

        width: parent.width
        maxHeight: 380

        Column {
            width: parent.width
            spacing: 2

            Repeater {
                model: root._rows

                delegate: Rectangle {
                    id: row

                    required property var modelData

                    // Label from the content field (after the id tab);
                    // falls back to the whole line.
                    readonly property string content: {
                        const idx = modelData.indexOf("\t");
                        return idx >= 0 ? modelData.slice(idx + 1) : modelData;
                    }
                    readonly property bool isImage: content.startsWith("img/")

                    width: parent.width
                    height: 34
                    radius: Theme.radius.sm

                    color: {
                        if (mouse.pressed)
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

                    Text {
                        id: iconText

                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        width: 20
                        visible: row.isImage
                        text: root._imgGlyph
                        font.family: Theme.fonts.mono
                        font.pixelSize: 14
                        color: mouse.containsMouse ? Theme.fgBright : Theme.fgDark
                    }

                    Text {
                        anchors.left: iconText.right
                        anchors.leftMargin: row.isImage ? Theme.spacing.sm : 0
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter

                        text: row.content
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

                    MouseArea {
                        id: mouse

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root._copyLine(row.modelData)
                    }

                    Accessible.role: Accessible.Button
                    Accessible.name: row.content
                }
            }

            Text {
                visible: root._rows.length === 0
                text: "Clipboard history is empty"
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

    // ── Danger zone ─────────────────────────────────────────────────────
    MenuRow {
        width: parent.width
        danger: true
        armed: root._wipeArmed
        armedLabel: "Really wipe all history?"
        label: "Clear history"

        onActivated: {
            if (root._wipeArmed) {
                root._wipeArmed = false;
                Quickshell.execDetached(["cliphist", "wipe"]);
                root.closeWindow();
            } else {
                root._wipeArmed = true;
            }
        }
    }
}
