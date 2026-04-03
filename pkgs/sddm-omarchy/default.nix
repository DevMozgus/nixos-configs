# SDDM theme: Material Deep Ocean (omarchy-style)
# Minimal login screen: centered NixOS snowflake + password field.
{ stdenv, lib, writeText, icon }:

let
  mainQml = writeText "Main.qml" ''
    import QtQuick

    Rectangle {
        id: root
        width: 640
        height: 480
        color: "#0F111A"

        property string currentUser: {
            if (userModel.lastUser !== "") return userModel.lastUser
            // SDDM UserModel.NameRole = Qt::UserRole + 1; Qt.DisplayRole is not handled
            var n = userModel.data(userModel.index(0, 0), Qt.UserRole + 1)
            return n ? n.toString() : ""
        }
        property int sessionIndex: {
            // SDDM SessionModel.NameRole = Qt::UserRole + 3
            for (var i = 0; i < sessionModel.rowCount(); i++) {
                var name = (sessionModel.data(sessionModel.index(i, 0), Qt.UserRole + 3) || "").toString()
                if (name.indexOf("uwsm") !== -1)
                    return i
            }
            return sessionModel.lastIndex
        }

        Connections {
            target: sddm
            function onLoginFailed() {
                errorMessage.text = "Login failed"
                password.text = ""
                password.focus = true
            }
            function onLoginSucceeded() {
                errorMessage.text = ""
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: root.height * 0.04
            width: parent.width

            Image {
                source: "logo.svg"
                width: root.width * 0.35
                height: Math.round(width * implicitHeight / implicitWidth)
                sourceSize.width: root.width * 0.35 * Screen.devicePixelRatio
                sourceSize.height: root.width * 0.35 * Screen.devicePixelRatio
                fillMode: Image.PreserveAspectFit
                smooth: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.width * 0.007

                Text {
                    text: "\uf023"
                    color: "#EEFFFF"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: root.height * 0.025
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: root.width * 0.17
                    height: root.height * 0.04
                    color: "#0F111A"
                    border.color: "#8F93A2"
                    border.width: 1
                    clip: true

                    TextInput {
                        id: password
                        anchors.fill: parent
                        anchors.margins: root.height * 0.008
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Password
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: root.height * 0.02
                        font.letterSpacing: root.height * 0.004
                        passwordCharacter: "\u2022"
                        color: "#EEFFFF"
                        focus: true

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(root.currentUser, password.text, root.sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }
            }

            Text {
                id: errorMessage
                text: ""
                color: "#FF5370"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: root.height * 0.018
                anchors.horizontalCenter: parent.horizontalCenter
            }
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
    cp ${icon} $out/share/sddm/themes/omarchy/logo.svg
  '';

  meta = with lib; {
    description = "Material Deep Ocean SDDM login theme (omarchy-style)";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
