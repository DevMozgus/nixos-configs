# SDDM theme: Material Deep Ocean (omarchy-style)
{
  stdenv,
  lib,
  writeText,
  wallpaper,
}:

let
  mainQml = writeText "Main.qml" ''
    import QtQuick 2.0
    import SddmComponents 2.0

    Rectangle {
        id: root
        width: 640
        height: 480
        color: "#0F111A"

        property string currentUser: "nicola"
        // 0 = normal, 1 = checking, 2 = failed
        property int authState: 0
        // Index of the selected session (passed to sddm.login). Defaults to
        // the UWSM entry; the dropdown below lets the user switch to plain
        // "Hyprland" for diagnostics.
        property int sessionIndex: 0
        property bool sessionListOpen: false

        // SDDM SessionModel roles (src/greeter/SessionModel.h):
        //   DirectoryRole = Qt.UserRole+1, FileRole = Qt.UserRole+2, TypeRole = Qt.UserRole+3,
        //   NameRole = Qt.UserRole+4, ExecRole = Qt.UserRole+5, CommentRole = Qt.UserRole+6.
        // data() returns an empty QVariant for Qt.DisplayRole — session names
        // MUST be read via NameRole or the selector renders blank.
        function sessionName(i) {
            return (sessionModel.data(sessionModel.index(i, 0), Qt.UserRole + 4) || "").toString()
        }

        // Default to the UWSM-managed Hyprland session, but the session
        // selector below lets the user pick plain "Hyprland" instead.
        function findDefaultSession() {
            // Prefer the UWSM session (file path contains "uwsm").
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var file = (sessionModel.data(sessionModel.index(i, 0), Qt.UserRole + 2) || "").toString()
                if (file.indexOf("uwsm") !== -1) return i
            }
            // Fallback: any Hyprland session.
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var name = root.sessionName(i).toLowerCase()
                if (name.indexOf("hyprland") !== -1) return i
            }
            return sessionModel.lastIndex
        }

        Connections {
            target: sddm
            function onLoginFailed() {
                root.authState = 2
                errorMsg.text = "Authentication failed"
                password.text = ""
                password.focus = true
            }
            function onLoginSucceeded() {
                root.authState = 0
                errorMsg.text = ""
            }
        }

        // Wallpaper
        Image {
            anchors.fill: parent
            source: "wallpaper3.png"
            fillMode: Image.PreserveAspectCrop
        }

        // Clock timer (every second)
        Timer { interval: 1000; running: true; repeat: true; onTriggered: timeLabel.text = Qt.formatTime(new Date(), "HH:mm") }
        // Date timer (every minute)
        Timer { interval: 60000; running: true; repeat: true; onTriggered: dateLabel.text = Qt.formatDate(new Date(), "dddd, MMMM d") }

        // ── Time (top, large) ────────────────────────────────────────────────
        Text {
            id: timeLabel
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.083
            text: Qt.formatTime(new Date(), "HH:mm")
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            font.pixelSize: root.height * 0.093
            color: "#E6EEFFFF"
        }

        // ── Date (below time) ────────────────────────────────────────────────
        Text {
            id: dateLabel
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.192
            text: Qt.formatDate(new Date(), "dddd, MMMM d")
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.height * 0.017
            color: "#CC8F93A2"
        }

        // ── Session selector (Hyprland vs Hyprland (UWSM)) ───────────────────
        // Minimalist pill dropdown built from pure QtQuick primitives (no
        // QtQuick.Controls, which fails to load its style plugin in the SDDM
        // Wayland greeter and breaks input). The pill shows the active session
        // name plus a chevron; tapping it opens a small floating list so the
        // user can pick plain "Hyprland" or "Hyprland (UWSM)" at login.
        Item {
            id: sessionSelector
            z: 50
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.645
            width: root.height * 0.28
            height: root.height * 0.04

            // Row highlighted by mouse hover or keyboard navigation.
            property int highlightIndex: -1

            function openSessionList() {
                sessionSelector.highlightIndex = root.sessionIndex
                root.sessionListOpen = true
                sessionKeys.forceActiveFocus()
            }

            function closeSessionList() {
                root.sessionListOpen = false
                password.forceActiveFocus()
            }

            // ── The pill ─────────────────────────────────────────────────────
            Rectangle {
                id: sessionPill
                anchors.fill: parent
                radius: height / 2
                color: pillArea.containsMouse || root.sessionListOpen ? "#AA181A29" : "#80181A29"
                border.width: 1
                border.color: root.sessionListOpen ? "#B382AAFF"
                            : pillArea.containsMouse ? "#8C676E95"
                            : "#4D464B5D"

                Behavior on color { ColorAnimation { duration: 160 } }
                Behavior on border.color { ColorAnimation { duration: 160 } }

                // Accent dot marking the session control
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: parent.height * 0.34
                    width: parent.height * 0.14
                    height: width
                    radius: width / 2
                    color: "#82AAFF"
                    opacity: root.sessionListOpen ? 1 : 0.65
                    Behavior on opacity { NumberAnimation { duration: 160 } }
                }

                Text {
                    anchors.centerIn: parent
                    width: parent.width - parent.height * 1.3
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: root.sessionName(root.sessionIndex)
                    color: "#EEFFFF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: root.height * 0.014
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: parent.height * 0.30
                    text: "\uf078"
                    color: root.sessionListOpen ? "#82AAFF" : "#676E95"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: Math.max(9, root.height * 0.011)
                    rotation: root.sessionListOpen ? 180 : 0
                    transformOrigin: Item.Center
                    Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 160 } }
                }

                MouseArea {
                    id: pillArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.sessionListOpen) sessionSelector.closeSessionList()
                        else sessionSelector.openSessionList()
                    }
                }
            }

            // Click-away catcher covering the whole screen (above the pill,
            // below the popup) so any outside click closes the list.
            MouseArea {
                x: -parent.x
                y: -parent.y
                width: root.width
                height: root.height
                z: 10
                visible: root.sessionListOpen
                onClicked: sessionSelector.closeSessionList()
            }

            // ── Floating session list ────────────────────────────────────────
            Item {
                id: sessionPopup
                z: 20
                property real pad: root.height * 0.008
                anchors.top: sessionPill.bottom
                anchors.topMargin: root.height * 0.010
                anchors.horizontalCenter: sessionPill.horizontalCenter
                width: sessionPill.width
                height: 2 * pad + listColumn.height
                visible: opacity > 0.01
                opacity: root.sessionListOpen ? 1 : 0
                transform: Translate {
                    y: root.sessionListOpen ? 0 : -root.height * 0.008
                    Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                }
                Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

                // Soft two-layer shadow
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 2 * root.height * 0.005
                    height: parent.height + 2 * root.height * 0.005
                    radius: sessionPanel.radius + root.height * 0.005
                    color: "#44000000"
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + 2 * root.height * 0.010
                    height: parent.height + 2 * root.height * 0.010
                    radius: sessionPanel.radius + root.height * 0.010
                    color: "#22000000"
                }

                Rectangle {
                    id: sessionPanel
                    anchors.fill: parent
                    color: "#F2181A29"
                    radius: root.height * 0.012
                    border.width: 1
                    border.color: root.sessionListOpen ? "#6682AAFF" : "#4D464B5D"

                    Column {
                        id: listColumn
                        anchors.centerIn: parent
                        width: sessionPopup.width - 2 * sessionPopup.pad
                        spacing: root.height * 0.004

                        Repeater {
                            model: sessionModel
                            delegate: Rectangle {
                                width: listColumn.width
                                height: root.height * 0.032
                                radius: height / 2
                                border.width: index === root.sessionIndex ? 1 : 0
                                border.color: "#4D82AAFF"
                                color: {
                                    var hot = sessionRowArea.containsMouse || index === sessionSelector.highlightIndex
                                    if (index === root.sessionIndex) return hot ? "#3D82AAFF" : "#261F2233"
                                    return hot ? "#2E1F2233" : "#001F2233"
                                }
                                Behavior on color { ColorAnimation { duration: 120 } }

                                // Fixed-width slot so labels align across rows
                                Item {
                                    anchors.top: parent.top
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.leftMargin: parent.height * 0.42
                                    width: Math.max(10, root.height * 0.013)

                                    Text {
                                        anchors.centerIn: parent
                                        visible: index === root.sessionIndex
                                        text: "\uf00c"
                                        color: "#82AAFF"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.pixelSize: Math.max(8, root.height * 0.011)
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: parent.height * 0.42 + Math.max(10, root.height * 0.013) + parent.height * 0.14
                                    anchors.right: parent.right
                                    anchors.rightMargin: parent.height * 0.42
                                    elide: Text.ElideRight
                                    text: root.sessionName(index)
                                    color: index === root.sessionIndex ? "#82AAFF"
                                         : (sessionRowArea.containsMouse || index === sessionSelector.highlightIndex) ? "#EEFFFF"
                                         : "#8F93A2"
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: root.height * 0.014
                                    verticalAlignment: Text.AlignVCenter
                                }

                                MouseArea {
                                    id: sessionRowArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: sessionSelector.highlightIndex = index
                                    onClicked: {
                                        root.sessionIndex = index
                                        sessionSelector.closeSessionList()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Keyboard support while the list is open: arrows move the
            // highlight, Enter/Space picks it, Escape closes.
            Item {
                id: sessionKeys
                Keys.onPressed: function(event) {
                    var count = sessionModel.rowCount()
                    if (event.key === Qt.Key_Escape) {
                        sessionSelector.closeSessionList()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        sessionSelector.highlightIndex = Math.max(0, sessionSelector.highlightIndex - 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        sessionSelector.highlightIndex = Math.min(count - 1, sessionSelector.highlightIndex + 1)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                        if (sessionSelector.highlightIndex >= 0 && sessionSelector.highlightIndex < count) {
                            root.sessionIndex = sessionSelector.highlightIndex
                        }
                        sessionSelector.closeSessionList()
                        event.accepted = true
                    }
                }
            }
        }

        // ── Username (bottom) ────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.729
            text: "\uf007  " + root.currentUser
            font.family: "JetBrainsMono Nerd Font"
            font.bold: true
            font.pixelSize: root.height * 0.013
            color: "#8F93A2"
        }

        // ── Password input ───────────────────────────────────────────────────
        Rectangle {
            id: inputContainer
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.792
            width: root.height * 0.28
            height: root.height * 0.046
            color: "#881F2233"
            border.color: root.authState === 0 ? "#F2676E95"
                        : root.authState === 1 ? "#F2C3E88D"
                        : "#F2FF5370"
            border.width: 2

            // Placeholder text
            Text {
                anchors.fill: parent
                anchors.margins: root.height * 0.007
                verticalAlignment: Text.AlignVCenter
                text: "Enter password\u2026"
                color: "#676E95"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: root.height * 0.017
                font.italic: true
                visible: password.text.length === 0
            }

            TextInput {
                id: password
                anchors.fill: parent
                anchors.margins: root.height * 0.007
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: root.height * 0.017
                font.letterSpacing: root.height * 0.004
                passwordCharacter: "\u2022"
                color: "#E6EEFFFF"
                focus: true

                onTextChanged: { if (root.authState === 2) root.authState = 0 }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.authState = 1
                        sddm.login(root.currentUser, password.text, root.sessionIndex)
                        event.accepted = true
                    }
                }
            }
        }

        // ── Error message (below input) ──────────────────────────────────────
        Text {
            id: errorMsg
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: inputContainer.bottom
            anchors.topMargin: root.height * 0.012
            text: ""
            color: "#F2FF5370"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.height * 0.015
            font.italic: true
        }

        Component.onCompleted: {
            root.sessionIndex = root.findDefaultSession()
            password.forceActiveFocus()
        }
    }
  '';

  metadataDesktop = writeText "metadata.desktop" ''
    [SddmGreeterTheme]
    Name=omarchy
    Description=Material Deep Ocean minimal login theme
    Author=nixos-configs
    MainScript=Main.qml
    ConfigFile=theme.conf
    QtVersion=6
    Theme-API=2.0
  '';

  themeConf = writeText "theme.conf" ''
    [General]
  '';
in
stdenv.mkDerivation {
  pname = "sddm-omarchy";
  version = "1.0.0";

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/omarchy
    cp ${mainQml} $out/share/sddm/themes/omarchy/Main.qml
    cp ${metadataDesktop} $out/share/sddm/themes/omarchy/metadata.desktop
    cp ${themeConf} $out/share/sddm/themes/omarchy/theme.conf
    cp ${wallpaper} $out/share/sddm/themes/omarchy/wallpaper3.png
  '';

  meta = with lib; {
    description = "Material Deep Ocean SDDM login theme (omarchy-style)";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
