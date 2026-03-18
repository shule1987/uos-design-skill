---
inclusion: manual
---

# 骨架屏组件

## Skeleton
```qml
component Skeleton: Rectangle {
    id: skeleton
    property string variant: "text"  // text, circle, rect
    property int lines: 1

    width: variant === "circle" ? 48 : 200
    height: variant === "circle" ? 48 : (variant === "text" ? 16 : 100)
    radius: variant === "circle" ? width / 2 : 4
    color: Theme.surface

    SequentialAnimation on opacity {
        running: true
        loops: Animation.Infinite
        NumberAnimation { from: 1; to: 0.5; duration: 800 }
        NumberAnimation { from: 0.5; to: 1; duration: 800 }
    }
}
```

## SkeletonGroup
```qml
component SkeletonGroup: Column {
    property int lines: 3
    spacing: Theme.spacingS

    Repeater {
        model: lines
        Skeleton {
            width: parent.width * (index === lines - 1 ? 0.6 : 1)
        }
    }
}
```
