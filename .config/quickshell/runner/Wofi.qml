//@ pragma IconTheme breeze-dark
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import ".."

PanelWindow {
    id: root

    color: "transparent"
    visible: false
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "quickshell-runner"

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    // Modus-Steuerung: "apps" oder "clipboard"
    property string currentMode: "apps"

    // Daten-Speicher
    property var allApps: []
    property var filteredApps: []
    property var clipboardItems: []
    property var filteredClipboard: []

    // Modus umschalten
    function setMode(mode) {
        currentMode = mode;
        searchInput.text = "";
        
        if (mode === "clipboard") {
            loadClipboard();
        } else {
            filterApps("");
        }
        
        searchInput.forceActiveFocus();
    }

    function toggleMode() {
        setMode(currentMode === "apps" ? "clipboard" : "apps");
    }

    // --- APP LAUNCHER LOGIK ---
    function getIconSource(iconName) {
        if (!iconName || iconName.trim() === "") {
            return Quickshell.iconPath("application-x-executable");
        }
        if (iconName.startsWith("/")) {
            return "file://" + iconName;
        }
        return Quickshell.iconPath(iconName);
    }

    Process {
        id: appScanner
        running: true
        command: [
            "bash", "-c",
            "python3 -c '" +
            "import os, glob, configparser, json\n" +
            "apps = []\n" +
            "paths = [\"/usr/share/applications/*.desktop\", os.path.expanduser(\"~/.local/share/applications/*.desktop\")]\n" +
            "for p in paths:\n" +
            "    for f in glob.glob(p):\n" +
            "        try:\n" +
            "            cp = configparser.ConfigParser(interpolation=None)\n" +
            "            cp.read(f, encoding=\"utf-8\")\n" +
            "            sec = cp[\"Desktop Entry\"]\n" +
            "            if sec.getboolean(\"NoDisplay\", False) or sec.get(\"Type\") != \"Application\": continue\n" +
            "            apps.append({\"name\": sec.get(\"Name\", \"\"), \"exec\": sec.get(\"Exec\", \"\"), \"icon\": sec.get(\"Icon\", \"\"), \"desktop\": f})\n" +
            "        except Exception: pass\n" +
            "apps.sort(key=lambda x: x[\"name\"].lower())\n" +
            "print(json.dumps(apps))\n" +
            "'"
        ]

        stdout: SplitParser {
            onRead: data => {
                try {
                    root.allApps = JSON.parse(data);
                    if (root.currentMode === "apps") root.filterApps("");
                } catch(e) {}
            }
        }
    }

    function filterApps(query) {
        if (!query || query.trim() === "") {
            filteredApps = allApps;
        } else {
            var q = query.toLowerCase();
            filteredApps = allApps.filter(app => app.name.toLowerCase().includes(q));
        }
        itemList.currentIndex = 0;
    }

    function launchApp(execCmd) {
        var cleanCmd = execCmd.replace(/%[fFeUuiCck]/g, "").trim();
	var detachedCmd = "setsid " + cleanCmd + " >/dev/null 2>&1 &";
        execProcess.command = ["sh", "-c", detachedCmd];
        execProcess.running = true;
        root.visible = false;
    }

    // --- CLIPBOARD LOGIK (CLIPHIST) ---
    Process {
        id: cliphistListProcess
        running: false
        command: [
            "bash", "-c",
            "python3 -c '" +
            "import subprocess, json\n" +
            "try:\n" +
            "    out = subprocess.check_output([\"cliphist\", \"list\"], text=True)\n" +
            "    lines = [line for line in out.splitlines() if line.strip()]\n" +
            "    print(json.dumps(lines))\n" +
            "except Exception:\n" +
            "    print(\"[]\")\n" +
            "'"
        ]
        
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.clipboardItems = JSON.parse(data);
                    root.filterClipboard(searchInput.text);
                } catch(e) {}
            }
        }
    }

    function loadClipboard() {
        clipboardItems = [];
        filteredClipboard = [];
        cliphistListProcess.running = false;
        cliphistListProcess.running = true;
    }

    function filterClipboard(query) {
        if (!query || query.trim() === "") {
            filteredClipboard = clipboardItems;
        } else {
            var q = query.toLowerCase();
            filteredClipboard = clipboardItems.filter(item => item.toLowerCase().includes(q));
        }
        itemList.currentIndex = 0;
    }

function selectClipboardItem(item) {
    // Übergeben der exakten Zeile via Python stdin an cliphist decode -> wl-copy
    execProcess.command = [
        "python3", "-c",
        "import subprocess, sys\n" +
        "item = sys.argv[1]\n" +
        "p1 = subprocess.Popen(['cliphist', 'decode'], stdin=subprocess.PIPE, stdout=subprocess.PIPE)\n" +
        "p2 = subprocess.Popen(['wl-copy'], stdin=p1.stdout)\n" +
        "p1.stdin.write(item.encode('utf-8'))\n" +
        "p1.stdin.close()\n" +
        "p2.communicate()\n",
        item
    ];
    
    execProcess.running = true;
    root.visible = false;
}
    Process {
        id: execProcess
        running: false
    }

    // Klick ins Leere schließt das Fenster
    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        implicitWidth: rowlayout.width + 40
        implicitHeight: 500
        color: Theme.background
        border.color: Theme.border
        border.width: Theme.width
        radius: 12

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // Kopfzeile: Modus-Tabs & Hilfe
	    RowLayout {
		id: rowlayout
		Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    implicitWidth: 80
                    implicitHeight: 26
                    radius: 6
                    color: root.currentMode === "apps" ? Theme.secondary : Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "Apps"
                        color: root.currentMode === "apps" ? Theme.alternatetext : Theme.secondary
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.setMode("apps")
                    }
                }

                Rectangle {
                    implicitWidth: 90
                    implicitHeight: 26
                    radius: 6
                    color: root.currentMode === "clipboard" ? Theme.secondary : Theme.border

                    Text {
                        anchors.centerIn: parent
                        text: "Clipboard"
                        color: root.currentMode === "clipboard" ? Theme.alternatetext : Theme.secondary
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.setMode("clipboard")
                    }
                }

                Item { Layout.fillWidth: true } // Spacer

                Text {
                    text: "[Tab] Modus wechseln"
                    color: Theme.alternate
                    font.pixelSize: 10
                }
            }

            // Suchfeld
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: root.currentMode === "apps" ? "App suchen..." : "Clipboard durchsuchen..."
                focus: true
                font.pixelSize: 14
                color: Theme.primary

                background: Rectangle {
                    color: Theme.alternate
                    radius: 8
                    border.color: searchInput.activeFocus ? Theme.secondary : Theme.border
                    border.width: 1
                }

                onTextChanged: {
                    if (root.currentMode === "apps") {
                        root.filterApps(text);
                    } else {
                        root.filterClipboard(text);
                    }
                }

                // Tastaturnavigation
                Keys.onTabPressed: (event) => {
                    root.toggleMode();
                    event.accepted = true;
                }
                Keys.onDownPressed: itemList.incrementCurrentIndex()
                Keys.onUpPressed: itemList.decrementCurrentIndex()
                Keys.onReturnPressed: {
                    if (itemList.currentItem) {
                        itemList.currentItem.activate();
                    }
                }
            }

            // Ergebnisliste
            ListView {
                id: itemList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: root.currentMode === "apps" ? root.filteredApps : root.filteredClipboard

                delegate: Rectangle {
                    id: delegateItem
                    width: itemList.width
                    height: 34
                    radius: 8

                    property bool isSelected: ListView.isCurrentItem
                    color: isSelected ? Theme.primary : (mouseArea.containsMouse ? Theme.secondary : "transparent")
       		    border.color: isSelected ? Theme.border : (mouseArea.containsMouse ? Theme.alternatetext : "transparent")
	            border.width: 2
                    function activate() {
                        if (root.currentMode === "apps") {
                            root.launchApp(modelData.exec);
                        } else {
                            root.selectClipboardItem(modelData);
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // Icon nur im App-Modus oder Icon für Clipboard anzeigen
                        IconImage {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            source: root.currentMode === "apps" 
                                    ? root.getIconSource(modelData.icon) 
                                    : Quickshell.iconPath("edit-copy")
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.currentMode === "apps" ? modelData.name : modelData
                            color: Theme.text
                            font.pixelSize: 13
                            font.bold: delegateItem.isSelected
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: delegateItem.activate()
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            setMode("apps"); // Öffnet standardmäßig im App-Modus
        }
    }
}
