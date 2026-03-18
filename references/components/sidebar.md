---
inclusion: manual
---

# 侧边栏组件

## Sidebar
```qml
component Sidebar: Rectangle {
    id: sidebar
    property bool collapsed: false
    property bool collapsible: true
    property bool blurEnabled: false
    property var items: []

    width: collapsed ? 60 : 240
    color: Theme.bgPanel

    WindowBlur {
        anchors.fill: parent
        radius: 48
        z: -1
        visible: sidebar.blurEnabled
    }

    Behavior on width {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: Theme.spacingL
        }
        spacing: Theme.spacingS

        Repeater {
            model: sidebar.items
            delegate: Rectangle {
                id: sidebarItem
                width: parent.width
                height: 40
                activeFocusOnTab: true
                color: modelData.active
                    ? Theme.surfaceActive
                    : (hovered ? Theme.surfaceHover : "transparent")

                property bool hovered: false
                Accessible.name: modelData.label

                Row {
                    anchors {
                        left: parent.left
                        leftMargin: Theme.spacingL
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: Theme.spacingM

                    AppIcon {
                        name: modelData.icon
                        size: 20
                        color: modelData.active ? Theme.accentForeground : Theme.iconNormal
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 13
                        color: modelData.active ? Theme.textStrong : Theme.textPrimary
                        visible: !sidebar.collapsed
                        opacity: sidebar.collapsed ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 120 }
                        }
                    }
                }

                HoverHandler { onHoveredChanged: sidebarItem.hovered = hovered }
                TapHandler {
                    onTapped: {
                        if (modelData.callback)
                            modelData.callback()
                    }
                }
                Keys.onReturnPressed: if (modelData.callback) modelData.callback()
                Keys.onSpacePressed: if (modelData.callback) modelData.callback()

                Behavior on color { ColorAnimation { duration: Theme.animFast } }
            }
        }
    }

    IconButton {
        visible: sidebar.collapsible
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Theme.spacingL
        }
        iconName: sidebar.collapsed ? "chevron-right" : "chevron-left"
        accessibleName: sidebar.collapsed ? qsTr("展开侧边栏") : qsTr("折叠侧边栏")
        onClicked: sidebar.collapsed = !sidebar.collapsed
    }
}
```
