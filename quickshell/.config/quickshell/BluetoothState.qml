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

    // "Name" or "Name · 85%" for the Control Center row ("" if nothing is connected)
    readonly property string connectedLabel: {
        const d = deviceList.find(x => x.connected)
        if (!d) return ""
        return d.battery >= 0 ? d.name + " · " + d.battery + "%" : d.name
    }

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
        command: ["sh", "-c", "bluetoothctl devices | while read -r _ mac name; do info=$(bluetoothctl info \"$mac\"); connected=$(printf '%s' \"$info\" | grep -q 'Connected: yes' && echo yes || echo no); batt=$(printf '%s' \"$info\" | sed -n 's/.*Battery Percentage: 0x[0-9a-fA-F]* (\\([0-9]*\\)).*/\\1/p' | head -n1); echo \"$mac|$name|$connected|${batt:--1}\"; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                const list = []
                for (const line of lines) {
                    const parts = line.split("|")
                    if (parts.length < 3) continue
                    const battery = parts.length > 3 ? parseInt(parts[3]) : -1
                    list.push({
                        mac: parts[0],
                        name: parts[1],
                        connected: parts[2] === "yes",
                        battery: isNaN(battery) ? -1 : battery,
                        order: list.length
                    })
                }
                // connected devices first, otherwise keep bluetoothctl's order
                list.sort((a, b) => (Number(b.connected) - Number(a.connected)) || (a.order - b.order))
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
