import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import ".."
Scope {
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

        
        exclusionMode: ExclusionMode.Normal
        // Das Fenster öffnet/schließt sich über den globalen StateStore
        visible: StateStore.notificationCenterOpen

        anchors {
            top: true
            right: true
            bottom: true
        }
        margins.top: 5    // Platz oben (z.B. für deine Bar)
        margins.right: 5
        margins.bottom: 5

        implicitWidth: 450
        color: "transparent"
	Rectangle {
		anchors.fill: parent
		color: Theme.background
		border.color: Theme.border
		border.width: Theme.width
		radius: Theme.radius

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
				color: Theme.background
				radius: 4

				Text {
				    anchors.left: parent.left
				    anchors.leftMargin: 10
				    anchors.verticalCenter: parent.verticalCenter
				    text: getNiceAppName(section)
				    color: Theme.accent
				    font.bold: true
				    font.pixelSize: 11
				}
			    }
			    // ----------------------------------------------

			    delegate: Rectangle {
				required property Notification modelData

				width: listView.width
				height: colLayout.implicitHeight + 16
				color: Theme.background
				border.color: Theme.border
				border.width: 1
				radius: 6

				ColumnLayout {
				    id: colLayout
				    anchors.fill: parent
				    anchors.margins: 10
				    spacing: 4

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

				    Text {
					text: modelData.body
					color: Theme.textSecondary
					font.pixelSize: 12
					Layout.fillWidth: true
					wrapMode: Text.WordWrap
					visible: text !== ""
				    }
				}
			    }
			}
		    }
		}
	}
    }
}
