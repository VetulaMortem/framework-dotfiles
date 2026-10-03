//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import ".."
PanelWindow {
    id: osdWindow

    anchors {
        bottom: true
    }
    margins.bottom: -3

    implicitWidth: 230
    implicitHeight: 40
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-osd"

    property int volumeLevel: AudioStore.volumeLevel
    property bool isMuted: AudioStore.isMuted


    visible: false

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: {
            osdWindow.visible = false
        }
    }

    function triggerOSD() {
        osdWindow.visible = true
        hideTimer.restart()
    }

    // OSD bei Änderungen triggern
    onVolumeLevelChanged: triggerOSD()
    onIsMutedChanged: triggerOSD()

    Rectangle {
        id: contentBox
        anchors.fill: parent
        color: Theme.background
        border.color: Theme.border
        border.width: Theme.width
        bottomLeftRadius: 0
        bottomRightRadius: 0
        topLeftRadius: 32
        topRightRadius: 32
        opacity: 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 100
                easing.type: Easing.OutCubic
            }
        }

        Row {
            anchors.centerIn: parent
            spacing: 14

            Text {
                width: 8
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 22
                color: osdWindow.isMuted ? Theme.alternate : Theme.text
                text: osdWindow.isMuted ? "󰝟" : (osdWindow.volumeLevel > 50 ? "󰕾" : "󰖀")
            }

            Rectangle {
                width: 130
                height: 10
                radius: 5
                color: Theme.alternate
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * (Math.min(osdWindow.volumeLevel, 100) / 100)
                    height: parent.height
                    radius: 5
                    color: osdWindow.isMuted ? Theme.alternate : Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    width: osdWindow.volumeLevel > 100
                           ? parent.width * (Math.min(osdWindow.volumeLevel - 100, 100) / 100)
                           : 0
                    height: parent.height
                    radius: 5
                    color: Theme.secondary
                    visible: !osdWindow.isMuted && osdWindow.volumeLevel > 100

                    Behavior on width {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }

            Text {
                width: 24
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 14
                font.bold: true
                color: Theme.text
                text: osdWindow.volumeLevel + "%"
            }
        }
    }
}
