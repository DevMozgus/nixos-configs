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

        // SDDM SessionModel roles: NameRole=0, FileRole=258.
        function sessionName(i) {
            return (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
        }

        // Default to the UWSM-managed Hyprland session, but the session
        // selector below lets the user pick plain "Hyprland" instead.
        function findDefaultSession() {
            // Prefer the UWSM session (file path contains "uwsm").
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var file = (sessionModel.data(sessionModel.index(i, 0), 258) || "").toString()
                if (file.indexOf("uwsm") !== -1) return i
            }
            // Fallback: any Hyprland session.
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString().toLowerCase()
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
        // Pure-QtQuick dropdown (no QtQuick.Controls, which fails to load its
        // style plugin in the SDDM Wayland greeter and breaks input). Lets the
        // user pick plain "Hyprland" or "Hyprland (UWSM)" at login.
        Item {
            id: sessionSelector
            z: 50
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.645
            width: root.height * 0.28
            height: root.height * 0.05

            Rectangle {
                id: sessionBox
                anchors.fill: parent
                color: root.sessionListOpen ? "#CC1F2233" : "#881F2233"
                border.color: "#F2676E95"
                border.width: 1
                radius: 2

                Text {
                    anchors.centerIn: parent
                    text: root.sessionName(root.sessionIndex)
                    color: "#8F93A2"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: root.height * 0.014
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.sessionListOpen = !root.sessionListOpen
                }
            }

            Column {
                id: sessionList
                anchors.top: sessionBox.bottom
                anchors.topMargin: 2
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.sessionListOpen
                z: 100

                Repeater {
                    model: sessionModel
                    delegate: Rectangle {
                        width: sessionBox.width
                        height: root.height * 0.04
                        color: index === root.sessionIndex ? "#6682AAFF" : "#DD181A29"
                        border.color: "#33676E95"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: root.sessionName(index)
                            color: "#EEFFFF"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: root.height * 0.014
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.sessionIndex = index
                                root.sessionListOpen = false
                            }
                        }
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
