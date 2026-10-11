import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import ".."
PanelWindow {
    id: osdCrosshair

    implicitWidth: 50
    implicitHeight: 50
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-lock"
    visible: StateStore.crossHair
    Image {
		id: background
		source: "/home/vetula/.assets/pngwing.com.png"
		anchors.fill: parent
		cache: false
		horizontalAlignment: Image.AlignCenter
	}

}
