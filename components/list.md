---
inclusion: always
---

# 列表组件

## ListItem
```qml
component ListItem: Rectangle {
    id: listItem
    property string title: ""
    property string subtitle: ""
    property string iconName: ""
    property bool selected: false
    signal clicked()

    width: parent.width
    height: subtitle ? 56 : 44
    color: {
        if (selected) return Theme.surfaceActive
        if (hovered) return Theme.surfaceHover
        return "transparent"
    }

    property bool hovered: false

    Row {
        anchors {
            left: parent.left
            leftMargin: Theme.spacingL
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacingM

        AppIcon {
            name: listItem.iconName
            size: 20
            color: Theme.textPrimary
            visible: listItem.iconName !== ""
        }

        Column {
            spacing: 2

            Text {
                text: listItem.title
                font.pixelSize: 13
                color: Theme.textPrimary
            }

            Text {
                text: listItem.subtitle
                font.pixelSize: 11
                color: Theme.textSecondary
                visible: listItem.subtitle !== ""
            }
        }
    }

    HoverHandler { onHoveredChanged: listItem.hovered = hovered }
    TapHandler { onTapped: listItem.clicked() }
    Behavior on color { ColorAnimation { duration: 80 } }
}
```
