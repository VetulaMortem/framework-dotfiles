import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Io
import ".."
Scope {
    property bool isLocked: false
    property bool isLocking: false
    component BackImage : Image {
		id: background
		anchors.fill: parent
		anchors.margins: Theme.width
		source: "/home/vetula/.assets/eDP-1"
		cache:false
		 fillMode: Image.PreserveAspectCrop
	}
     // 2. Das Fenster (PanelWindow) direkt in derselben Datei
    Variants {
        model: Quickshell.screens

        delegate: Component {
            PanelWindow {
                required property var modelData
	WlrLayershell.layer: WlrLayer.Overlay
		    WlrLayershell.namespace: "quickshell-lock"
        exclusionMode: ExclusionMode.Ignore
                screen: modelData

		visible: isLocking

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }
                implicitHeight: 30
                color: Theme.border
		BackImage{
			id:hyprfader
		}
            }
        }
    }
Timer {
        id: delayTimer
        interval: 400 // 2000 Millisekunden = 2 Sekunden
        repeat: false  // Läuft nur einmalig durch
        onTriggered: {
		isLocked = !isLocked;
        }
    }
Timer {
        id: delayTimer2
        interval: 400
        repeat: false
        onTriggered: {
		isLocking = !isLocking;
        }
    }

Timer {
        id: delayTimer3
        interval: 1000
        repeat: false
        onTriggered: {
		isLocking = !isLocking;
        }
    }
    WlSessionLock {
        id: sessionLock
        locked: isLocked

        surface: WlSessionLockSurface {
            LockContent {
                anchors.fill: parent
                onUnlockSuccess: {
			isLocking = true
			delayTimer2.restart();
			delayTimer.restart();
                }
            }
        }
    }

    component LockContent: Rectangle {
	    id: root

        color: Theme.background
	border.color: Theme.border
	border.width: Theme.width
	signal unlockSuccess()
	BackImage {
	id:real
	}
        PamContext {
            id: pam

	    onPamMessage: ()=> {
		if(pam.message.length == 10){
			statusText.text = "Entering Password"
		}
		else{

		statusText.text = pam.message;
		}
            }

	    onCompleted: result => {
                if (result === PamResult.Success) {
                    statusText.text = "Erfolgreich!";
		    root.unlockSuccess();
                    pam.abort();
                } else {
                    statusText.text = "Falsches Passwort! Noch einmal:";
                    passwordInput.text = "";
                    pam.abort();
                    pam.start();
                }
	    }
        }

        // Sobald diese Komponente geladen wird, holen wir den Fokus direkt aufs Eingabefeld
	Component.onCompleted: {
            passwordInput.forceActiveFocus();
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 20
            width: 350

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatTime(clock.date, "hh:mm")
                color: Theme.text
                font.pixelSize: 64
                font.bold: true
            }

            Text {
                id: statusText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Please enter Password"
                color: Theme.accent
                font.pixelSize: 16
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                TextInput {
                    id: passwordInput
                    anchors.centerIn: parent
                    width: 300
                    height: 45
                    color: Theme.text
                    font.pixelSize: 18
                    echoMode: TextInput.Password
                    focus: true
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 15
                    rightPadding: 15

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        color: Theme.alternate
                        radius: Theme.radius
                        border.color: passwordInput.activeFocus ? Theme.primary : Theme.border
                        border.width: Theme.width
                    }

                    onAccepted: {
			    if(text == ""){
				    console.log("Start");
				    pam.start();
				    console.log("Middle");
				    pam.respond(" ");
				    console.log("End");
			    }
			    else{
				pam.respond(text);
			    }
		    }
		    onTextEdited: {
			pam.start();
		    }
                }
            }
	MediaControlWidget { }
        }
	}

    IpcHandler {
        target: "lockscreen"

        function lock(): void {
		if(!isLocked){
			isLocking = true;
			delayTimer.restart();
			delayTimer3.restart();
                }
        }     
    	function forceUnlock(): void {
		isLocked = false;
	}
    }
}
