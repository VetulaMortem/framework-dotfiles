import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import ".."
Scope {
    id: root

    // Eigenschaft für die aktuelle Helligkeit in Prozent (0 - 100)
    property int brightnessPercent: 0
    property int maxBrightness: 100
    property int currentBrightness: 0
    property bool isVisible: true

    // Timer zum Ausblenden nach 5 Sekunden
    Timer {
        id: hideTimer
        interval: 1500
        running: false
        repeat: false
        onTriggered: {
            root.isVisible = false
        }
    }

    // Prozess zum Auslesen der Helligkeit (verwendet brightnessctl)
    // Alternativ kann hier auch ein FileView auf /sys/class/backlight/... verwendet werden.
    Process {
        id: brightnessProcess
        // Liest den aktuellen und maximalen Wert aus (z.B. via brightnessctl)
        command: ["sh", "-c", "/home/vetula/.assets/getBrightnessPercentage.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                // Der erste Wert ist current, der zweite ist max
		let lines = data.trim().split(" ");
                if (lines.length >= 2) {
                    let cur = parseInt(lines[0]);
		    let max = parseInt(lines[1]);
		    root.currentBrightness = cur;
		    root.maxBrightness = max;
                    
                    if (!isNaN(cur) && !isNaN(max) && max > 0) {
                        let percent = Math.round((cur / max) * 100);
                        
                        // Wenn sich die Helligkeit geändert hat -> Overlay anzeigen & Timer neustarten
                        if (percent !== root.brightnessPercent) {
                            root.brightnessPercent = percent;
                            root.isVisible = true;
                            hideTimer.restart();
                        }
                    }
                }
            }
        }
    }

    // Timer, der regelmäßig (z.B. alle 500ms) die Helligkeit abfragt
    Timer {
        interval: 500
        running: true
        repeat: true
        onTriggered: {
            brightnessProcess.running = true
        }
    }

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


    visible: root.isVisible

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

        Row {
            anchors.centerIn: parent
            spacing: 14

            Text {
                width: 8
                horizontalAlignment: Text.AlignRight
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 22
                color: Theme.text
                text: ""
            }

            Rectangle {
                width: 130
                height: 10
                radius: 5
                color: Theme.alternate
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    width: parent.width * (Math.min(root.brightnessPercent, 100) / 100)
                    height: parent.height
                    radius: 5
                    color: Theme.accent

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
                text: root.brightnessPercent + "%"
            }
        }
    }
}
}
