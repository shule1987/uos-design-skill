---
inclusion: manual
---

# 空状态组件

## Empty
```qml
component Empty: Item {
    id: empty
    property string iconName: "inbox"
    property string title: "暂无数据"
    property string description: ""

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL
        width: 300

        AppIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: empty.iconName
            size: 64
            color: Theme.textMuted
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: empty.title
            font.pixelSize: 16
            font.weight: Font.Medium
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            text: empty.description
            font.pixelSize: 13
            color: Theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            visible: empty.description !== ""
        }
    }
}
```
