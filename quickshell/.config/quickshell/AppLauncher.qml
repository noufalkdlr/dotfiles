import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
    id: root

    property bool visible: false
    property var allApps: DesktopEntries.applications.values
    property var filtered: allApps

    function toggle() {
        root.visible = !root.visible
        if (root.visible) {
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

            // Last real pointer position (window coordinates). Hover events also fire when items merely
            // appear or scroll under a *stationary* pointer; those must not move the selection.
            property real pointerX: 0
            property real pointerY: 0
            property bool pointerSeen: false

            function pointerMoved(x, y) {
                const moved = pointerSeen && (Math.abs(x - pointerX) > 0.5 || Math.abs(y - pointerY) > 0.5)
                pointerSeen = true
                pointerX = x
                pointerY = y
                return moved
            }

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

            GlassPanel {
                anchors.centerIn: parent
                width: 370
                height: 480

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: PickerStyle.windowMargins
                    spacing: 8

                    TextField {
                        id: searchField
                        width: parent.width
                        height: PickerStyle.fieldHeight
                        placeholderText: "Search Apps..."
                        leftPadding: PickerStyle.fieldPaddingLeft
                        rightPadding: PickerStyle.fieldPaddingH
                        color: PickerStyle.textColor
                        placeholderTextColor: PickerStyle.placeholderColor
                        font.family: PickerStyle.fontFamily
                        font.weight: PickerStyle.fontWeight
                        font.pixelSize: PickerStyle.fontSize

                        background: Rectangle {
                            color: PickerStyle.fieldBg
                            radius: PickerStyle.fieldRadius
                            border.color: PickerStyle.fieldBorder
                            border.width: 1

                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.verticalCenter: parent.verticalCenter
                                text: "\uf002"
                                font.family: Theme.fontFamily
                                font.pixelSize: 14
                                color: PickerStyle.placeholderColor
                            }
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
                        highlightMoveDuration: PickerStyle.highlightMoveDuration
                        highlightMoveVelocity: -1
                        highlightResizeDuration: 0   // no left->right grow animation when the picker opens
                        highlightResizeVelocity: -1
                        spacing: PickerStyle.itemSpacing

                        highlight: Rectangle {
                            color: PickerStyle.highlightColor
                            radius: PickerStyle.itemRadius
                            border.color: PickerStyle.highlightBorder
                            border.width: 1
                        }

                        model: root.filtered

                        delegate: Item {
                            required property var modelData
                            required property int index

                            width: listView.width
                            height: PickerStyle.itemHeight

                            Row {
                                anchors.left: parent.left
                                anchors.leftMargin: PickerStyle.itemPaddingH
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: PickerStyle.iconMarginRight

                                IconImage {
                                    width: PickerStyle.iconSize
                                    height: PickerStyle.iconSize
                                    anchors.verticalCenter: parent.verticalCenter
                                    source: Quickshell.iconPath(modelData.icon)
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.name
                                    font.family: PickerStyle.fontFamily
                                    font.pixelSize: PickerStyle.itemFontSize
                                    font.weight: PickerStyle.fontWeight
                                    color: PickerStyle.textColor
                                    elide: Text.ElideRight
                                    width: listView.width - PickerStyle.iconSize - PickerStyle.iconMarginRight - PickerStyle.itemPaddingH * 2
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                // select on real pointer movement only (not when items appear under a still pointer)
                                onPositionChanged: (mouse) => {
                                    const p = mapToItem(null, mouse.x, mouse.y)
                                    if (pickerWin.pointerMoved(p.x, p.y)) listView.currentIndex = index
                                }
                                onClicked: root.launchApp(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
