import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd
import Quickshell.Io
import ".."

Scope {
    property bool isLocked: true
    property bool isLocking: true

    component BackImage : Image {
        id: background
        anchors.fill: parent
        anchors.margins: Theme.width
        source: "/home/vetula/.assets/eDP-1"
        cache: false
        fillMode: Image.PreserveAspectCrop
    }

    Timer {
        id: delayTimer
        interval: 400
        repeat: false
        onTriggered: {
            isLocked = !isLocked;
        }
    }
    
    Timer {
        id: delayTimer2
        interval: 400
        repeat: false
        onTriggered: {
            isLocking = !isLocking;
        }
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: greeterWindow
                required property var modelData
                screen: modelData
                visible: isLocking
                color: "transparent"

                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.namespace: "quickshell-greeter-content"
                exclusionMode: ExclusionMode.Ignore
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

                anchors {
                    top: true
                    left: true
                    right: true
                    bottom: true
                }

                GreeterContent {
                    anchors.fill: parent
                    onLoginSuccess: {
                        delayTimer2.restart();
                        delayTimer.restart();
                    }
                }
            }
        }
    }

    component GreeterContent: Rectangle {
        id: root

        color: Theme.background
        border.color: Theme.border
        border.width: Theme.width
        signal loginSuccess()

        BackImage {
            id: real
        }

        // Prozesse für Shutdown und Reboot
        Process {
            id: shutdownProc
            command: ["systemctl", "poweroff"]
        }

        Process {
            id: rebootProc
            command: ["systemctl", "reboot"]
        }

        ListModel {
            id: sessionModel
        }

        // Python-Parser für .desktop Dateien
        Process {
            id: sessionScanner
            command: ["python3", "-c", `
import configparser, glob, os
for f in glob.glob('/usr/share/wayland-sessions/*.desktop'):
    try:
        p = configparser.ConfigParser()
        p.read(f)
        if 'Desktop Entry' in p:
            name = p['Desktop Entry'].get('Name')
            exec_cmd = p['Desktop Entry'].get('Exec')
            filename = os.path.basename(f)
            if name and exec_cmd:
                print(f"FILE:{filename}")
                print(f"NAME:{name}")
                print(f"EXEC:{exec_cmd}")
    except:
        pass
        `]
            running: true

            property string currentFile: ""
            property string currentName: ""

            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => {
                    let text = line.trim();
                    if (text.startsWith("FILE:")) {
                        sessionScanner.currentFile = text.substring(5).trim();
                    } else if (text.startsWith("NAME:")) {
                        sessionScanner.currentName = text.substring(5).trim();
                    } else if (text.startsWith("EXEC:")) {
                        let execCmd = text.substring(5).trim();
                        if (sessionScanner.currentName !== "" && execCmd !== "") {
                            let index = sessionModel.count;
                            sessionModel.append({ 
                                filename: sessionScanner.currentFile, 
                                name: sessionScanner.currentName, 
                                command: execCmd 
                            });

                            // Automatische Vorauswahl deiner bevorzugten UWSM-Session
                            if (sessionScanner.currentFile === "hyprland-uwsm.desktop" || 
                                sessionScanner.currentName.includes("uwsm-managed")) {
                                sessionCombo.currentIndex = index;
                            }

                            sessionScanner.currentFile = "";
                            sessionScanner.currentName = "";
                        }
                    }
                }
            }
        }

        Connections {
            target: Greetd

            function onAuthMessage(message, error, responseRequired, echoResponse) {
                if (responseRequired) {
                    if (echoResponse) {
                        Greetd.respond(userInput.text);
                    } else {
                        Greetd.respond(passwordInput.text);
                    }
                }
                if (message) {
                    statusText.text = message;
                }
            }

            function onAuthFailure(message) {
                statusText.text = "Falsches Passwort oder User!";
                passwordInput.text = "";
                passwordInput.enabled = false;
                userInput.enabled = true;
                userInput.forceActiveFocus();
                Greetd.cancelSession();
            }

            function onReadyToLaunch() {
                statusText.text = "Erfolgreich! Starte Session...";
                
                let sessionCmd = sessionModel.get(sessionCombo.currentIndex).command;
                
                Greetd.launch(["sh", "-c", sessionCmd]);
                root.loginSuccess();
            }
        }

        Component.onCompleted: {
            userInput.forceActiveFocus();
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 16
            width: 350

            SystemClock {
                id: clock
                precision: SystemClock.Minutes
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatTime(clock.date, "hh:mm")
                color: Theme.text
                font.pixelSize: 64
                font.bold: true
            }

            Text {
                id: statusText
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: "Please enter Username"
                color: Theme.accent
                font.pixelSize: 16
                wrapMode: Text.WordWrap
            }

            // 1. Eingabefeld: Benutzername
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                TextInput {
                    id: userInput
                    anchors.centerIn: parent
                    width: 350
                    height: 45
                    color: Theme.text
                    text: "vetula"
                    font.pixelSize: 18
                    focus: true
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 15
                    rightPadding: 15

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        color: Theme.alternate
                        radius: Theme.radius
                        border.color: userInput.activeFocus ? Theme.primary : Theme.border
                        border.width: Theme.width
                    }

                    onAccepted: {
                        if (text.length > 0) {
                            statusText.text = "Entering Password...";
                            userInput.enabled = false;
                            passwordInput.enabled = true;
                            passwordInput.forceActiveFocus();
                        }
                    }
                }
            }

            // 2. Eingabefeld: Passwort
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 45

                TextInput {
                    id: passwordInput
                    anchors.centerIn: parent
                    width: 350
                    height: 45
                    color: Theme.text
                    font.pixelSize: 18
                    echoMode: TextInput.Password
                    enabled: false
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 15
                    rightPadding: 15

                    Rectangle {
                        anchors.fill: parent
                        z: -1
                        color: Theme.alternate
                        radius: Theme.radius
                        border.color: passwordInput.activeFocus ? Theme.primary : Theme.border
                        border.width: Theme.width
                    }
                    onAccepted: {
                            statusText.text = "Creating Session...";
                            passwordInput.forceActiveFocus();
                            Greetd.createSession(userInput.text);
                    }
                }
            }

            // 3. Dropdown-Menü
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                ComboBox {
                    id: sessionCombo
                    anchors.fill: parent
                    model: sessionModel
                    textRole: "name"

                    background: Rectangle {
                        color: Theme.alternate
                        border.color: Theme.border
                        border.width: Theme.width
                        radius: Theme.radius
                    }

                    contentItem: Text {
                        leftPadding: 15
                        text: sessionCombo.displayText
                        color: Theme.text
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            // 4. Power-Buttons (Shutdown & Reboot)
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 38
                spacing: 10

                // Shutdown Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.alternate
                    border.color: Theme.border
                    border.width: Theme.width
                    radius: Theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "Shutdown"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shutdownProc.running = true
                    }
                }

                // Reboot Button
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Theme.alternate
                    border.color: Theme.border
                    border.width: Theme.width
                    radius: Theme.radius

                    Text {
                        anchors.centerIn: parent
                        text: "Reboot"
                        color: Theme.text
                        font.pixelSize: 13
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: rebootProc.running = true
                    }
                }
            }
        }
    }

    IpcHandler {
        target: "greeter"

        function lock(): void {
            isLocking = true;
            delayTimer.restart();
        }
        function forceUnlock(): void {
            isLocked = false;
        }
    }
}
