pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Bluetooth state + actions (bluetoothctl). Used by ControlCenter / BluetoothPage.
Singleton {
    id: root

    property bool powered: false
    property var deviceList: []
    property bool scanning: false

    // name of the first connected device ("" if none)
    readonly property string connectedName: {
        const d = deviceList.find(x => x.connected)
        return d ? d.name : ""
    }

    function refresh() { checkProc.running = true }
    function loadDevices() { listProc.running = true }
    function togglePower() { toggleProc.running = true }
    function setConnected(mac, doConnect) {
        connectProc.mac = mac
        connectProc.doConnect = doConnect
        connectProc.running = true
    }

    // ---- Status check ----
    Process {
        id: checkProc
        command: ["bluetoothctl", "show"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                root.powered = this.text.includes("Powered: yes")
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }

    // ---- Device list (paired + nearby) ----
    Process {
        id: listProc
        command: ["sh", "-c", "bluetoothctl devices | while read -r _ mac name; do connected=$(bluetoothctl info \"$mac\" | grep -q 'Connected: yes' && echo yes || echo no); echo \"$mac|$name|$connected\"; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                const list = []
                for (const line of lines) {
                    const parts = line.split("|")
                    if (parts.length < 3) continue
                    list.push({ mac: parts[0], name: parts[1], connected: parts[2] === "yes" })
                }
                root.deviceList = list
                root.scanning = false
            }
        }

        onRunningChanged: if (running) root.scanning = true
    }

    // ---- Toggle power ----
    Process {
        id: toggleProc
        command: ["bluetoothctl", "power", root.powered ? "off" : "on"]

        stdout: StdioCollector {
            onStreamFinished: checkProc.running = true
        }
    }

    // ---- Connect / Disconnect ----
    Process {
        id: connectProc
        property string mac: ""
        property bool doConnect: true
        command: ["bluetoothctl", doConnect ? "connect" : "disconnect", mac]

        stdout: StdioCollector {
            onStreamFinished: listProc.running = true
        }
    }
}
