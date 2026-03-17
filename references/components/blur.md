---
inclusion: manual
---

# 模糊效果

## GlassLayer
```qml
Item {
    id: root
    required property Item targetItem
    property real radius: 10
    property real blurAmount: 0.9
    property bool effectEnabled: false

    MultiEffect {
        anchors.fill: parent
        source: liveBackdrop
        blurEnabled: true
        blur: root.blurAmount
        blurMax: 96
        saturation: 1.07
        brightness: 0.03
        maskEnabled: true
        maskSource: blurMask
    }
}
```

## WindowBlur
```qml
WindowBlur {
    window: popup.Window.window
    enabled: popup.visible
    blurRadius: 12
    blurRect: Qt.rect(panel.x, panel.y, panel.width, panel.height)
}
```

## 阴影
```qml
layer.enabled: true
layer.effect: MultiEffect {
    shadowEnabled: true
    shadowColor: Theme.dark ? Qt.rgba(0,0,0,0.34) : Qt.rgba(0,0,0,0.18)
    shadowBlur: 0.36
    shadowVerticalOffset: 2
}
```
