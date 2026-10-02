//@ pragma IconTheme breeze-dark
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

PanelWindow {
    id: root
    visible: true
    // 1. Transparentes Hauptfenster
    color: "transparent"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    Shortcut {
        sequence: "Escape"
        onActivated: root.visible = false
    }

    property var allApps: []
    property var filteredApps: []

    // Icon-Resolver Helper
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
                    root.filterApps("");
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
        appList.currentIndex = 0;
    }

    function launchApp(execCmd) {
        var cleanCmd = execCmd.replace(/%[fFeUuiCck]/g, "").trim();
	var detachedCmd = "setsid " + cleanCmd + " >/dev/null 2>&1 &";
	appLauncher.command = ["sh", "-c", detachedCmd];
        appLauncher.running = true;
        root.visible = false;
    }

    Process {
        id: appLauncher
        running: false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.visible = false
    }

    Rectangle {
        anchors.centerIn: parent
        width: 300
        height: 500
        color: "#BB2A39"
        border.color: "#31342B"
        border.width: 3
        radius: 12

        MouseArea {
            anchors.fill: parent
            onClicked: (mouse) => mouse.accepted = true
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "App suchen..."
                focus: true
                font.pixelSize: 14
                color: "#5CBD88"

                background: Rectangle {
                    color: "#181825"
                    radius: 8
                    border.color: searchInput.activeFocus ? "#89b4fa" : "#313244"
                    border.width: 1
                }

                onTextChanged: root.filterApps(text)

                Keys.onDownPressed: appList.incrementCurrentIndex()
                Keys.onUpPressed: appList.decrementCurrentIndex()
                Keys.onReturnPressed: {
                    if (appList.currentItem) {
                        appList.currentItem.launch();
                    }
                }
            }

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: root.filteredApps

                delegate: Rectangle {
                    id: delegateItem
                    width: appList.width
                    height: 34
                    radius: 8

                    property bool isSelected: ListView.isCurrentItem
                    color: isSelected ? "#5CBD88" : (mouseArea.containsMouse ? "#89b4fa" : "transparent")
       		    border.color: isSelected ? "#31342B" : (mouseArea.containsMouse ? "#181825" : "transparent")
	            border.width: 2
                    function launch() {
                        root.launchApp(modelData.exec);
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        IconImage {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            source: root.getIconSource(modelData.icon)
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.name
                            color: "#cdd6f4"
                            font.pixelSize: 13
                            font.bold: delegateItem.isSelected
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: delegateItem.launch()
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            searchInput.forceActiveFocus();
            appList.currentIndex = 0;
        }
    }
}
