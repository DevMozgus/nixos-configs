pragma Singleton

// mdo design system — Material Deep Ocean.
//
// Single source of truth for colors, fonts, spacing, radii, motion and
// icon glyphs across the whole shell. All values come from the
// Nix-generated Theme.json sitting next to shell.qml; the loading is
// deliberately isolated in this file so a mechanism change is a one-file
// fix. Every hardcoded hex below is a FALLBACK only (used when
// Theme.json is missing or malformed at runtime).

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // ─── Runtime theme source ──────────────────────────────────────────
    FileView {
        id: themeFile

        path: Qt.resolvedUrl("Theme.json")
        blockLoading: true
        watchChanges: false
    }

    readonly property var _raw: {
        try {
            const parsed = JSON.parse(themeFile.text());
            if (parsed !== null && typeof parsed === "object")
                return parsed;
        } catch (e) {
            console.warn("[mdo] Theme.json unavailable — using built-in fallbacks:", e);
        }
        return {};
    }

    function _pick(obj, key, fallback) {
        if (obj !== null && obj !== undefined && obj[key] !== null && obj[key] !== undefined)
            return obj[key];
        return fallback;
    }

    // Color with a new alpha — used all over the shell for washes/hairlines.
    function withAlpha(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha);
    }

    // ─── Identity / metrics ────────────────────────────────────────────
    readonly property bool isLaptop: root._pick(root._raw, "isLaptop", false)
    readonly property int barHeight: root._pick(root._raw, "barHeight", 36)

    // ─── Typography ────────────────────────────────────────────────────
    readonly property QtObject fonts: QtObject {
        readonly property string mono: root._pick(root._raw.fonts, "monospace", "monospace")
        readonly property string sans: root._pick(root._raw.fonts, "sansSerif", "sans-serif")

        readonly property QtObject size: QtObject {
            readonly property int xs: 10  // micro labels, dates, section headers
            readonly property int sm: 11  // secondary labels, mono readouts
            readonly property int md: 13  // default labels, bar clock
            readonly property int lg: 14  // popover titles
        }
    }

    // ─── Palette (base16 · Material Deep Ocean) ────────────────────────
    readonly property color bg: root._pick(root._raw.colors, "base00", "#0F111A")
    readonly property color surface: root._pick(root._raw.colors, "base01", "#181A29")
    readonly property color selection: root._pick(root._raw.colors, "base02", "#1F2233")
    readonly property color comment: root._pick(root._raw.colors, "base03", "#464B5D")
    readonly property color fgDark: root._pick(root._raw.colors, "base04", "#676E95")
    readonly property color fg: root._pick(root._raw.colors, "base05", "#8F93A2")
    readonly property color fgBright: root._pick(root._raw.colors, "base06", "#EEFFFF")
    readonly property color white: root._pick(root._raw.colors, "base07", "#FFFFFF")
    readonly property color red: root._pick(root._raw.colors, "base08", "#FF5370")
    readonly property color orange: root._pick(root._raw.colors, "base09", "#F78C6C")
    readonly property color yellow: root._pick(root._raw.colors, "base0A", "#FFCB6B")
    readonly property color green: root._pick(root._raw.colors, "base0B", "#C3E88D")
    readonly property color cyan: root._pick(root._raw.colors, "base0C", "#89DDFF")
    readonly property color accent: root._pick(root._raw.colors, "base0D", "#82AAFF")
    readonly property color purple: root._pick(root._raw.colors, "base0E", "#C792EA")
    readonly property color coral: root._pick(root._raw.colors, "base0F", "#F07178")

    // Semantic aliases — use these, not the raw slots, in widgets.
    readonly property color success: root.green
    readonly property color danger: root.red
    readonly property color warning: root.yellow

    // Derived surface treatments (the quiet-surface look).
    readonly property color barBg: root.withAlpha(root.bg, 0.88)
    readonly property color panelBg: root.withAlpha(root.surface, 0.97)
    readonly property color hairline: root.selection
    readonly property color wash: root.withAlpha(root.selection, 0.55)
    readonly property color washStrong: root.withAlpha(root.selection, 0.95)
    readonly property color dangerWash: root.withAlpha(root.danger, 0.16)
    readonly property color accentWash: root.withAlpha(root.accent, 0.16)

    // ─── Geometry ──────────────────────────────────────────────────────
    readonly property QtObject radius: QtObject {
        readonly property int xs: 6
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int pill: 1000
    }

    readonly property QtObject spacing: QtObject {
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int md: 12
        readonly property int lg: 16
        readonly property int xl: 24
    }

    // ─── Motion ────────────────────────────────────────────────────────
    readonly property QtObject duration: QtObject {
        readonly property int instant: 80
        readonly property int fast: 120
        readonly property int normal: 160
        readonly property int slow: 220
    }

    readonly property int easing: Easing.OutCubic

    // ─── Icon glyphs (Nerd Font, render with fonts.mono) ───────────────
    readonly property QtObject icons: QtObject {
        readonly property string chevronLeft: "\uF053"
        readonly property string chevronRight: "\uF054"
        readonly property string chevronUp: "\uF077"
        readonly property string chevronDown: "\uF078"
        readonly property string check: "\uF00C"
        readonly property string close: "\uF00D"
        readonly property string volumeUp: "\uF028"
        readonly property string volumeDown: "\uF027"
        readonly property string volumeMute: "\uF6A9"
        readonly property string microphone: "\uF130"
        readonly property string microphoneMute: "\uF131"
        readonly property string headphones: "\uF025"
        readonly property string wifi: "\uF1EB"
        readonly property string ethernet: "\uF796"
        readonly property string bluetooth: "\uF293"
        readonly property string bell: "\uF0F3"
        readonly property string bellSlash: "\uF1F6"
        readonly property string sun: "\uF185"
        readonly property string moon: "\uF186"
        readonly property string power: "\uF011"
        readonly property string drive: "\uF0A0"
        readonly property string layoutDwindle: "\uF009"
        readonly property string layoutMaster: "\uF0DB"
        readonly property string lock: "\uF023"
        readonly property string logout: "\uF2F5"
        readonly property string reboot: "\uF2F1"
        readonly property string batteryFull: "\uF240"
        readonly property string batteryThreeQuarters: "\uF241"
        readonly property string batteryHalf: "\uF242"
        readonly property string batteryQuarter: "\uF243"
        readonly property string batteryEmpty: "\uF244"
        readonly property string bolt: "\uF0E7"
        readonly property string record: "\uF111"
        readonly property string usb: "\uF287"
    }

    // Icon-theme names must go through the "image://icon/<name>" scheme for
    // IconImage; bare names are treated as qrc-relative URLs and fail to
    // load. Absolute paths and image:///http(s) URLs pass through untouched.
    function iconSource(raw) {
        if (raw === null || raw === undefined || raw === "")
            return "";
        if (raw.startsWith("/") || raw.startsWith("image://") || raw.startsWith("http"))
            return raw;
        return "image://icon/" + raw;
    }
}
