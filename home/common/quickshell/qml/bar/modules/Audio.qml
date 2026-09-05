// Audio — fully wired to the Pipewire default sink.
//
// Icon + mono volume readout react live (PwObjectTracker is REQUIRED —
// without it volume/muted changes don't propagate). Click opens
// AudioPopover for device switching and per-direction control.

import QtQuick
import Quickshell.Services.Pipewire

import qs
import qs.components
import qs.popovers

BarWidget {
    id: root

    property var hub: null

    readonly property var sink: Pipewire.defaultAudioSink

    // Tracker required — without it volume/muted changes don't propagate.
    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    readonly property real volume: root.sink && root.sink.audio ? root.sink.audio.volume : 0
    readonly property bool muted: root.sink && root.sink.audio ? root.sink.audio.muted : false

    readonly property string audioIcon: {
        if (root.muted || root.volume <= 0.001)
            return Theme.icons.volumeMute;
        if (root.volume < 0.5)
            return Theme.icons.volumeDown;
        return Theme.icons.volumeUp;
    }

    checked: audioPopover.visible
    contentSpacing: 6

    onClicked: {
        if (root.hub)
            root.hub.openPopover(audioPopover, root);
        else
            audioPopover.toggleFor(root);
    }

    AudioPopover {
        id: audioPopover
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.audioIcon
        font.family: Theme.fonts.mono
        font.pixelSize: 14
        color: root.muted ? Theme.comment : root.contentColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.volume * 100) + "%"
        font.family: Theme.fonts.mono
        font.pixelSize: Theme.fonts.size.sm
        color: root.muted ? Theme.comment : root.contentColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.duration.fast
            }
        }
    }
}
