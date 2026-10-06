import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import ".."
Scope {
    function removeMessage(rawMessage) {
	StateStore.newMessages = Array.from(StateStore.newMessages).filter(r => r !== rawMessage)
	StateStore.centerMessages = Array.from(StateStore.centerMessages).filter(r => r !== rawMessage)
    }
    function realDismiss(rawMessage) {
	StateStore.newMessages = Array.from(StateStore.newMessages).filter(r => r !== rawMessage)
	rawMessage.dismiss();
	StateStore.centerMessages = Array.from(StateStore.centerMessages).filter(r => r !== rawMessage)
    }
    // Helferfunktion für schöne App-Namen (falls du sie hier auch brauchst)
    function getNiceAppName(rawName) {
        var nameMap = {
            "org.mozilla.firefox": "Firefox",
            "firefox": "Firefox",
            "discord": "Discord",
            "spotify": "Spotify",
            "kitty": "Terminal"
        };
        return nameMap[rawName] !== undefined ? nameMap[rawName] : rawName;
    }

    PanelWindow {
        id: centerWindow

	WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notificationCenter"
        exclusionMode: ExclusionMode.Normal
        // Das Fenster öffnet/schließt sich über den globalen StateStore
        visible: StateStore.notificationCenterOpen

        anchors {
            top: true
            right: true
            bottom: true
        }
        margins.top: 0    // Platz oben (z.B. für deine Bar)
        margins.right: 0 - Theme.width
        margins.bottom: 0

        implicitWidth: 450
        color: "transparent"
	Rectangle {
		anchors.fill: parent
		color: Theme.primaryTransparent
		border.color: Theme.border
		border.width: Theme.width
        	bottomLeftRadius: Theme.radius * 2
        	topLeftRadius: Theme.radius * 2

		ColumnLayout {
		    anchors.fill: parent
		    anchors.margins: 15
		    spacing: 12
		    // Kopfzeile des Notification Centers
		    RowLayout {
			Layout.fillWidth: true
			Text {
			    text: "Benachrichtigungen"
			    color: Theme.text
			    font.bold: true
			    font.pixelSize: 16
			}

			Item { Layout.fillWidth: true }
			Switch {
			    id: dndSwitch
			    checked: StateStore.doNotDisturb
			    onToggled: StateStore.doNotDisturb = checked

			    // Die Schiene (Hintergrund des Schalters)
			    indicator: Rectangle {
				implicitWidth: 44
				implicitHeight: 24
				x: parent.leftPadding
				y: parent.height / 2 - height / 2
				radius: Theme.radius * 4
				// Farbe wechselt dynamisch je nach Zustand
				color: dndSwitch.checked ? Theme.accent : Theme.secondaryTransparent
				border.color: Theme.border
				border.width: 1

				// Der Schieberegler (Knopf)
				Rectangle {
				    id: handle
				    // Animate oder positioniere den Knopf links oder rechts
				    x: dndSwitch.checked ? parent.width - width - 4 : 4
				    y: (parent.height - height) / 2
				    width: 16
				    height: 16
				    radius: Theme.radius
				    color: dndSwitch.checked ? Theme.background : Theme.text

				    // Optional: Macht das Verschieben butterweich
				    Behavior on x {
					NumberAnimation { duration: 150 }
				    }
				}
			    }
			}
			// Schließen-Button oder "Alle löschen"
			Text {
			    text: "✕"
			    color: Theme.text
			    font.bold: true
			    font.pixelSize: 14

			    MouseArea {
				anchors.fill: parent
				onClicked: StateStore.notificationCenterOpen = false
			    }
			}
		    }

		    // Trennlinie
		    Rectangle {
			Layout.fillWidth: true
			height: 1
			color: Theme.border
		    }

		    // Scrollbare Liste mit App-Gruppierung
		    ScrollView {
			Layout.fillWidth: true
			Layout.fillHeight: true
			clip: true

			ListView {
			    id: listView
			    width: parent.width
			    model: StateStore.centerMessages
			    spacing: 8

			    // --- AUTOMATISCHE GRUPPIERUNG NACH APP-NAME ---
			    section.property: "appName"
			    section.criteria: ViewSection.FullString
			    section.delegate: Rectangle {
				width: listView.width
				height: 28
				color: "transparent"
				radius: 4

				Text {
				    anchors.left: parent.left
				    anchors.leftMargin: 10
				    anchors.verticalCenter: parent.verticalCenter
				    text: getNiceAppName(section)
				    color: Theme.text
				    font.bold: true
				    font.pixelSize: 11
				}
			    }
			    // ----------------------------------------------
			delegate: Rectangle {
			    required property Notification modelData
			    property Notification henry : modelData
			    width: listView.width
			    height: colLayout.implicitHeight + 16
			    color: Theme.secondary
			    border.color: Theme.border
			    border.width: Theme.width
			    radius: 6

			    ColumnLayout {
				id: colLayout
				anchors.fill: parent
				anchors.margins: 10
				spacing: 4

				// Zeile 1: Summary und Löschen-Button
				RowLayout {
				    Layout.fillWidth: true
				    
				    Text {
					text: modelData.summary != "" ? modelData.summary : "ERROR"
					color: Theme.text
					font.bold: true
					font.pixelSize: 13
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
				    }

				    Text {
					text: "🗑"
					color: Theme.text
					font.pixelSize: 11
					
					MouseArea {
					    anchors.fill: parent
					    onClicked: realDismiss(modelData)
					}
				    }
				}

				// Zeile 2: Body Text (falls vorhanden)
				Text {
				    text: modelData.body
				    color: Theme.text
				    font.pixelSize: 12
				    Layout.fillWidth: true
				    wrapMode: Text.WordWrap
				    visible: text !== ""
				}

				// Zeile 3: Aktionen / Buttons (nur anzeigen, wenn actions vorhanden sind)
				Flow {
				    Layout.fillWidth: true
				    spacing: 6
				    visible: modelData.actions.length > 0

				    Repeater {
					model: modelData.actions

					delegate: Rectangle {
					    // modelData ist hier das einzelne Action-Objekt
					    // (abhängig von der Version evtl. .text oder .name verwenden)
					    property var actionObject: modelData 

					    width: actionText.implicitWidth + 20
					    height: 24
					    color: Theme.primary // Passe dies an dein Theme an
					    border.color: Theme.border
					    border.width: 1
					    radius: 4

					    Text {
						id: actionText
						text: actionObject.text ?? actionObject.name ?? "Action"
						color: Theme.text
						font.pixelSize: 11
						anchors.centerIn: parent
					    }

					    MouseArea {
						anchors.fill: parent
						onClicked: {
						    // Aktion ausführen (je nach Quickshell-Version 
						    // entfallen Aufrufe direkt über das Notification-Objekt
						    // oder via NotificationManager)
						    actionObject.invoke?.(); 
						    removeMessage(henry);
						    // Alternativ, falls dein Notification-Modell eine Funktion anbietet:
						    // modelData.invokeAction(actionObject.id);
						}
					    }
					}
				    }
				}
			    }
			}
			}
		    }
		}
	}
    }
}
