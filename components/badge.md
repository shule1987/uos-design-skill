---
inclusion: always
---

# 徽章组件

## Badge
```qml
component Badge: Rectangle {
    id: badge
    property int count: 0

    width: Math.max(18, label.width + 8)
    height: 18
    radius: 9
    color: Theme.danger
    visible: count > 0

    Text {
        id: label
        anchors.centerIn: parent
        text: badge.count > 99 ? "99+" : badge.count
        font.pixelSize: 11
        font.weight: Font.Medium
        color: "#FFFFFF"
    }
}
```

## StatusDot
```qml
component StatusDot: Rectangle {
    property string status: "online"

    width: 8
    height: 8
    radius: 4
    color: {
        switch(status) {
            case "online": return Theme.success
            case "away": return Theme.warning
            case "busy": return Theme.danger
            default: return Theme.textMuted
        }
    }
}
```
