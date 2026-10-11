/* STREAMING_CHUNK:Importing required modules and Theme */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import ".." // Imports Theme.qml from the same directory

/* STREAMING_CHUNK:Defining main widget panel container */
Rectangle {
id: root
width: 340
height: 220
color: Theme.background
border.color: Theme.border
border.width: Theme.width
radius: 12

/* STREAMING_CHUNK:Internal state for selected player management */
property var activePlayer: null
property var availablePlayers: Mpris.players
property bool showIfNoPlayer: true
/* STREAMING_CHUNK:Selecting default active player when players list updates */
Connections {
    target: Mpris
    function onPlayersChanged() {
        if (!root.activePlayer && Mpris.players.values.length > 0) {
            root.activePlayer = Mpris.players.values[0]
        }
    }
}

Component.onCompleted: {
    if (Mpris.players.values.length > 0) {
        root.activePlayer = Mpris.players.values[0]
    }
    root.visible = showIfNoPlayer ? true : root.activePlayer
}

/* STREAMING_CHUNK:Building the main layout */
ColumnLayout {
    anchors.fill: parent
    anchors.margins: 12
    spacing: 10

    /* STREAMING_CHUNK:Creating the player selector dropdown header */
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "🎵"
            font.pixelSize: 14
        }

        ComboBox {
            id: playerSelector
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            model: Mpris.players.values
            
            textRole: "identity"
            
            onActivated: (index) => {
                if (index >= 0 && index < Mpris.players.values.length) {
                    root.activePlayer = Mpris.players.values[index]
                }
            }

            background: Rectangle {
                color: Theme.alternate
                border.color: Theme.border
                border.width: 1
                radius: 6
            }

            contentItem: Text {
                leftPadding: 8
                rightPadding: playerSelector.indicator.width + playerSelector.spacing
                text: playerSelector.displayText
                color: Theme.text
                font.pixelSize: 13
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            popup: Popup {
                y: playerSelector.height + 4
                width: playerSelector.width
                implicitHeight: contentItem.implicitHeight
                padding: 1

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: playerSelector.popup.visible ? playerSelector.delegateModel : null
                    ScrollIndicator.vertical: ScrollIndicator { }
                }

                background: Rectangle {
                    color: Theme.background
                    border.color: Theme.border
                    border.width: 1
                    radius: 6
                }
            }

            delegate: ItemDelegate {
                width: playerSelector.width
                height: 32
                contentItem: Text {
                    text: model.identity || "Unknown Player"
                    color: Theme.text
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 8
                }
                background: Rectangle {
                    color: highlighted ? Theme.primaryTransparent : "transparent"
                }
                highlighted: playerSelector.highlightedIndex === index
            }
        }
    }

    /* STREAMING_CHUNK:Displaying track metadata (Title and Artist) */
    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        /* STREAMING_CHUNK:Album art placeholder / image */
        Rectangle {
            width: 40
            height: 40
            radius: 6
            color: Theme.alternate
            border.color: Theme.border
            border.width: 1
            clip: true

            Image {
                anchors.fill: parent
                source: root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                text: "💿"
                visible: !parent.children[0].visible
                font.pixelSize: 18
            }
        }

        /* STREAMING_CHUNK:Track Info Labels */
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: root.activePlayer ? (root.activePlayer.trackTitle || "No Track") : "No Player Connected"
                color: Theme.text
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.activePlayer ? (root.activePlayer.trackArtists ? root.activePlayer.trackArtists.join(", ") : "Unknown Artist") : "Select a player"
                color: Theme.alternatetext
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }

    /* STREAMING_CHUNK:Creating media control buttons (Backward, Play/Pause, Forward) */
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 16

        /* STREAMING_CHUNK:Backward Button */
        Button {
            id: prevButton
            width: 32
            height: 32
            enabled: root.activePlayer ? root.activePlayer.canGoPrevious : false

            contentItem: Text {
                text: "⏮"
                color: prevButton.enabled ? Theme.text : Theme.alternatetext
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }

            background: Rectangle {
                color: prevButton.hovered && prevButton.enabled ? Theme.primaryTransparent : "transparent"
                radius: 16
            }

            onClicked: {
                if (root.activePlayer && root.activePlayer.canGoPrevious) {
                    root.activePlayer.previous()
                }
            }
        }

        /* STREAMING_CHUNK:Play / Pause Toggle Button */
        Button {
            id: playPauseButton
            width: 38
            height: 38
            enabled: root.activePlayer ? (root.activePlayer.canPlay || root.activePlayer.canPause) : false

            property bool isPlaying: root.activePlayer ? (root.activePlayer.playbackState === MprisPlaybackState.Playing) : false

            contentItem: Text {
                text: playPauseButton.isPlaying ? "⏸" : "▶"
                color: playPauseButton.enabled ? Theme.primary : Theme.alternatetext
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 16
            }

            background: Rectangle {
                color: playPauseButton.hovered ? Theme.primaryTransparent : Theme.secondaryTransparent
                border.color: Theme.border
                border.width: 1
                radius: 19
            }

            onClicked: {
                if (root.activePlayer) {
                    root.activePlayer.togglePlaying()
                }
            }
        }

        /* STREAMING_CHUNK:Forward Button */
        Button {
            id: nextButton
            width: 32
            height: 32
            enabled: root.activePlayer ? root.activePlayer.canGoNext : false

            contentItem: Text {
                text: "⏭"
                color: nextButton.enabled ? Theme.text : Theme.alternatetext
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 14
            }

            background: Rectangle {
                color: nextButton.hovered && nextButton.enabled ? Theme.primaryTransparent : "transparent"
                radius: 16
            }

            onClicked: {
                if (root.activePlayer && root.activePlayer.canGoNext) {
                    root.activePlayer.next()
                }
            }
        }
    }
}}
