import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking

Scope {
    // 1. Hauptzugriff auf das Singleton-Objekt Networking
    // Networking.devices ist ein ObjectModel aller erkannten Netzwerkkarten
    
    ColumnLayout {
        spacing: 8

        Repeater {
            // Wir binden das Modell direkt an Networking.devices
            model: Networking.devices

            delegate: RowLayout {
                required property NetworkDevice modelData
                spacing: 10

                // Icon / Schnittstellenname (z. B. wlan0, eth0)
                Text {
                    text: modelData.name
                    color: "white"
                    font.bold: true
                }

                // Statusanzeige (z. B. Connected, Disconnected)
                Text {
                    text: {
                        switch (modelData.state) {
                            case NetworkDeviceState.Connected: return "Verbunden"
                            case NetworkDeviceState.Connecting: return "Verbinde..."
                            case NetworkDeviceState.Disconnected: return "Getrennt"
                            default: return "Unbekannt"
                        }
                    }
                    color: modelData.state === NetworkDeviceState.Connected ? "#4CAF50" : "#888888"
                }

                // Falls es ein WLAN-Gerät ist, SSID anzeigen
                Text {
                    visible: modelData.type === NetworkDeviceType.Wifi
                    text: modelData.connectedAccessPoint ? modelData.connectedAccessPoint.ssid : "Kein AP"
                    color: "#AAA"
                }
            }
        }
    }
}
