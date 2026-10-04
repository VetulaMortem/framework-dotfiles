//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark
import QtQuick
import Quickshell
import Quickshell.Io // Wichtig: Hier liegt IpcHandler!

// Ordnerpfade direkt importieren
import "."
ShellRoot {
    // Komponenten werden direkt über den Dateinamen aufgerufen
    Waybar {}
    Battery {}
    Sound {}
    Wofi {}
    Statusinfo {}
    NotificationServer {}
    NotificationCenter {}
    IdleInhibitor {}


Scope {
    // 1. Deinen Launcher instanziieren
    Wofi {
        id: appLauncher
    }
    // 2. IPC Handler registrieren
    IpcHandler {
        target: "launcher" // Der Name des IPC-Targets

        // Funktion, die von außen aufgerufen werden kann
        function toggle(): void {
            appLauncher.visible = !appLauncher.visible;
        }

        function open(): void {
            appLauncher.visible = true;
        }

        function close(): void {
            appLauncher.visible = false;
        }
	function toggleClipboard(): void {
            if (appLauncher.visible && appLauncher.currentMode === "clipboard") {
                appLauncher.visible = false;
            } else {
                appLauncher.visible = true;
                appLauncher.setMode("clipboard");
            }
        }
    }
    IpcHandler {
    target: "shell"
        function reload(): void {
            Quickshell.reload(false);
        }
    }
    IpcHandler {
    target: "notifications"
        function toggle(): void {
            StateStore.notificationCenterOpen = !StateStore.notificationCenterOpen;
        }
    }
}
}

