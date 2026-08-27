//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower


PanelWindow {
    id: root


    visible: {
	if (Hyprland.focusedWorkspace.toplevels.values.length != 1){
	     	
	     return true
	}
	return false
    }
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 38
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: 38

    // Gemeinsame Style-Eigenschaften für alle Inseln
    component Island : Rectangle {
        color: "#BB2A39"       // Dunkler, warmes Rot/Braun-Ton
        border.color: "#31342B" // Roter Rahmen
        border.width: 4
	bottomLeftRadius: 32
	bottomRightRadius: 32
	topLeftRadius: 0
	topRightRadius: 0
        height: 41

        // Abstand vom oberen Bildschirmrand
        anchors.top: parent.top
        anchors.topMargin: -4
    }


    // 1. LINKE INSEL (Workspaces)
    Island {
        id: leftIsland
        anchors.left: parent.left
        anchors.leftMargin: 0
	width: workspaceRow.implicitWidth + 40

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 0 // Gleicht den abgeschnittenen oberen Rand aus
            spacing: 8

            // Geht durch die Workspaces 1 bis 10 (oder deine gewünschte Anzahl)
            Repeater {
                model: 10

                Rectangle {
                    required property int index
                    property int wsId: index + 1
                    // Prüft, ob dieser Workspace der aktuell aktive ist
                    property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
		    // Prüft, ob auf dem Workspace Fenster liegen
                    property bool isOccupied: {
			for (var i = 0;i < Hyprland.workspaces.values.length;i++){
				if(Hyprland.workspaces.values[i].id === wsId){
					return Hyprland.workspaces.values[i].toplevels.values.length > 0 ? true : false
				}
		        }
		    }
                    // Dynamische Form: Aktiver Workspace wird eine längere "Pille", inaktive bleiben runde Dots
                    width: isActive ? 32 : 12
                    height: 12
                    radius: 8

                    // Farbanpassung: Aktiv = Hellrot, Belegt = Weiß/Rosa, Leer = Dunkler Dot
                    color: isActive ? "#FE7446" : (isOccupied ? "#5CBD88" : "#282828")

                    // Animation für den Wechsel der Breite (Pill-Effekt)
                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    // Klick-Event zum Wechseln des Workspaces
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + "})")
                    }
                }
            }
        }
    }

    // 2. MITTLERE INSEL (Uhrzeit)
    Island {
        id: centerIsland
        anchors.horizontalCenter: parent.horizontalCenter
	width: clockRow.implicitWidth + 28

	// Status-Variablen für SwayNC
        property bool dndActive: false
	property int count: 0

	// Prozess zum Abfragen des Status (JSON-Format von swaync-client)

	Process {
            id: swayncStatus
            command: ["swaync-client", "-s"]
            running: true

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    let cleaned = data.trim()
                    if (cleaned.length > 0) {
                        try {
                            let json = JSON.parse(cleaned)
                            // "dnd" ist ein Boolean, "count" liefert die Anzahl der ungelesenen Notifications
                            centerIsland.dndActive = json.dnd ?? false
                            centerIsland.count = json.count ?? 0
                        } catch(e) {}
                    }
                }
            }
        }
	Process {
	    id: swayncExec
    	}
	Process {
	    id: bluetooth
    }
    // Funktion zum Aktualisieren des Status
        function updateSwayNc() {
            swayncStatus.running = true
        }
        // SystemClock liefert die aktuelle Zeit
        SystemClock {
            id: clock
            precision: SystemClock.Minutes // Reicht völlig für "HH:mm"
        }
	Row {
		    id: clockRow
		    anchors.centerIn: parent
		    anchors.verticalCenterOffset: 0
		    spacing: 8

		    // Uhrzeit & Datum
		    Text {
			font.family: "JetBrainsMono NF"
			font.pixelSize: 16
			font.bold: true
			color: "#ffffff"
			text: Qt.formatDateTime(clock.date, "MMM dd  HH:mm")
		    }

		    // Glocken-Icon für SwayNC
		    Text {
			font.family: "JetBrainsMono NF"
			font.pixelSize: 16
			
			// Farbe: Rot bei ungelesenen Nachrichten, ausgegraut bei DND, sonst Weiß>>
			color: centerIsland.count > 0 ? "#ff5545" : (centerIsland.dndActive ? "#888888" : "#ffffff")
			
			// Icon-Wechsel je nach Status:
			// 󰂛 = DND / Stumm
			// 󱅫 = Neue Benachrichtigungen
			// 󰂚 = Normal
			text: centerIsland.dndActive ? "󰂛" : (centerIsland.count > 0 ? "󱅫" : "󰂚")


			// Klick-Logik für SwayNC
			MouseArea {
			    anchors.fill: parent
			    cursorShape: Qt.PointingHandCursor
			    acceptedButtons: Qt.LeftButton | Qt.RightButton

			    onClicked: (mouse) => {
				if (mouse.button === Qt.LeftButton) {
				    // Linksklick: Notification Center öffnen/schließen
				    swayncExec.command = ["swaync-client", "-t", "-sw"]
				} else if (mouse.button === Qt.RightButton) {
				    // Rechtsklick: Do Not Disturb umschalten
				    swayncExec.command = ["swaync-client", "-d", "-sw"]
			    	}
				swayncExec.running = true
                        
                        // Status kurz nach dem Klick neu abfragen
                        centerIsland.updateSwayNc()

			    }
			}
		    }
		}
	    }

    // 3. RECHTE INSEL (System-Tray)
    Island {
        id: rightIsland
        anchors.right: parent.right
        anchors.rightMargin: 0
        width: trayRow.implicitWidth + 32

// 1. PACMAN UPDATES PROZESS
    Process {
        id: updateProc
        // Prüft ausstehende Updates (checkupdates ist Teil von pacman-contrib)
        command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: true

        property int updateCount: 0

        stdout: SplitParser {
            onRead: data => {
                let count = parseInt(data.trim()) || 0
                updateProc.updateCount = count
            }
        }
    }

    // Timer: Alle 30 Minuten Updates prüfen
    Timer {
        interval: 18000
        running: true
        repeat: true
        onTriggered: updateProc.running = true
    }

    // 2. POWER PROFILE PROZESS
    Process {
        id: powerProfileProc
        command: ["powerprofilesctl", "get"]
        running: true

        property string currentProfile: "balanced"

        stdout: SplitParser {
            onRead: data => {
                let profile = data.trim()
                if (profile.length > 0) {
                    powerProfileProc.currentProfile = profile
                }
            }
        }
    }
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: powerProfileProc.running = true
    }

    Process {
        id: powerProfileSetExec
    }


// Lautstärke Anzeige & Pavucontrol Launcher
            Process {
                id: volumeProc
                // Fragt die Lautstärke von WirePlumber ab
                command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
                running: true

                property int volumePercent: 0
                property bool isMuted: false

                stdout: SplitParser {
                    onRead: data => {
                        let str = data.trim()
                        volumeProc.isMuted = str.includes("[MUTED]")
                        let match = str.match(/Volume:\s+([0-9.]+)/)
                        if (match) {
                            volumeProc.volumePercent = Math.round(parseFloat(match[1]) * 100)
                        }
                    }
                }
            }

// Timer: Fragt die Lautstärke jede Sekunde neu ab
            Timer {
                interval: 100
                running: true
                repeat: true
                onTriggered: {
                    volumeProc.running = true
                }
            }

            // Prozess zum Starten von Pavucontrol
            Process {
                id: pavucontrolExec
                command: ["pavucontrol"]
            }
	


        Row {
            id: trayRow
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 0
            spacing: 10

		
	    Row {
                spacing: 4
                visible: updateProc.updateCount > 0 // Nur sichtbar wenn Updates da sind

                Text {
                    font.family: "JetBrainsMono NF"
                    font.pixelSize: 16
                    color: "#5CBD88" // Sanftes Gelb/Orange für Updates
                    text: "󰏔"
                MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
                    Process { id: termExec }
                    onClicked: {
                        // Öffnet dein Terminal für den Update-Befehl
                        termExec.command = ["kitty","--class","update","-o","background_opacity=1.0","-e","/home/vetula/.config/hypr/scripts/update_system.sh"]
                        termExec.running = true
                    }
                }
                }

                Text {
                    font.family: "JetBrainsMono NF"
                    font.pixelSize: 16
                    font.bold: true
                    color: "#ffffff"
                    text: updateProc.updateCount.toString()
                }

            }


            Repeater {
                model: SystemTray.items
                IconImage {
                    id: iconImg
		    required property SystemTrayItem modelData

                    source: modelData.icon
                    implicitWidth: 20
                    implicitHeight: 20

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        cursorShape: Qt.PointingHandCursor

                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                // Linksklick: Primäre Aktion ausführen
                                modelData.activate()
                            } else if (mouse.button === Qt.RightButton) {
                                // Rechtsklick: Menü öffnen falls vorhanden, sonst Sekundäraktion
				if (modelData.hasMenu) {
				    let globalPos = iconImg.mapToItem(null, 0, 0)

                                    modelData.display(root, globalPos.x, root.height)
                                } else {
                                    modelData.secondaryActivate()
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                // Tertiäraktion (falls vom Applet unterstützt)
                                modelData.secondaryActivate()
                            }
                        }
                    }
                }
	    }
		Row {
			spacing: 4
			Text {

                        font.family: "JetBrainsMono NF"
                        font.pixelSize: 16
                    font.bold: true
                    color: "#6167AD"
                    text: ""

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        bluetooth.command = ["blueberry"]
                        bluetooth.running = true
                    }
                }
			}
		}	
	// Akku-Anzeige via UPower
                Row {
                    spacing: 4
                    // UPower.displayDevice liefert den Hauptakku des Systems
                    visible: UPower.displayDevice !== null && UPower.displayDevice.isPresent

                    property var device: UPower.displayDevice

                    // Icon basierend auf Status & Prozent
                    Text {
                        font.family: "JetBrainsMono NF"
                        font.pixelSize: 16
                        
                        // Grün beim Laden, Rot unter 20%, sonst Weiß
                        color: parent.device.state === UPowerDeviceState.Charging ? "#a6e3a1" : 
                               (parent.device.percentage <= 0.2 ? "#ff5545" : "#ffffff")

                        text: {
                            if (parent.device.state === UPowerDeviceState.Charging) return "󰂄"
                            let p = parent.device.percentage
                            if (p > 0.9) return "󰁹"
                            if (p > 0.7) return "󰂀"
                            if (p > 0.5) return "󰁾"
                            if (p > 0.3) return "󰁼"
                            if (p > 0.1) return "󰁺"
                            return "󰂎"
                        }
                    }

                    // Prozent-Text
                    Text {
                        font.family: "JetBrainsMono NF"
                        font.pixelSize: 16
                        font.bold: true
                        color: "#ffffff"
                        text: Math.round(parent.device.percentage * 100) + "%"
                    }
	    }

	    // Icon + Prozent Text
            Row {
                spacing: 4

                Text {
                    font.family: "JetBrainsMono NF"
                    font.pixelSize: 16
                    color: volumeProc.isMuted ? "#ff5545" : "#ffffff"
                    text: volumeProc.isMuted ? "󰝟" : (volumeProc.volumePercent > 50 ? "󰕾" : "󰖀")



		    MouseArea {
			    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        // Öffnet Pavucontrol bei Klick
                        pavucontrolExec.running = true
                    }
                }

	    	}

                Text {
                    font.family: "JetBrainsMono NF"
                    font.pixelSize: 16
                    font.bold: true
		    color: (volumeProc.volumePercent > 100 ? "#000000" : "#ffffff")
		    text: volumeProc.volumePercent + "%"
                }
            }

	Text {
                font.family: "JetBrainsMono NF"
                font.pixelSize: 16
                
                // Icon & Farbe je nach Profil
                color: {
                    switch (powerProfileProc.currentProfile) {
                        case "performance": return "#6167AD"
                        case "power-saver": return "#5CBD88"
                        default: return "#ffffff"
                    }
                }

                text: {
                    switch (powerProfileProc.currentProfile) {
                        case "performance": return "󰓅"
                        case "power-saver": return "󰾆"
                        default: return "󰾅"
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        let nextProfile = "balanced"
                        if (powerProfileProc.currentProfile === "balanced") {
                            nextProfile = "performance"
                        } else if (powerProfileProc.currentProfile === "performance") {
                            nextProfile = "power-saver"
                        } else {
                            nextProfile = "balanced"
                        }

                        // Profil umschalten & Status neu laden
                        powerProfileSetExec.command = ["powerprofilesctl", "set", nextProfile]
                        powerProfileSetExec.running = true
                        powerProfileProc.running = true
                    }
                }
            }

        }
    }
}
