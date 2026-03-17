---
inclusion: always
---

# 标签页组件

## TabItem

```
标签栏示例：
┌────────┬────────┬────────┬───┐
│ 标签1  │ 标签2  │ 标签3  │ + │
│  [✕]   │  [✕]   │  [✕]   │   │
└────────┴────────┴────────┴───┘
  激活      普通      普通    新建

固定标签 (pinned):
┌───┬────────┬────────┐
│ 📌│ 标签1  │ 标签2  │
└───┴────────┴────────┘
48px   180px    180px
```

```qml
component TabItem: Rectangle {
    id: tab
    property string title: "新标签页"
    property bool active: false
    property bool pinned: false
    signal clicked()
    signal closeRequested()

    width: pinned ? 48 : 180
    height: 30 
    radius: Theme.radiusMd
    color: {
        if (active) return Colors.tabActive
        if (hovered) return Colors.tabHover
        return Colors.tabInactive
    }

    property bool hovered: false

    Row {
        anchors {
            left: parent.left
            leftMargin: Theme.spacingM
            right: closeBtn.left
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spacingS

        Text {
            text: tab.title
            font.pixelSize: 12
            color: Colors.chromeTopTextPrimary
            elide: Text.ElideRight
            visible: !tab.pinned
        }
    }

    IconButton {
        id: closeBtn
        anchors {
            right: parent.right
            rightMargin: 4
            verticalCenter: parent.verticalCenter
        }
        width: 20
        height: 20
        iconName: "x"
        iconSize: 12
        visible: !tab.pinned && (tab.hovered || tab.active)
        onClicked: tab.closeRequested()
    }

    HoverHandler { onHoveredChanged: tab.hovered = hovered }
    TapHandler { onTapped: tab.clicked() }
    Behavior on color { ColorAnimation { duration: 100 } }
}
```
