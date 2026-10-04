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
import Quickshell.Services.UPower
import Quickshell.Services.Pipewire
import Quickshell.Networking
import ".."
PanelWindow {
	id: root

	property int volumeLevel: AudioStore.volumeLevel
	property bool isMuted: AudioStore.isMuted

Process {
        id: floatingcounter
        // Nutzt die ID des aktiven Workspaces
        command: ["/home/vetula/.scripts/floatingcounter.sh", Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id.toString() : "1"]
        running: true
        property int count: 0

        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim())
                floatingcounter.count = isNaN(val) ? 0 : val
            }
        }
    }

    Connections {
        target: Hyprland

        function onRawEvent(event) {
            // event.name contains the event type (e.g., "workspace", "activewindow")
            // event.data contains the event context/arguments
            // print("Hyprland event: " + event.name + " -> " + event.data);
            if (event.name === "workspace" || event.name === "activewindow" || event.name === "changefloatingmode") {
	    floatingcounter.running = true

	    }
        }
    }
    // Timer als Fallback, falls Fenster geschlossen/geöffnet werden ohne Workspace-Wechsel
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: floatingcounter.running = true
    }

    // Ausblenden, wenn exakt 1 Fenster im Workspace aktiv ist
visible: {
        return floatingcounter.count
 !== 1
    }
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 38
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: implicitHeight
    WlrLayershell.namespace: "quickshell-bar"

    // Baustein: Basis-Text für Icons & Standard-Font
    component BaseText : Text {
        font.family: "JetBrainsMono NF"
        font.pixelSize: 16
        color: Theme.text
    }

    // Gemeinsame Style-Eigenschaften für alle Inseln
    component Island : Rectangle {
        color: Theme.background
        border.color: Theme.border
        border.width: Theme.width
        bottomLeftRadius: Theme.radius * 4
        bottomRightRadius: Theme.radius * 4 
        topLeftRadius: 0
        topRightRadius: 0
        height: 41

        anchors.top: parent.top
        anchors.topMargin: -3
    }

    // Singletons für globale Shell-Execs
    Process { id: termExec }
    Process { id: bluetoothExec }
    Process { id: pavucontrolExec; command: ["pavucontrol"] }
    Process { id: powerProfileSetExec }

    // Helper-Timer, um dem System nach dem Umschalten Zeit zu geben, das Profil zu aktualisieren
    Timer {
        id: powerProfileRefreshDelay
        interval: 150
        repeat: false
        onTriggered: powerProfileProc.running = true
    }

    // ------------------------------------------------------
    // 1. LINKE INSEL (Workspaces)
    // ------------------------------------------------------
    Island {
        id: leftIsland
        anchors.left: parent.left
        width: workspaceRow.implicitWidth + 40

        Row {
            id: workspaceRow
            anchors.centerIn: parent
            spacing: 8

            Repeater {
                model: 10

                Rectangle {
			id:workspacerect
                    required property int index
                    property int wsId: index + 1
                    property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
                    property bool isOccupied: Hyprland.workspaces.values.some(ws => ws.id === wsId && ws.toplevels.values.length > 0)
		    property bool isHovered: false
		    property string normalColor: isHovered ? Theme.secondary : isActive ? Theme.accent : (isOccupied ? Theme.primary : Theme.alternate)
                    width: isActive ? 32 : 12
                    height: 12
                    radius: 8

                    color: normalColor
                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			hoverEnabled: true
			onEntered: {
				parent.isHovered = true
			}
			onExited: {
				parent.isHovered = false
			}
			onClicked: {
				Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + "})")
			}
                    }
                }
            }
        }
    }

    // ------------------------------------------------------
    // 2. MITTLERE INSEL (Uhrzeit & Benachrichtigungen)
    // ------------------------------------------------------
    Island {
        id: centerIsland
        anchors.horizontalCenter: parent.horizontalCenter
        width: clockRow.implicitWidth + 28

        property bool dndActive: StateStore.doNotDisturb
        property int count: 0

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        Row {
            id: clockRow
            anchors.centerIn: parent
            spacing: 8

            BaseText {
                font.bold: true
                text: Qt.formatDateTime(clock.date, "MMM dd  HH:mm")
            }

            BaseText {
		    color: centerIsland.dndActive ? (StateStore.centerMessages.length > 0 ? Theme.secondary : Theme.alternate) : (StateStore.centerMessages.length > 0 ? Theme.primary : Theme.text)
                text: centerIsland.dndActive ? "󰂛" : (StateStore.centerMessages.length > 0 ? "󱅫" : "󰂚")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
			    StateStore.notificationCenterOpen = !StateStore.notificationCenterOpen;
                        } else if (mouse.button === Qt.RightButton) {
			    StateStore.doNotDisturb = !StateStore.doNotDisturb;
                        }
                    }
                }
            }
        }
    }

    // ------------------------------------------------------
    // 3. RECHTE INSEL (System Status & Tray)
    // ------------------------------------------------------
    Island {
        id: rightIsland
        anchors.right: parent.right
        width: trayRow.implicitWidth + 32
	bottomRightRadius: StateStore.notificationCenterOpen ? 0 : Theme.radius * 4 
	// Pacman Updates
        Process {
            id: updateProc
            command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
            running: true
            property int updateCount: 0

            stdout: SplitParser {
                onRead: data => {
                    updateProc.updateCount = parseInt(data.trim()) || 0
                }
            }
        }

        Timer {
            interval: 1800000 // 30 Minuten
            running: true
            repeat: true
            onTriggered: updateProc.running = true
        }

        // Power Profile
        Process {
            id: powerProfileProc
            command: ["powerprofilesctl", "get"]
            running: true
            property string currentProfile: "balanced"

            stdout: SplitParser {
                onRead: data => {
                    let profile = data.trim()
                    if (profile.length > 0) powerProfileProc.currentProfile = profile
                }
            }
        }

        Timer {
            interval: 30000
            running: true
            repeat: true
            onTriggered: powerProfileProc.running = true
        }

        // Lautstärke: Realtime Event-Listener via pw-mon / wpctl

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 10

            // Pacman Updates
            Row {
                spacing: 4
                visible: updateProc.updateCount > 0
                BaseText {
                    font.bold: true
                    text: "󰏔 " + updateProc.updateCount.toString()
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            termExec.command = ["kitty", "--class", "update", "-o", "background_opacity=1.0", "-e", "/home/vetula/.config/hypr/scripts/update_system.sh"]
                            termExec.running = true
                        }
                    }
                }
            }
            // System Tray Items
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
                                modelData.activate()
                            } else if (mouse.button === Qt.RightButton) {
                                if (modelData.hasMenu) {
                                    let globalPos = iconImg.mapToItem(null, 0, 0)
                                    modelData.display(root, globalPos.x, root.height)
                                } else {
                                    modelData.secondaryActivate()
                                }
                            } else if (mouse.button === Qt.MiddleButton) {
                                modelData.secondaryActivate()
                            }
                        }
                    }
                }
            }
            // Bluetooth
            Row {
                spacing: 4
                BaseText {
                    font.bold: true
                    color: Theme.secondary
                    text: ""

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            bluetoothExec.command = ["blueberry"]
                            bluetoothExec.running = true
                        }
                    }
                }
            }

            // Bluetooth
            Row {
                spacing: 4
                BaseText {
                    font.bold: true
                    color: StateStore.idleInhibited ? Theme.primary : Theme.text
                    text: StateStore.idleInhibited ? "󰈉" : "󰈈"
			//TODO Idle controll
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
				StateStore.idleInhibited = !StateStore.idleInhibited
			}
                    }
                }
            }
            // Akku (UPower)
            Row {
                spacing: 4
                visible: UPower.displayDevice !== null && UPower.displayDevice.isPresent
                property var device: UPower.displayDevice

                BaseText {
                    color: parent.device && parent.device.state === UPowerDeviceState.Charging ? Theme.primary : 
                           (parent.device && parent.device.percentage <= 0.2 ? Theme.alternate : Theme.text)

                    text: {
                        if (!parent.device) return ""
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

                BaseText {
                    font.bold: true
                    text: parent.device ? Math.round(parent.device.percentage * 100) + "%" : ""
                }
            }

            // Lautstärke Anzeige
            Row {
                spacing: 4

                BaseText {
                    color: root.isMuted ? Theme.alternate : Theme.text
                    text: root.isMuted ? "󰝟" : (root.volumeLevel > 50 ? "󰕾" : "󰖀") + " " +root.volumeLevel + "%"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pavucontrolExec.running = true
                    }
                }

            }
	    BaseText {
		    id: net
		    width:netText.implicitWidth
		    height:netText.implicitHeight
		    readonly property string networktext: {
			const devices = Networking.devices.values;
			for (let i = 0; i < devices.length; i++) {
			    const dev = devices[i];
			    if (dev.connected) {
				var returntext = "Connected";
				// WLAN Handling (Prüfung mit NetworkDeviceType)
				if (dev.type === NetworkDevice.Wifi) {
				    // Signalstärke des aktiven Access Points auslesen (0 bis 100 oder 0.0 bis 1.0)
				    var strength = dev.networks.values[0].signalStrength;

				    // Falls Quickshell Werte von 0.0 bis 1.0 liefert, auf 0-100 umrechnen:
				    if (strength <= 1.0 && strength > 0) strength = Math.round(strength * 100);

				    // Icon basierend auf Signalstärke wählen
				    var wifiIcon = "󰤯"; // Disconnected / Sehr schwach
				    if (strength > 80)      wifiIcon = "󰤨"; // 81-100%
				    else if (strength > 60) wifiIcon = "󰤥"; // 61-80%
				    else if (strength > 40) wifiIcon = "󰤢"; // 41-60%
				    else if (strength > 20) wifiIcon = "󰤟"; // 21-40%
				    returntext = wifiIcon + " " + Math.round(strength) + "%";
				}

				// LAN / Ethernet Handling
				if (dev.type === NetworkDevice.Wired) {
				    returntext = "󰌗";
				}

				return returntext;
			    }
			}
			return "󰤮 "; // Icon, wenn gar kein Netzwerk verbunden ist
		    }
		    BaseText {
			id: netText
			text: net.networktext
			MouseArea {
			anchors.fill: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
			    termExec.command = ["kitty", "--class", "wifi", "-o", "background_opacity=1.0", "-e", "nmtui"]
			    termExec.running = true
			}
		    }
		}
	    }
            // Power Profile Toggle
            BaseText {
                color: {
                    switch (powerProfileProc.currentProfile) {
                        case "performance": return Theme.secondary
                        case "power-saver": return Theme.primary
                        default: return Theme.text
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
                        }

                        powerProfileSetExec.command = ["powerprofilesctl", "set", nextProfile]
                        powerProfileSetExec.running = true
                        // Startet den Timer für das verzögerte Icon-Update
                        powerProfileRefreshDelay.start()
                    }
                }
            }
        }
    }
}
