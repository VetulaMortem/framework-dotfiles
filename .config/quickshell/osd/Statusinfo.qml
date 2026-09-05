//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."
PanelWindow {
    id: osdInfo

    implicitWidth: thetext.implicitWidth == 0 ? 0 : thetext.implicitWidth + 10
    implicitHeight: thetext.implicitHeight == 0 ? 0 : thetext.implicitHeight + 10
    color: "transparent"
anchors {
        left: true
        bottom: true
    }
    // Verhindert das Verschieben von Fenstern
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-osdInfo"
    // Das Fenster startet komplett unsichtbar

    property bool isMuted: AudioStore.isMuted
Process { id: termExec }
Process {
            id: getCapslockstate
            command: ["cat","/sys/class/leds/input2::capslock/brightness"]
            property int buttonstate:-1
            stdout: SplitParser {
		    onRead: data => {
			    getCapslockstate.buttonstate = data.trim()
                }
            }
        }
    Timer {
        id: pollTimer
        interval: 150
	running: true
	repeat: true
	onTriggered: {
		getCapslockstate.running= true
	}
    }
    Rectangle {
        id: capslockBox
        anchors.fill: parent
	anchors.leftMargin: -3
	anchors.bottomMargin: -3
        color: "#BB2A39"
        border.color: "#31342B"
        border.width: 3
        bottomLeftRadius: 0
        bottomRightRadius: 0
        topLeftRadius: 0
        topRightRadius: 32
        opacity: 1.0

        Row {
	    id: thetext
            anchors.centerIn: parent
            spacing: 5

	    Text {
		id: muteToggle
		visible: true
                horizontalAlignment: Text.AlignCenter
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 22
                color:  "#ffffff"
		text: (isMuted ? "󰝟" : "")
		MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            termExec.command = ["wpctl","set-mute","@DEFAULT_SINK@","0"]
                            termExec.running = true
                        }
                    }
            }
	    Text {
		id: capsLock
		visible: true
                horizontalAlignment: Text.AlignCenter
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono NF"
                font.pixelSize: 22
                color:  "#ffffff"
                text: (getCapslockstate.buttonstate == 1 ? "󰘲" : "")
            }
        }
    }



}
