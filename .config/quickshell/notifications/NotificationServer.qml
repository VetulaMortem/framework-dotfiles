import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts

Scope {
	// Funktion zum Mappen von App-Namen
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
		if(notification.summary == "debug"){
			notification.Retainable.lock();
		}
		console.log(notification.Retainable.retained);
        }
    }

    PanelWindow {
        id: popupWindow

        //exclusionMode: ExclusionMode.Ignore
        
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
            model: notificationServer.trackedNotifications

            delegate: Rectangle {
                required property Notification modelData

                width: 300
                height: colLayout.implicitHeight + 20
                color: "#BB2A39"
		border.color: "#31342B"
                border.width: 3
                radius: 8

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
                            color: "#5CBD88"
                            font.bold: true
                            font.pixelSize: 12
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Text {
                            text: "✕"
                            color: "#FE7446"
                            font.bold: true
                            
                            MouseArea {
                                anchors.fill: parent
                                onClicked: modelData.dismiss()
                            }
                        }
                    }

                    Text {
			    text: getNiceMessage(modelData.appName,modelData.summary,modelData.body)
                        color: "#ffffff"
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
                    onTriggered: modelData.expire()
		} 
            }
        }
    }
}	
