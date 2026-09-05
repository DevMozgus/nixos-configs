// SectionHeader — small uppercase section label used inside popovers.

import QtQuick

import qs

Item {
    id: root

    property string text: ""

    implicitWidth: 200
    implicitHeight: 22

    Text {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        text: root.text.toUpperCase()
        font.family: Theme.fonts.sans
        font.pixelSize: Theme.fonts.size.xs
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
        color: Theme.fgDark
    }
}
