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

PanelWindow {
    id: root
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
            print("Hyprland event: " + event.name + " -> " + event.data);
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
    WlrLayershell.exclusiveZone: 38
    WlrLayershell.namespace: "quickshell-bar"

    // Baustein: Basis-Text für Icons & Standard-Font
    component BaseText : Text {
        font.family: "JetBrainsMono NF"
        font.pixelSize: 16
        color: "#ffffff"
    }

    // Gemeinsame Style-Eigenschaften für alle Inseln
    component Island : Rectangle {
        color: "#BB2A39"
        border.color: "#31342B"
        border.width: 4
        bottomLeftRadius: 32
        bottomRightRadius: 32
        topLeftRadius: 0
        topRightRadius: 0
        height: 41

        anchors.top: parent.top
        anchors.topMargin: -4
    }

    // Singletons für globale Shell-Execs
    Process { id: termExec }
    Process { id: bluetoothExec }
    Process { id: pavucontrolExec; command: ["pavucontrol"] }
    Process { id: swayncExec }
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
                    required property int index
                    property int wsId: index + 1
                    property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === wsId : false
                    
                    // Belegungsprüfung
                    property bool isOccupied: Hyprland.workspaces.values.some(ws => ws.id === wsId && ws.toplevels.values.length > 0)

                    width: isActive ? 32 : 12
                    height: 12
                    radius: 8

                    color: isActive ? "#FE7446" : (isOccupied ? "#5CBD88" : "#282828")

                    Behavior on width {
                        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
                    }
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + "})")
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

        property bool dndActive: false
        property int count: 0

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
                            centerIsland.dndActive = json.dnd ?? false
                            centerIsland.count = json.count ?? 0
                        } catch(e) {}
                    }
                }
            }
        }

        function updateSwayNc() {
            swayncStatus.running = true
        }

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
                color: centerIsland.count > 0 ? "#ff5545" : (centerIsland.dndActive ? "#888888" : "#ffffff")
                text: centerIsland.dndActive ? "󰂛" : (centerIsland.count > 0 ? "󱅫" : "󰂚")

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            swayncExec.command = ["swaync-client", "-t", "-sw"]
                        } else if (mouse.button === Qt.RightButton) {
                            swayncExec.command = ["swaync-client", "-d", "-sw"]
                        }
                        swayncExec.running = true
                        centerIsland.updateSwayNc()
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
        Process {
            id: volumeProc
            // Horcht dauerhaft auf System-Audio-Events und liest bei jeder Änderung wpctl aus
            command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@; pw-mon | stdbuf -oL grep --line-buffered 'sink' | while read -r line; do wpctl get-volume @DEFAULT_AUDIO_SINK@; done"]
            running: true

            property int volumePercent: 0
            property bool isMuted: false

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: data => {
                    let str = data.trim()
                    if (str.length === 0) return
                    volumeProc.isMuted = str.includes("[MUTED]")
                    let match = str.match(/Volume:\s+([0-9.]+)/)
                    if (match) {
                        volumeProc.volumePercent = Math.round(parseFloat(match[1]) * 100)
                    }
                }
            }
        }

        Row {
            id: trayRow
            anchors.centerIn: parent
            spacing: 10

            // Pacman Updates
            Row {
                spacing: 4
                visible: updateProc.updateCount > 0

                BaseText {
                    color: "#5CBD88"
                    text: "󰏔"

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            termExec.command = ["kitty", "--class", "update", "-o", "background_opacity=1.0", "-e", "/home/vetula/.config/hypr/scripts/update_system.sh"]
                            termExec.running = true
                        }
                    }
                }

                BaseText {
                    font.bold: true
                    text: updateProc.updateCount.toString()
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
                    color: "#6167AD"
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

            // Akku (UPower)
            Row {
                spacing: 4
                visible: UPower.displayDevice !== null && UPower.displayDevice.isPresent
                property var device: UPower.displayDevice

                BaseText {
                    color: parent.device && parent.device.state === UPowerDeviceState.Charging ? "#a6e3a1" : 
                           (parent.device && parent.device.percentage <= 0.2 ? "#ff5545" : "#ffffff")

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
                    color: volumeProc.isMuted ? "#ff5545" : "#ffffff"
                    text: volumeProc.isMuted ? "󰝟" : (volumeProc.volumePercent > 50 ? "󰕾" : "󰖀")

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pavucontrolExec.running = true
                    }
                }

                BaseText {
                    font.bold: true
                    color: volumeProc.volumePercent > 100 ? "#ff5545" : "#ffffff"
                    text: volumeProc.volumePercent + "%"
                }
            }

            // Power Profile Toggle
            BaseText {
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
