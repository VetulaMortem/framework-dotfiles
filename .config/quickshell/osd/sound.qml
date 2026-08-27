//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: osdWindow

    anchors {
        bottom: true
    }
    margins.bottom: -3

    implicitWidth: 230
    implicitHeight: 40
    color: "transparent"

    // Verhindert das Verschieben von Fenstern
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-osd"

    property int volumeLevel: 0
    property bool isMuted: false

    // Das Fenster startet komplett unsichtbar
    visible: false

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: {
            contentBox.opacity = 0.0
        }
    }

    function triggerOSD() {
        // Erst sichtbar machen, dann Transparenz hochfahren
        osdWindow.visible = true
        contentBox.opacity = 1.0
        hideTimer.restart()
    }

    Process {
        id: volumeMonitor
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@; pw-mon | stdbuf -oL grep --line-buffered 'sink' | while read -r line; do wpctl get-volume @DEFAULT_AUDIO_SINK@; done"]
        running: true

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                let str = data.trim()
                if (str.length === 0) return

                let muted = str.includes("[MUTED]")
                let match = str.match(/Volume:\s+([0-9.]+)/)
                let vol = match ? Math.round(parseFloat(match[1]) * 100) : 0

                if (osdWindow.volumeLevel !== vol || osdWindow.isMuted !== muted) {
                    osdWindow.volumeLevel = vol
                    osdWindow.isMuted = muted
                    osdWindow.triggerOSD()
                }
            }
        }
    }

    Rectangle {
        id: contentBox
        anchors.fill: parent
        color: "#BB2A39"
        border.color: "#31342B"
        border.width: 3
        bottomLeftRadius: 0
        bottomRightRadius: 0
        topLeftRadius: 32
        topRightRadius: 32
        opacity: 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        // Sobald die Animation das Fenster vollständig ausgeblendet hat,
        // wird visible auf false gesetzt, um Mausklicks nicht zu blockieren.
        onOpacityChanged: {
            if (opacity === 0.0) {
                osdWindow.visible = false
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
                color: osdWindow.isMuted ? "#ff5545" : "#ffffff"
                text: osdWindow.isMuted ? "󰝟" : (osdWindow.volumeLevel > 50 ? "󰕾" : "󰖀")
            }

// Fortschrittsbalken (Background)
            Rectangle {
                width: 130
                height: 10
                radius: 5
                color: "#282828"
                anchors.verticalCenter: parent.verticalCenter


                // 1. Standard-Balken (0 % bis 100 %)
                Rectangle {
                    // Stoppt die Breite bei max. 100 % der Lautstärke
                    width: parent.width * (Math.min(osdWindow.volumeLevel, 100) / 100)
                    height: parent.height
                    radius: 5
                    color: osdWindow.isMuted ? "#ff5545" : "#FE7446"

                    Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                // 2. Überlap-Balken (101 % bis 200 %)
                Rectangle {
                    // Startet erst ab 100 % und wächst von 0 bis 100 % Lautstärke-Überschuss
                    width: osdWindow.volumeLevel > 100
                           ? parent.width * (Math.min(osdWindow.volumeLevel - 100, 100) / 100)
                           : 0
                    height: parent.height
                    radius: 5
                    color: "#6167AD" // Akzentfarbe für den Boost
                    visible: !osdWindow.isMuted && osdWindow.volumeLevel > 100

                    Behavior on width {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }

	    Text {
		width: 24 // Bietet genug Platz für bis zu "200%"
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 14
                font.bold: true
                color: "#ffffff"
                text: osdWindow.volumeLevel + "%"
            }
        }
    }
}
