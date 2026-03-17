---
inclusion: manual
---

# 抽屉组件

## Drawer

```
右侧抽屉 (placement="right")
┌─────────────────────┬──────────┐
│                     │          │
│                     │  抽屉    │
│    主内容区域        │  内容    │
│                     │ (360px)  │
│                     │          │
└─────────────────────┴──────────┘

左侧抽屉 (placement="left")
┌──────────┬─────────────────────┐
│          │                     │
│  抽屉    │                     │
│  内容    │    主内容区域        │
│ (360px)  │                     │
│          │                     │
└──────────┴─────────────────────┘
```

```qml
component Drawer: Item {
    id: drawer
    property bool open: false
    property string placement: "right"  // left, right, top, bottom
    property int size: 360

    anchors.fill: parent
    visible: open || drawerRect.x !== hiddenX || drawerRect.y !== hiddenY

    readonly property real hiddenX: {
        if (placement === "left") return -size
        if (placement === "right") return parent.width
        return 0
    }

    readonly property real hiddenY: {
        if (placement === "top") return -size
        if (placement === "bottom") return parent.height
        return 0
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: drawer.open ? 1 : 0
        visible: opacity > 0

        TapHandler { onTapped: drawer.open = false }

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    Rectangle {
        id: drawerRect
        width: placement === "left" || placement === "right" ? drawer.size : parent.width
        height: placement === "top" || placement === "bottom" ? drawer.size : parent.height
        color: Theme.bgPanel

        x: {
            if (placement === "left") return drawer.open ? 0 : -width
            if (placement === "right") return drawer.open ? parent.width - width : parent.width
            return 0
        }

        y: {
            if (placement === "top") return drawer.open ? 0 : -height
            if (placement === "bottom") return drawer.open ? parent.height - height : parent.height
            return 0
        }

        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        Behavior on y {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.3)
            shadowBlur: 0.5
        }
    }
}
```
