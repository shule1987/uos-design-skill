---
inclusion: always
---

# 进度条组件

## ProgressBar

```
0%:  ┌────────────────────┐
     └────────────────────┘

50%: ┌──────────┬─────────┐
     │██████████│         │
     └──────────┴─────────┘

100%:┌────────────────────┐
     │████████████████████│
     └────────────────────┘
```

## CircularProgress

```
    ╭─────╮
   ╱   75% ╲
  │    ●    │
   ╲       ╱
    ╰─────╯
   (圆形进度)
```

```qml
component ProgressBar: Rectangle {
    id: progressBar
    property real value: 0.0

    width: 200
    height: 4
    radius: 2
    color: Theme.surface

    Rectangle {
        height: parent.height
        radius: parent.radius
        width: parent.width * progressBar.value
        color: Theme.accent

        Behavior on width {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
    }
}
```

## CircularProgress
```qml
component CircularProgress: Item {
    id: circular
    property real value: 0.0
    property int size: 48

    width: size
    height: size

    Canvas {
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d")
            const centerX = width / 2
            const centerY = height / 2
            const radius = Math.min(width, height) / 2 - 4

            ctx.clearRect(0, 0, width, height)

            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
            ctx.strokeStyle = Theme.surface
            ctx.lineWidth = 4
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * circular.value)
            ctx.strokeStyle = Theme.accent
            ctx.lineWidth = 4
            ctx.lineCap = "round"
            ctx.stroke()
        }
    }

    onValueChanged: canvas.requestPaint()
}
```
