import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root

    property bool visible: false
    property var allApps: []
    property var filtered: []

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
            root.allApps = DesktopEntries.applications.values
            root.filtered = root.allApps
        }
    }

    function doFilter(q) {
        if (q.length === 0) {
            root.filtered = root.allApps
        } else {
            const lower = q.toLowerCase()
            root.filtered = root.allApps.filter(e =>
                e.name.toLowerCase().includes(lower) ||
                (e.genericName && e.genericName.toLowerCase().includes(lower)) ||
                e.keywords.some(k => k.toLowerCase().includes(lower))
            )
        }
    }

    function launchApp(entry) {
        entry.execute()
        root.visible = false
    }

    IpcHandler {
        target: "appLauncher"

        function toggle() {
            root.toggle()
        }
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: pickerWin
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

            Component.onCompleted: {
                searchField.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.visible = false
            }

            Rectangle {
                anchors.centerIn: parent
                width: 400
                height: 480
                color: Qt.rgba(0, 0, 0, 0.7)
                radius: 12
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    TextField {
                        id: searchField
                        width: parent.width
                        height: 38
                        placeholderText: "Search Apps..."
                        leftPadding: 12
                        rightPadding: 12
                        color: "#ffffff"
                        placeholderTextColor: Qt.rgba(1, 1, 1, 0.4)
                        font.family: "Cascadia Mono"
                        font.pixelSize: 14

                        background: Rectangle {
                            color: Qt.rgba(1, 1, 1, 0.04)
                            radius: 8
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                        }

                        onTextChanged: {
                            root.doFilter(text)
                            listView.currentIndex = 0
                        }

                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                root.visible = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.filtered.length > 0 && listView.currentIndex >= 0) {
                                    root.launchApp(root.filtered[listView.currentIndex])
                                }
                                event.accepted = true
                            } else if (event.key === Qt.Key_Down || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_N)) {
                                listView.currentIndex = Math.min(listView.currentIndex + 1, root.filtered.length - 1)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Up || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_P)) {
                                listView.currentIndex = Math.max(listView.currentIndex - 1, 0)
                                event.accepted = true
                            }
                        }
                    }

                    ListView {
                        id: listView
                        width: parent.width
                        height: parent.height - searchField.height - 8
                        clip: true
                        currentIndex: 0
                        highlightFollowsCurrentItem: true
                        spacing: 4

                        highlight: Rectangle {
                            color: Qt.rgba(1, 1, 1, 0.12)
                            radius: 8
                            border.color: Qt.rgba(1, 1, 1, 0.08)
                            border.width: 1
                        }

                        model: root.filtered

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: listView.width
                            height: 40

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: 10
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 10

                                IconImage {
                                    width: 28
                                    height: 28
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    font.family: "Cascadia Mono"
                                    font.pixelSize: 13
                                    font.weight: index === listView.currentIndex ? Font.Bold : Font.Normal
                                    color: "#ffffff"
                                    elide: Text.ElideRight
                                    width: listView.width - 60
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: listView.currentIndex = index
                                onClicked: root.launchApp(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
