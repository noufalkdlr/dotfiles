pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Wi-Fi state + actions (nmcli). Used by ControlCenter / WifiPage.
Singleton {
    id: root

    property bool connected: false
    property bool wifiEnabled: true
    property string currentSSID: ""
    property var networkList: []
    property var knownSSIDs: []            // saved Wi-Fi profiles (connect without a password)
    property bool scanning: false

    property string connectingSsid: ""     // network we are connecting to right now ("" = idle)
    property string connectError: ""       // last failure message ("" = none)
    property string passwordRequestSsid: ""  // set when a connect attempt needed a password

    function scan() {
        connectError = ""
        knownProc.running = true
        scanProc.running = true
    }
    function toggleWifi() { toggleProc.running = true }
    function isKnown(ssid) { return knownSSIDs.indexOf(ssid) !== -1 }
    function connectTo(ssid, password) {
        connectError = ""
        connectingSsid = ssid
        connectProc.targetSsid = ssid
        connectProc.targetPassword = password || ""
        connectProc.running = true
    }
    function disconnectCurrent() { disconnectProc.running = true }

    // ---- Status check ----
    Process {
        id: checkProc
        command: ["sh", "-c", "nmcli -t -f WIFI radio; nmcli -t -f ACTIVE,SSID dev wifi | grep '^yes'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                root.wifiEnabled = lines[0] === "enabled"
                if (lines.length > 1 && lines[1]) {
                    root.connected = true
                    root.currentSSID = lines[1].split(":")[1] || ""
                } else {
                    root.connected = false
                    root.currentSSID = ""
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: checkProc.running = true
    }

    // ---- Saved Wi-Fi profiles ----
    Process {
        id: knownProc
        command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]

        stdout: StdioCollector {
            onStreamFinished: {
                const names = []
                for (const line of this.text.trim().split("\n")) {
                    const i = line.lastIndexOf(":")
                    if (i < 0) continue
                    if (line.substring(i + 1) !== "802-11-wireless") continue
                    names.push(line.substring(0, i).replace(/\\:/g, ":"))
                }
                root.knownSSIDs = names
            }
        }
    }

    // ---- WiFi scan ----
    Process {
        id: scanProc
        command: ["sh", "-c", "nmcli -t -f SSID,SIGNAL,SECURITY dev wifi list --rescan yes"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n").filter(l => l.length > 0)
                const seen = {}
                const list = []
                for (const line of lines) {
                    const parts = line.split(":")
                    const ssid = parts[0]
                    if (!ssid || seen[ssid]) continue
                    seen[ssid] = true
                    list.push({ ssid: ssid, signal: parts[1] || "0", security: parts[2] || "" })
                }
                root.networkList = list
                root.scanning = false
            }
        }

        onRunningChanged: if (running) root.scanning = true
    }

    // ---- Toggle WiFi ----
    Process {
        id: toggleProc
        command: ["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"]

        stdout: StdioCollector {
            onStreamFinished: checkProc.running = true
        }
    }

    // ---- Connect ----
    // ssid / password are passed as positional parameters ($1 / $2), never spliced into the script.
    // On failure with a typed password, the half-created profile is deleted again so a wrong
    // password doesn't leave a "known" network behind.
    Process {
        id: connectProc
        property string targetSsid: ""
        property string targetPassword: ""
        command: ["sh", "-c",
            'if [ -n "$2" ]; then out=$(nmcli dev wifi connect "$1" password "$2" 2>&1); else out=$(nmcli dev wifi connect "$1" 2>&1); fi; rc=$?; if [ $rc -ne 0 ] && [ -n "$2" ]; then nmcli connection delete id "$1" >/dev/null 2>&1; fi; printf "%s\\n__rc=%s\\n" "$out" "$rc"',
            "sh", targetSsid, targetPassword]

        stdout: StdioCollector {
            onStreamFinished: {
                const m = /__rc=(\d+)/.exec(this.text)
                const ok = m !== null && m[1] === "0"
                const ssid = connectProc.targetSsid
                root.connectingSsid = ""

                if (ok) {
                    root.connectError = ""
                    root.passwordRequestSsid = ""
                } else if (connectProc.targetPassword.length === 0 && /secret|password/i.test(this.text)) {
                    // saved profile missing/invalid -> ask for the password
                    root.passwordRequestSsid = ssid
                } else {
                    root.connectError = "Couldn't connect to " + ssid + "."
                        + (connectProc.targetPassword.length > 0 ? " Check the password and try again." : "")
                }

                checkProc.running = true
                scanProc.running = true
                knownProc.running = true
            }
        }
    }

    // ---- Disconnect ----
    Process {
        id: disconnectProc
        command: ["sh", "-c", "nmcli con down id \"" + root.currentSSID + "\""]

        stdout: StdioCollector {
            onStreamFinished: {
                checkProc.running = true
            }
        }
    }
}
