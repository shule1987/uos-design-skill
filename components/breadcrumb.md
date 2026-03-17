---
inclusion: always
---

# 面包屑组件

## Breadcrumb
```qml
component Breadcrumb: Row {
    id: breadcrumb
    property var items: []  // [{text, href}]
    signal itemClicked(int index)

    spacing: Theme.spacingS

    Repeater {
        model: breadcrumb.items
        delegate: Row {
            spacing: Theme.spacingS

            Text {
                text: modelData.text
                font.pixelSize: 13
                color: index === breadcrumb.items.length - 1
                    ? Theme.textPrimary
                    : Theme.textSecondary
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    cursorShape: index < breadcrumb.items.length - 1 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    enabled: index < breadcrumb.items.length - 1
                    onClicked: breadcrumb.itemClicked(index)
                }
            }

            AppIcon {
                name: "chevron-right"
                size: 12
                color: Theme.textMuted
                visible: index < breadcrumb.items.length - 1
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
```
