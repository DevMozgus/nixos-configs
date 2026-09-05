// AudioPopover — FULLY FUNCTIONAL exemplar (Quickshell.Services.Pipewire).
//
// Output/input device switching (optimistic), volume slider + mute for
// the current default sink and source. PwObjectTracker is REQUIRED for
// the volume/muted bindings below to propagate.

import QtQuick
import Quickshell.Services.Pipewire

import qs
import qs.components

Popover {
    id: root

    popWidth: 300

    // ── Data ────────────────────────────────────────────────────────────
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream)
    readonly property var sources: Pipewire.nodes.values.filter(n => n.isSource && !n.isStream)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Optimistic device switching: highlight the clicked device right away
    // and clear the pending override once the server confirms the default.
    property int pendingSinkId: -1
    property int pendingSourceId: -1

    onSinkChanged: root.pendingSinkId = -1
    onSourceChanged: root.pendingSourceId = -1

    readonly property int effectiveSinkId: root.pendingSinkId >= 0 ? root.pendingSinkId : (root.sink ? root.sink.id : -1)
    readonly property int effectiveSourceId: root.pendingSourceId >= 0 ? root.pendingSourceId : (root.source ? root.source.id : -1)

    // Tracker required — without it volume/muted changes don't propagate
    // to the sliders below.
    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => n)
    }

    readonly property real sinkVolume: root.sink && root.sink.audio ? root.sink.audio.volume : 0
    readonly property bool sinkMuted: root.sink && root.sink.audio ? root.sink.audio.muted : false
    readonly property real sourceVolume: root.source && root.source.audio ? root.source.audio.volume : 0
    readonly property bool sourceMuted: root.source && root.source.audio ? root.source.audio.muted : false

    function _deviceLabel(node) {
        return node.description || node.nickname || node.name || "Unknown device";
    }

    // ── Output ──────────────────────────────────────────────────────────
    SectionHeader {
        text: "Output"
    }

    ScrollableList {
        width: parent.width
        maxHeight: 150

        Repeater {
            model: root.sinks

            delegate: MenuRow {
                required property var modelData

                width: parent.width
                icon: Theme.icons.volumeUp
                label: root._deviceLabel(modelData)
                selected: modelData.id === root.effectiveSinkId

                onActivated: {
                    root.pendingSinkId = modelData.id;
                    // Async on the server side — the UI stays optimistic.
                    Pipewire.preferredDefaultAudioSink = modelData;
                }
            }
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: root.sinkMuted ? Theme.icons.volumeMute : (root.sinkVolume < 0.5 ? Theme.icons.volumeDown : Theme.icons.volumeUp)
            danger: root.sinkMuted

            onActivated: {
                if (root.sink && root.sink.audio)
                    root.sink.audio.muted = !root.sinkMuted;
            }
        }

        Slider {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 28 - 46 - parent.spacing * 2
            value: root.sinkVolume
            step: 0.05

            onMoved: value => {
                if (root.sink && root.sink.audio)
                    root.sink.audio.volume = value;
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 46
            text: Math.round(root.sinkVolume * 100) + "%"
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.sm
            color: root.sinkMuted ? Theme.comment : Theme.fg
            horizontalAlignment: Text.AlignRight
        }
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.hairline
    }

    // ── Input ───────────────────────────────────────────────────────────
    SectionHeader {
        text: "Input"
    }

    ScrollableList {
        width: parent.width
        maxHeight: 110

        Repeater {
            model: root.sources

            delegate: MenuRow {
                required property var modelData

                width: parent.width
                icon: Theme.icons.microphone
                label: root._deviceLabel(modelData)
                selected: modelData.id === root.effectiveSourceId

                onActivated: {
                    root.pendingSourceId = modelData.id;
                    Pipewire.preferredDefaultAudioSource = modelData;
                }
            }
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacing.sm

        IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: root.sourceMuted ? Theme.icons.microphoneMute : Theme.icons.microphone
            danger: root.sourceMuted

            onActivated: {
                if (root.source && root.source.audio)
                    root.source.audio.muted = !root.sourceMuted;
            }
        }

        Slider {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 28 - 46 - parent.spacing * 2
            value: root.sourceVolume
            step: 0.05

            onMoved: value => {
                if (root.source && root.source.audio)
                    root.source.audio.volume = value;
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 46
            text: Math.round(root.sourceVolume * 100) + "%"
            font.family: Theme.fonts.mono
            font.pixelSize: Theme.fonts.size.sm
            color: root.sourceMuted ? Theme.comment : Theme.fg
            horizontalAlignment: Text.AlignRight
        }
    }
}
