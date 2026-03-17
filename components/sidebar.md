---
inclusion: always
---

# 侧边栏组件

## Sidebar
```qml
component Sidebar: Rectangle {
    id: sidebar
    property bool collapsed: false
    property var items: []

    width: collapsed ? 60 : 240
    color: Theme.bgPanel

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
                width: parent.width
                height: 40
                color: modelData.active
                    ? Theme.surfaceActive
                    : (hovered ? Theme.surfaceHover : "transparent")

                property bool hovered: false

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
                        color: modelData.active ? Theme.accent : Theme.textPrimary
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 13
                        color: Theme.textPrimary
                        visible: !sidebar.collapsed
                        opacity: sidebar.collapsed ? 0 : 1

                        Behavior on opacity {
                            NumberAnimation { duration: 120 }
                        }
                    }
                }

                HoverHandler { onHoveredChanged: parent.hovered = hovered }
                TapHandler { onTapped: modelData.callback() }

                Behavior on color { ColorAnimation { duration: 80 } }
            }
        }
    }

    IconButton {
        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Theme.spacingL
        }
        iconName: sidebar.collapsed ? "chevron-right" : "chevron-left"
        onClicked: sidebar.collapsed = !sidebar.collapsed
    }
}
```
