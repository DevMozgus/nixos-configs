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

        property string currentUser: userModel.lastUser
        // 0 = normal, 1 = checking, 2 = failed
        property int authState: 0
        property int sessionIndex: {
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
                if (name.indexOf("uwsm") !== -1) return i
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

        // ── Username (bottom) ────────────────────────────────────────────────
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.height * 0.729
            text: "\uf007  " + userModel.lastUser
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

        Component.onCompleted: password.forceActiveFocus()
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
