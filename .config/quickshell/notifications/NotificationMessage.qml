// NotificationPopups.qml
import Quickshell
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
Scope {
    // Hier als 'var' deklarieren, da es sich um ein Quickshell-Modell handelt
    required property var notificationsModel

    // Test-Debug, ob das Model hier ankommt:
    Component.onCompleted: {
        console.log("Model in NotificationPopups angekommen:", notificationsModel);
    }

        
        PanelWindow {
            required property Notification modelData
            exclusionMode: ExclusionMode.Ignore
            
            anchors { top: true; right: true }
            margins.top: 20
            margins.right: 20
            
            implicitWidth: 300
            implicitHeight: 100
            color: "#1e1e2e"
            visible: true

            Text {
                anchors.centerIn: parent
                text: modelData.summary
                color: "white"
            }
        }
}
