// mdo — Material Deep Ocean shell root.
//
// One Bar per screen + the IPC hub and global windows. Reach it from the
// CLI with:
//   qs -c mdo ipc call <target> <function>    e.g. qs -c mdo ipc call power open

import Quickshell
import Quickshell.Io
import QtQuick

import qs.bar
import qs.launcher
import qs.menus
import qs.notifications

ShellRoot {
    id: shellRoot

    // Every bar instance, for IPC-triggered popovers.
    property var bars: []

    Variants {
        model: Quickshell.screens

        Bar {
            id: bar

            screen: modelData

            Component.onCompleted: shellRoot.bars.push(bar)
            Component.onDestruction: {
                const idx = shellRoot.bars.indexOf(bar);
                if (idx !== -1)
                    shellRoot.bars.splice(idx, 1);
            }
        }
    }

    // ─── Global overlay windows (singletons, primary-screen) ──────────
    Launcher {
        id: launcherWin
    }

    ClipboardMenu {
        id: clipboardWin
    }

    EmojiPicker {
        id: emojiWin
    }

    ScreenshotMenu {
        id: screenshotWin
    }

    KeybindsMenu {
        id: keybindsWin
    }

    // ─── Overlay seams ─────────────────────────────────────────────────
    signal launcherRequested()
    signal notificationsRequested()
    signal notificationsCenterRequested()
    signal clipboardRequested()
    signal emojiRequested()
    signal screenshotRequested()
    signal keybindsRequested()

    onLauncherRequested: launcherWin.openWindow()
    onNotificationsRequested: Store.center.openWindow()
    onNotificationsCenterRequested: Store.center.openWindow()
    onClipboardRequested: clipboardWin.openWindow()
    onEmojiRequested: emojiWin.openWindow()
    onScreenshotRequested: screenshotWin.openWindow()
    onKeybindsRequested: keybindsWin.openWindow()

    // ─── IPC hub ───────────────────────────────────────────────────────
    IpcHandler {
        target: "launcher"

        function open(): void {
            shellRoot.launcherRequested()
        }
    }

    IpcHandler {
        target: "power"

        function open(): void {
            const bar = shellRoot.bars.find(b => b.screen === Quickshell.primaryScreen) || shellRoot.bars[0];
            if (bar)
                bar.openPowerMenu();
        }
    }

    IpcHandler {
        target: "notifications"

        function open(): void {
            shellRoot.notificationsRequested()
        }

        function center(): void {
            shellRoot.notificationsCenterRequested()
        }
    }

    IpcHandler {
        target: "clipboard"

        function open(): void {
            shellRoot.clipboardRequested()
        }
    }

    IpcHandler {
        target: "emoji"

        function open(): void {
            shellRoot.emojiRequested()
        }
    }

    IpcHandler {
        target: "screenshot"

        function open(): void {
            shellRoot.screenshotRequested()
        }
    }

    IpcHandler {
        target: "keybinds"

        function open(): void {
            shellRoot.keybindsRequested()
        }
    }
}
