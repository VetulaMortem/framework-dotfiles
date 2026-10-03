import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import ".."
Scope {
	// Funktion zum Mappen von App-Namen
function realDismiss(rawMessage) {
	StateStore.centerMessages = Array.from(StateStore.centerMessages).filter(r => r !== rawMessage)
	rawMessage.dismiss();
	StateStore.newMessages = Array.from(StateStore.newMessages).filter(r => r !== rawMessage)
}
function getNiceAppName(rawName) {
    if (!rawName || rawName === "") return "System";

    // Deine Mapping-Liste: "Technischer Name": "Schöner Name"
    var nameMap = {
        "org.mozilla.firefox": "Firefox",
        "firefox": "Firefox",
        "discord": "Discord",
        "spotify": "Spotify",
        "org.gnome.Nautilus": "Dateimanager",
	"kitty": "Terminal",
	"notify-send": "System"
        // Hier kannst du beliebig weitere hinzufügen...
    };
    // Gibt den gemappten Namen zurück, oder den Originalnamen, falls kein Eintrag existiert
    return nameMap[rawName] !== undefined ? nameMap[rawName] : rawName;
}
function getNiceMessage(rawApp,rawSummary,rawBody) {
	if (rawSummary == "debug") return StateStore.newMessages.length;
	if (rawBody != "") return rawBody;
	else return rawSummary;
}
	NotificationServer {
        id: notificationServer
        keepOnReload: true
	property var notificationCount: trackedNotifications.values.length
        onNotification: (notification) => {
		console.log("Neue Notification von: " + notification.summary);
		notification.tracked = true;
		StateStore.newMessages.push(notification);
		StateStore.centerMessages.push(notification);
		if(notification.summary == "debug"){
		}
		console.log(notification.Retainable.retained);
        }
    }

    PanelWindow {
        id: popupWindow

        exclusionMode: ExclusionMode.Normal
        
        anchors {
            top: true
            right: true
        }
        margins.top: 5
        margins.right: 5
        
        implicitWidth: 300
        // Höhe passt sich sauber an den Inhalt der Liste an (+ etwas Padding)
        implicitHeight: listView.contentHeight > 0 ? listView.contentHeight + 20 : 0
        color: "transparent"
        
        visible: notificationServer.notificationCount > 0

        ListView {
            id: listView
            width: 300
            // WICHTIG: Kein anchors.fill: parent, sondern Höhe an Inhalt koppeln!
            height: contentHeight
            spacing: 10
            model: StateStore.newMessages

            delegate: Rectangle {
                required property Notification modelData

                width: 300
                height: colLayout.implicitHeight + 20
                color: Theme.background
		border.color: Theme.border
                border.width: Theme.width
                radius: Theme.radius

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: dismissTimer.stop()
                    onExited: dismissTimer.restart()
                }

                ColumnLayout {
                    id: colLayout
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: getNiceAppName(modelData.appName)
                            color: Theme.primary
                            font.bold: true
                            font.pixelSize: 12
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "✕"
                            color: Theme.accent
                            font.bold: true
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: realDismiss(modelData)
                            }
                        }
                    }

                    Text {
			    text: getNiceMessage(modelData.appName,modelData.summary,modelData.body)
                        color: Theme.text
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                    }
                }

                Timer {
                    id: dismissTimer
                    interval: modelData.expireTimeout > 0 ? modelData.expireTimeout : 5000
                    running: true
                    repeat: false
                    onTriggered: StateStore.newMessages = Array.from(StateStore.newMessages).filter(r => r !== modelData)

		} 
            }
        }
    }
}	
