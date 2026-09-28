import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Apple-menu style power menu.
// Restart / Shut Down / Log Out ask for confirmation in a centered dialog (Enter = confirm, Esc = cancel).
Item {
    id: root
    width: 32
    height: 32

    property alias iconText: icon.text
    property string username: ""
    property string hostname: ""
    property string uptime: ""

    // power action waiting for confirmation (null = no dialog)
    property var pending: null
    // seconds until the pending action runs by itself; 0 = wait for the user (safe default)
    property int autoSeconds: 0
    property int remaining: 0

    function ask(item) {
        root.remaining = root.autoSeconds
        root.pending = item
    }

    function confirm() {
        const item = root.pending
        root.pending = null
        if (item) item.action.running = true
    }

    function cancel() {
        root.pending = null
    }

    Text {
        id: icon
        anchors.centerIn: parent
        text: "\uf303"
        font.family: Theme.fontFamily
        font.pixelSize: 16
        color: "white"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popup.visible) {
                popup.visible = false
                PopupManager.closeIfActive(popup)
            } else {
                PopupManager.request(popup)
                popup.visible = true
                infoProc.running = true
            }
        }
    }

    Process {
        id: infoProc
        command: ["sh", "-c", "whoami; hostname; uptime -p"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n")
                root.username = lines[0] || ""
                root.hostname = lines[1] || ""
                root.uptime = lines[2] || ""
            }
        }
    }

    Process {
        id: lockProc
        command: ["hyprlock"]
    }

    Process {
        id: sleepProc
        command: ["systemctl", "suspend"]
    }

    Process {
        id: logoutProc
        command: ["hyprctl", "dispatch", "exit"]
    }

    Process {
        id: rebootProc
        command: ["systemctl", "reboot"]
    }

    Process {
        id: shutdownProc
        command: ["systemctl", "poweroff"]
    }

    // ================= MENU POPUP =================
    PanelWindow {
        id: popup
        visible: false
        color: "transparent"

        exclusionMode: ExclusionMode.Ignore

        onVisibleChanged: {
            if (!visible) PopupManager.closeIfActive(popup)
        }

        WlrLayershell.namespace: "quickshell-popup"
        WlrLayershell.layer: WlrLayer.Overlay

        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        MouseArea {
            anchors.fill: parent
            onClicked: popup.visible = false
        }

        GlassPanel {
            anchors {
                top: parent.top
                left: parent.left
                topMargin: Theme.popupTopMargin
                leftMargin: 10
            }
            width: 240
            height: contentCol.implicitHeight + 16
            transformOrigin: Item.TopLeft
            autoShow: false
            shown: popup.visible

            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }

            Column {
                id: contentCol
                anchors.fill: parent
                anchors.margins: 6
                spacing: 2

                // ---- User info header ----
                Column {
                    width: parent.width
                    spacing: 1
                    topPadding: 4
                    bottomPadding: 8
                    leftPadding: 10

                    Text {
                        text: root.username + "@" + root.hostname
                        font.family: Theme.textFontFamily
                        font.weight: Font.DemiBold
                        font.pixelSize: 13
                        color: "#ffffff"
                    }

                    Text {
                        text: root.uptime
                        font.family: Theme.textFontFamily
                        font.pixelSize: 11
                        color: "#9a9a9a"
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: PickerStyle.dividerColor
                }

                Item { width: 1; height: 4 }

                // ---- Power actions (items with "question" open the confirmation dialog) ----
                Repeater {
                    model: [
                        { label: "Sleep", icon: "\uf186", action: sleepProc },
                        { label: "Restart…", icon: "\uf2f1", action: rebootProc,
                          question: "Are you sure you want to restart your computer now?", button: "Restart" },
                        { label: "Shut Down…", icon: "\uf011", action: shutdownProc,
                          question: "Are you sure you want to shut down your computer now?", button: "Shut Down" },
                        { label: "Lock Screen", icon: "\uf023", action: lockProc, sep: true },
                        { label: "Log Out…", icon: "\uf2f5", action: logoutProc,
                          question: "Are you sure you want to log out now?", button: "Log Out" }
                    ]

                    delegate: Column {
                        required property var modelData

                        width: contentCol.width
                        spacing: 2

                        Rectangle {
                            visible: !!modelData.sep
                            width: parent.width
                            height: 1
                            color: PickerStyle.dividerColor
                        }

                        Rectangle {
                            width: parent.width
                            height: 28
                            radius: 8
                            color: hoverArea.containsMouse ? PickerStyle.highlightColor : "transparent"

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 8

                                Text {
                                    text: modelData.icon
                                    font.family: Theme.fontFamily
                                    font.pixelSize: 12
                                    color: "#ffffff"
                                    width: 16
                                }

                                Text {
                                    text: modelData.label
                                    font.family: Theme.textFontFamily
                                    font.pixelSize: 13
                                    color: "#ffffff"
                                }
                            }

                            MouseArea {
                                id: hoverArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    popup.visible = false
                                    if (modelData.question) root.ask(modelData)
                                    else modelData.action.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ================= CONFIRMATION DIALOG =================
    LazyLoader {
        active: root.pending !== null

        PanelWindow {
            id: dialogWin
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.namespace: "quickshell-popup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }

            Component.onCompleted: keys.forceActiveFocus()

            // optional auto-confirm countdown (off unless root.autoSeconds > 0)
            Timer {
                interval: 1000
                repeat: true
                running: root.autoSeconds > 0
                onTriggered: {
                    root.remaining -= 1
                    if (root.remaining <= 0) root.confirm()
                }
            }

            // click outside = cancel
            MouseArea {
                anchors.fill: parent
                onClicked: root.cancel()
            }

            GlassPanel {
                anchors.centerIn: parent
                width: 340
                height: dialogCol.implicitHeight + 40

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Item {
                    id: keys
                    anchors.fill: parent
                    focus: true

                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.cancel()
                            event.accepted = true
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            root.confirm()
                            event.accepted = true
                        }
                    }

                    Column {
                        id: dialogCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 20
                        spacing: 14

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 48
                            height: 48
                            radius: 24
                            color: Qt.rgba(1, 1, 1, 0.12)

                            Text {
                                anchors.centerIn: parent
                                text: root.pending ? root.pending.icon : ""
                                font.family: Theme.fontFamily
                                font.pixelSize: 20
                                color: "#ffffff"
                            }
                        }

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: root.pending ? root.pending.question : ""
                            font.family: Theme.textFontFamily
                            font.weight: Font.DemiBold
                            font.pixelSize: 14
                            color: "#ffffff"
                        }

                        Text {
                            visible: root.autoSeconds > 0
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                            text: "If you do nothing, your computer will "
                                + (root.pending ? root.pending.button.toLowerCase() : "")
                                + " automatically in " + root.remaining + " seconds."
                            font.family: Theme.textFontFamily
                            font.weight: Theme.textFontWeight
                            font.pixelSize: 11
                            color: PickerStyle.placeholderColor
                        }

                        Row {
                            width: parent.width
                            spacing: 10

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: 34
                                radius: 17
                                color: cancelHover.containsMouse ? Qt.rgba(1, 1, 1, 0.22) : Qt.rgba(1, 1, 1, 0.14)

                                Text {
                                    anchors.centerIn: parent
                                    text: "Cancel"
                                    font.family: Theme.textFontFamily
                                    font.weight: Font.DemiBold
                                    font.pixelSize: 13
                                    color: "#ffffff"
                                }

                                MouseArea {
                                    id: cancelHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.cancel()
                                }
                            }

                            Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: 34
                                radius: 17
                                color: "#0A84FF"
                                opacity: okHover.containsMouse ? 0.85 : 1

                                Text {
                                    anchors.centerIn: parent
                                    text: root.pending ? root.pending.button : ""
                                    font.family: Theme.textFontFamily
                                    font.weight: Font.DemiBold
                                    font.pixelSize: 13
                                    color: "#ffffff"
                                }

                                MouseArea {
                                    id: okHover
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: root.confirm()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
