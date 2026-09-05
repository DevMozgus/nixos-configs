// ScreenshotMenu — PHASE2 screenshot/recording menu modal.
//
// Replicates the retired rofi screenshot-menu script + the grimblast
// Hyprland binds: area/screen × clipboard/satty-edit, gpu-screen-recorder
// variants, color picker. Every row launches the same underlying command
// detached and closes the menu.

import QtQuick
import Quickshell
import Quickshell.Io

import qs
import qs.components

ModalWindow {
    id: root

    cardWidth: 320

    // Recording state — mirrors /tmp/screenrecord-pid (toggle-recording).
    property bool _recording: false

    onOpened: {
        root._recording = false;
        recordingCheck.running = true;
    }

    Process {
        id: recordingCheck

        command: ["bash", "-c", "if [ -f /tmp/screenrecord-pid ] && kill -0 \"$(cat /tmp/screenrecord-pid)\" 2>/dev/null; then echo on; else echo off; fi"]

        stdout: StdioCollector {
            id: recordingOut

            onStreamFinished: root._recording = recordingOut.text.trim() === "on"
        }
    }

    function _run(command) {
        Quickshell.execDetached(command);
        root.closeWindow();
    }

    // gpu-screen-recorder launch, same flags as the old menu script; the
    // audio variant rows don't manage the PID file (only toggle-recording
    // does).
    function _record(audioArgs) {
        root._run(["bash", "-c",
            "mkdir -p \"$HOME/Videos\"; "
            + "FILE=\"$HOME/Videos/screenrecording-$(date +%Y-%m-%d_%H-%M-%S).mp4\"; "
            + "notify-send \"Screen Recording\" \"Select area to record…\" -t 3000; "
            + "exec gpu-screen-recorder -w portal -k auto -s 0x0 -f 60 -fm cfr "
            + "-fallback-cpu-encoding yes -o \"$FILE\" " + audioArgs]);
    }

    // ── Screenshots ─────────────────────────────────────────────────────
    SectionHeader {
        text: "Screenshots"
    }

    MenuRow {
        width: parent.width
        label: "Screenshot region → clipboard"
        readout: "grimblast copy area"

        onActivated: root._run(["grimblast", "copy", "area"])
    }

    MenuRow {
        width: parent.width
        label: "Screenshot screen → clipboard"
        readout: "grimblast copy screen"

        onActivated: root._run(["grimblast", "copy", "screen"])
    }

    MenuRow {
        width: parent.width
        label: "Screenshot region → edit (satty)"
        readout: "grimblast save area"

        onActivated: root._run(["bash", "-c", "grimblast save area - | satty --filename -"])
    }

    MenuRow {
        width: parent.width
        label: "Screenshot screen → edit (satty)"
        readout: "grimblast save screen"

        onActivated: root._run(["bash", "-c", "grimblast save screen - | satty --filename -"])
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Recording ───────────────────────────────────────────────────────
    SectionHeader {
        text: "Recording"
    }

    MenuRow {
        width: parent.width
        visible: root._recording
        icon: Theme.icons.record
        danger: true
        label: "Stop recording"
        readout: "stop-recording"

        onActivated: root._run(["stop-recording"])
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.record
        label: "Record screen (no audio)"
        readout: "toggle-recording"

        onActivated: root._run(["toggle-recording"])
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.record
        label: "Record screen + desktop audio"

        onActivated: root._record("-a default_output -ac aac")
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.record
        label: "Record screen + desktop + mic"

        onActivated: root._record("-a \"default_output|default_input\" -ac aac")
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Tools ───────────────────────────────────────────────────────────
    SectionHeader {
        text: "Tools"
    }

    MenuRow {
        width: parent.width
        icon: Theme.icons.sun
        label: "Color picker"
        readout: "hyprpicker -a"

        onActivated: root._run(["hyprpicker", "-a"])
    }
}
