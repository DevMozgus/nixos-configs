// ModalWindow — the ONE standalone modal frame (PHASE2 overlays).
//
// Fullscreen layer-shell window on the primary screen: dim scrim +
// centered card (panelBg, 1px hairline border, radius.lg) matching the
// Popover frame treatment. Closes on Esc or scrim click. Subclasses
// declare their content as direct children (routed into the padded card
// column) and react to opened() to reset state / focus search inputs.

import QtQuick
import Quickshell
import Quickshell.Wayland

import qs

PanelWindow {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    // Subclass content lands here.
    default property alias contentData: contentColumn.data
    property alias contentSpacing: contentColumn.spacing

    // Card geometry; height follows content.
    property int cardWidth: 480
    property int cardPadding: Theme.spacing.lg

    signal opened()
    // `closed` is inherited from PanelWindow (ProxyWindowBase); do not
    // redeclare — it logs an invalidOverride warning. We emit it manually
    // in onVisibleChanged for the hide transition.

    function openWindow() {
        root.visible = true;
    }

    function closeWindow() {
        root.visible = false;
    }

    // ── Window setup ────────────────────────────────────────────────────
    visible: false
    color: "transparent"
    // NOTE: `screen` is intentionally left unset — assigning
    // Quickshell.primaryScreen at creation time binds before screens are
    // enumerated ("Unable to assign [undefined]…"). Unset windows follow
    // the default (primary) screen, matching Toasts.qml.

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    exclusiveZone: -1

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "mdo:modal"

    onVisibleChanged: {
        if (visible) {
            card.opacity = 0;
            card.scale = 0.97;
            popIn.restart();
            root.opened();
        } else {
            root.closed();
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: root.closeWindow()
    }

    SequentialAnimation {
        id: popIn

        ParallelAnimation {
            NumberAnimation {
                target: card
                property: "opacity"
                to: 1
                duration: Theme.duration.normal
                easing.type: Theme.easing
            }
            NumberAnimation {
                target: card
                property: "scale"
                to: 1
                duration: Theme.duration.normal
                easing.type: Theme.easing
            }
        }
    }

    // ── Scrim ───────────────────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        color: Theme.withAlpha(Theme.bg, 0.5)

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeWindow()
        }
    }

    // ── Card ────────────────────────────────────────────────────────────
    Rectangle {
        id: card

        anchors.centerIn: parent
        width: root.cardWidth
        height: contentColumn.implicitHeight + root.cardPadding * 2

        radius: Theme.radius.lg
        color: Theme.panelBg
        border.width: 1
        border.color: Theme.hairline

        opacity: 0
        transformOrigin: Item.Center

        // Swallow clicks on the card body so they don't fall through to
        // the scrim; declared before the content column so real content
        // sits on top and stays interactive.
        MouseArea {
            anchors.fill: parent
        }

        Column {
            id: contentColumn

            anchors.fill: parent
            anchors.margins: root.cardPadding
            spacing: Theme.spacing.sm
        }
    }
}
