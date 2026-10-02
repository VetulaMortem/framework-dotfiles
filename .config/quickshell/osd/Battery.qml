//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: osdCharge

    implicitWidth: thetext.implicitWidth+30
    implicitHeight: 40
    color: "transparent"

    // Verhindert das Verschieben von Fenstern
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-osdCharge"
    // Das Fenster startet komplett unsichtbar
    visible: false

    Timer {
        id: hideTimer
        interval: 1500
        repeat: false
        onTriggered: {
        	osdCharge.visible = false
        }
    }
Process {
            id: getPlugstate
            command: ["cat", "/sys/class/power_supply/ACAD/online"]
            running: true

            property int powerstate:-1
            property int triggersleep:-1
            stdout: SplitParser {
		    onRead: data => {
			    getPlugstate.powerstate = data.trim()
			if(data.trim() == 1 && getPlugstate.triggersleep != 1){
				osdCharge.visible = true
				hideTimer.start()
				getPlugstate.triggersleep=1
			}
			else{
				if(data.trim() == 0){
					getPlugstate.triggersleep=0
				}
			}
                }
            }
        }


    Timer {
        id: pollTimer
        interval: 150
	running: true
	repeat: true
	onTriggered: {
		getPlugstate.running = true
	}
    }

    Rectangle {
        id: contentBox
        anchors.fill: parent
        color: "#BB2A39"
        border.color: "#31342B"
        border.width: 3
        bottomLeftRadius: 32
        bottomRightRadius: 32
        topLeftRadius: 32
        topRightRadius: 32
        opacity: 1.0

        Row {
            anchors.centerIn: parent
            spacing: 0

	    Text {
		id: thetext
                horizontalAlignment: Text.AlignCenter
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 22
                color:  "#ffffff"
                text: "󱐋 Charging..."
            }
        }
    }
}
