import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
PanelWindow {
	id: root
	anchors	{
        top: true
        left: true
    }

    implicitHeight: 0
    implicitWidth: 0
	color: "transparent"
	Loader {
		active: StateStore.idleInhibited
		sourceComponent: IdleInhibitor {
			window: root
			enabled: true
		}
	}

}
