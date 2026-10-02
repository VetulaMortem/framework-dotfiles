// AudioStore.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

QtObject {
    id: root
    // PwObjectTracker registrieren
    property var tracker: PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    readonly property var sink: Pipewire.defaultAudioSink

    readonly property int volumeLevel: {
        if (!sink || !sink.audio) return 0;
        return Math.round(sink.audio.volume * 100);
    }

    readonly property bool isMuted: sink && sink.audio ? sink.audio.muted : false
}
