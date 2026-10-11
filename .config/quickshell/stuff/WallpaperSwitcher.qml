import QtQuick
import QtQuick.Controls
import Quickshell.Wayland
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import ".."
PanelWindow {
    id: root

    // Passe den Pfad zu deinem Wallpaper-Ordner an (z.B. absoluter Pfad)
    property string wallpaperDir: "file:///home/vetula/.assets/wallpapers"
    property bool showWindow : false
    // Funktion zum Ausführen deines bestehenden Scripts
    
            width: 800
            height: 160
	    anchors.bottom: true
            color: "transparent" // Passend zu deinem Theme
            visible: showWindow // Oder an einen Shortcut/Toggle koppeln
	    WlrLayershell.layer: WlrLayer.Overlay
	    WlrLayershell.exclusiveZone: -1
	    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
	    WlrLayershell.namespace: "quickshell-wallpaperswitcher"
    onShowWindowChanged: {
        if (showWindow) {
            getCurrentWallpaper.running = true
        }
    }

            FolderListModel {
                id: folderModel
                folder: root.wallpaperDir
                nameFilters: ["*.png", "*.jpg", "*.jpeg"]
                showFiles: true
                sortField: FolderListModel.Name
            }
    // Prozess zum Auslesen des aktuellen Wallpapers (Passe den Pfad an, 
    // falls dein Skript den Pfad woanders speichert, z.B. in ~/.cache/current_wallpaper)
    Process {
        id: getCurrentWallpaper
        command: ["realpath", "/home/vetula/.assets/eDP-1"]
        stdout: SplitParser {
            onRead: data => {
                let currentPath = data.trim()
                // Suche das passende Wallpaper im FolderModel
                for (let i = 0; i < folderModel.count; i++) {
                    let fileUrl = folderModel.get(i, "fileUrl").toString()
                    if (fileUrl.includes(currentPath) || currentPath.endsWith(folderModel.get(i, "fileName"))) {
                        listView.currentIndex = i
                        // Springe zum Index und zentriere ihn in der Ansicht
                        listView.positionViewAtIndex(i, ListView.Center)
                        break
                    }
                }
            }
        }
    }

    function selectWallpaper(filePath) {
        // Entfernt das "file://" Prefix, falls dein Script einen reinen Pfad erwartet
        let cleanPath = filePath.replace("file://", "")
        wallpaperProcess.command = ["/home/vetula/.scripts/bgandtheme.sh", cleanPath] // Hier dein Script eintragen!
        wallpaperProcess.running = true
        // Optional: Fenster nach Auswahl schließen
	showWindow = false
    }
    IpcHandler {
    target: "wallpaperswitcher"
    function toggle(): void {
            getCurrentWallpaper.running = true
	    showWindow = !showWindow
        }
    }

    // Prozess zum Ausführen des Shell-Scripts
    Process {
        id: wallpaperProcess
        // onExited kannst du nutzen, um Feedback zu geben
    }
    // Das eigentliche UI-Fenster
            // Beispiel: Zentriertes Overlay am unteren Bildschirmrand
	    Rectangle {
		    color: Theme.background
		    border.color: Theme.border
		    border.width: Theme.width
	            topLeftRadius: Theme.radius * 4
		    topRightRadius: Theme.radius * 4
		    implicitWidth: parent.width
		    implicitHeight: parent.height
        	    anchors.bottom: parent.bottom
		    anchors.bottomMargin: -3
		    ListView {
			id: listView
			anchors.fill: parent
			anchors.margins: 20
			orientation: ListView.Horizontal
			spacing: 5
			clip: true
			focus: true
			model: folderModel

			delegate: Rectangle {
			    required property int index
			    required property url fileUrl
			    required property string fileName

			    implicitWidth: listView.currentIndex === index ? 180 : 50
			    implicitHeight: 120
			    color: Theme.primary
			    radius: 8
			    border.color: listView.currentIndex === index ? Theme.secondary : "transparent"
			    border.width: 3
			    Image {
				anchors.fill: parent
				anchors.margins: 4
				source: fileUrl
				fillMode: Image.PreserveAspectCrop
				asynchronous: true
			    }

			    MouseArea {
				anchors.fill: parent
				onClicked: {
				    listView.currentIndex = index
				    root.selectWallpaper(fileUrl.toString())
				}
			    }
			}

			// Tastatur-Navigation (Pfeiltasten + Enter)
			Keys.onReturnPressed: {
				if (currentItem) {
				root.selectWallpaper(listView.currentItem.fileUrl.toString())
			    }
			}
		    }
	    }


        }

