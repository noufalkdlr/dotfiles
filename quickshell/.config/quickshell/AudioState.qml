pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Audio output state + actions (PipeWire). Used by ControlCenter / SoundPage.
Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real volumeLevel: (sink?.audio?.volumes.length ?? 0) > 0 ? sink.audio.volumes[0] : 0
    readonly property var outputs: Pipewire.nodes.values.filter(n => n.isSink && n.audio && !n.isStream)
    readonly property string outputName: sink ? (sink.description || sink.name) : "No Output"

    // ---- input (microphone) ----
    readonly property PwNode source: Pipewire.defaultAudioSource
    readonly property bool inputMuted: source?.audio?.muted ?? false
    readonly property real inputLevel: (source?.audio?.volumes.length ?? 0) > 0 ? source.audio.volumes[0] : 0
    readonly property var inputs: Pipewire.nodes.values.filter(n => !n.isSink && n.audio && !n.isStream)
    readonly property string inputIcon: (inputMuted || inputLevel === 0) ? "\uf131" : "\uf130"

    // speaker glyph for the current state
    readonly property string icon: {
        if (muted || volumeLevel === 0) return "\uf6a9"
        if (volumeLevel < 0.5) return "\uf027"
        return "\uf028"
    }

    // audio properties are only valid on bound nodes -> track both default sink and source
    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => n)
    }

    function setVolume(v) {
        if (root.sink?.ready && root.sink?.audio) {
            root.sink.audio.muted = false
            root.sink.audio.volume = v
        }
    }

    function toggleMute() {
        if (root.sink?.ready && root.sink?.audio) {
            root.sink.audio.muted = !root.sink.audio.muted
        }
    }

    function selectOutput(node) {
        Pipewire.preferredDefaultAudioSink = node
    }

    function setInputVolume(v) {
        if (root.source?.ready && root.source?.audio) {
            root.source.audio.muted = false
            root.source.audio.volume = v
        }
    }

    function toggleInputMute() {
        if (root.source?.ready && root.source?.audio) {
            root.source.audio.muted = !root.source.audio.muted
        }
    }

    function selectInput(node) {
        Pipewire.preferredDefaultAudioSource = node
    }
}
