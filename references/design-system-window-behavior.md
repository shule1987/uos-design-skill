---
inclusion: manual
---

# 设计系统 - 窗口行为规范

## 目录
- 使用前提
- 窗口系统
- 窗口拖动
- 窗口控制按钮
- 窗口尺寸约束
- 窗口状态管理
- 弹窗行为
- 交互行为
- 响应式布局

## 使用前提
- 先确认目标 Qt / DTK 版本，以及应用运行在 Wayland 还是 X11。
- 默认保留系统窗口装饰；自绘标题栏属于按需启用方案。
- `Popup.Window` 仅适用于 Qt 6.8+ 且目标桌面已经验证窗口化弹窗行为的场景。

## 窗口系统

### 窗口类型

#### 1. 主窗口（默认系统装饰）
```qml
ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    color: Theme.bg
}
```

#### 2. 自绘主窗口（按需启用）
```qml
ApplicationWindow {
    id: mainWindow
    property bool blurEnabled: false

    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    color: "transparent"

    // 仅在需要自定义桌面壳层时启用
    flags: Qt.Window | Qt.FramelessWindowHint

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }
}
```

#### 3. 弹窗（Popup）
```qml
Popup {
    id: popup
    property bool blurEnabled: false
    width: 300
    height: 400
    focus: true
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    // Qt 6.8+ 且需要窗口管理器参与时可改为 Popup.Window
    // popupType: Popup.Window

    background: Rectangle {
        radius: Theme.radiusMd
        color: Theme.popupBg

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Theme.dark ? Qt.rgba(0,0,0,0.34) : Qt.rgba(0,0,0,0.18)
            shadowBlur: 0.36
            shadowVerticalOffset: 2
        }
    }

    // 可选 blur，必须保留纯色回退
    WindowBlur {
        window: popup.Window.window
        enabled: popup.visible
        blurRadius: 12
        visible: popup.blurEnabled
    }
}
```

### 窗口拖动

#### 标题栏拖动区域
```qml
Item {
    id: titleBar
    height: 40
    anchors { left: parent.left; right: parent.right; top: parent.top }

    DragHandler {
        target: null
        onActiveChanged: {
            if (active && typeof mainWindow.startSystemMove === "function")
                mainWindow.startSystemMove()
        }
    }

    // 双击最大化/还原
    TapHandler {
        onDoubleTapped: {
            if (mainWindow.visibility === Window.Maximized)
                mainWindow.showNormal()
            else
                mainWindow.showMaximized()
        }
    }
}
```

#### Logo 区域拖动
```qml
Item {
    id: appLogo
    width: 20
    height: 20

    DragHandler {
        target: null
        onActiveChanged: {
            if (active && Window.window &&
                    typeof Window.window.startSystemMove === "function")
                Window.window.startSystemMove()
        }
    }

    TapHandler {
        onDoubleTapped: {
            if (!Window.window)
                return
            if (Window.window.visibility === Window.Maximized)
                Window.window.showNormal()
            else
                Window.window.showMaximized()
        }
    }
}
```

### 窗口控制按钮

```qml
component WindowControlButton: IconButton {
    width: 46
    height: 40
    radius: 0
    iconSize: 14
    hoverColor: isClose ? Theme.danger : Theme.titlebarHover
    iconColor: Theme.iconNormal
    iconHoverColor: isClose ? "#FFFFFF" : Theme.iconHover
    activeFocusOnTab: true

    property bool isClose: false
}

// 使用
Row {
    id: winButtons
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    spacing: 0

    WindowControlButton {
        iconName: "window-minimize"
        accessibleName: qsTr("最小化")
        onClicked: mainWindow.showMinimized()
    }
    WindowControlButton {
        iconName: mainWindow.visibility === Window.Maximized
            ? "window-restore" : "window-maximize"
        accessibleName: mainWindow.visibility === Window.Maximized
            ? qsTr("还原窗口") : qsTr("最大化窗口")
        onClicked: {
            if (mainWindow.visibility === Window.Maximized)
                mainWindow.showNormal()
            else
                mainWindow.showMaximized()
        }
    }
    WindowControlButton {
        iconName: "window-close"
        isClose: true
        accessibleName: qsTr("关闭")
        onClicked: mainWindow.close()
    }
}
```

### 窗口尺寸约束

```qml
ApplicationWindow {
    // 最小尺寸
    minimumWidth: 800
    minimumHeight: 600

    // 最大尺寸（可选）
    maximumWidth: 1920
    maximumHeight: 1080

    // 初始尺寸
    width: 1200
    height: 800
}
```

### 窗口状态管理

```qml
// 保存窗口状态
Settings {
    property alias windowX: mainWindow.x
    property alias windowY: mainWindow.y
    property alias windowWidth: mainWindow.width
    property alias windowHeight: mainWindow.height
    property int windowVisibility: Window.Windowed
}

// 恢复窗口状态
Component.onCompleted: {
    if (settings.windowVisibility === Window.Maximized)
        mainWindow.showMaximized()
}

// 保存状态
onClosing: {
    settings.windowVisibility = mainWindow.visibility
}
```

---

## 弹窗行为

### 弹窗定位

#### 相对定位
```qml
function openAt(anchor, offsetX, offsetY) {
    var anchorItem = anchor || parent
    var px = Number(offsetX) || 0
    var py = Number(offsetY) || 0

    var host = popupParentItem()
    if (anchorItem && host) {
        var globalPos = anchorItem.mapToGlobal(px, py)
        var localPos = host.mapFromGlobal(globalPos.x, globalPos.y)
        var fit = clampPosition(localPos.x, localPos.y)
        x = fit.x
        y = fit.y
        open()
    }
}
```

#### 边界限制
```qml
function clampPosition(nextX, nextY) {
    var host = popupParentItem()
    var widthLimit = host ? host.width : 0
    var heightLimit = host ? host.height : 0
    var popupWidth = Math.max(0, root.width || root.implicitWidth || 0)
    var popupHeight = Math.max(0, root.implicitHeight || root.height || 0)
    var margin = 8

    if (widthLimit > 0)
        nextX = Math.max(margin, Math.min(nextX, widthLimit - popupWidth - margin))
    if (heightLimit > 0)
        nextY = Math.max(margin, Math.min(nextY, heightLimit - popupHeight - margin))

    return { x: Math.round(nextX), y: Math.round(nextY) }
}
```

### 弹窗动画

```qml
Popup {
    // 淡入
    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 120
        }
    }

    // 淡出
    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 80
        }
    }
}
```

### 模态遮罩

```qml
Popup {
    modal: true
    dim: true  // 启用遮罩

    Overlay.modal: Rectangle {
        color: Theme.scrim  // 半透明黑色
    }
}
```

---

## 交互行为

### 悬停状态

```qml
Rectangle {
    id: button
    color: hovered ? Theme.surfaceHover : Theme.surface

    property bool hovered: false

    HoverHandler {
        onHoveredChanged: button.hovered = hovered
    }

    Behavior on color {
        ColorAnimation { duration: 80 }
    }
}
```

### 点击反馈

```qml
Rectangle {
    id: clickable
    color: pressed ? Theme.surfaceActive : (hovered ? Theme.surfaceHover : "transparent")

    property bool hovered: false
    property bool pressed: false

    HoverHandler {
        onHoveredChanged: clickable.hovered = hovered
    }

    TapHandler {
        onPressedChanged: clickable.pressed = pressed
        onTapped: console.log("Clicked!")
    }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

### 焦点管理

```qml
TextInput {
    id: input
    focus: true

    // 焦点边框
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: Theme.radiusSm + 2
        color: "transparent"
        border.color: input.activeFocus ? Theme.accentForeground : "transparent"
        border.width: 2
    }
}
```

### 键盘导航

```qml
ListView {
    id: list
    focus: true
    keyNavigationEnabled: true
    highlightFollowsCurrentItem: true

    Keys.onUpPressed: decrementCurrentIndex()
    Keys.onDownPressed: incrementCurrentIndex()
    Keys.onReturnPressed: {
        if (currentItem)
            currentItem.activate()
    }
}
```

---

## 响应式布局

### 窗口尺寸断点

```qml
QtObject {
    readonly property bool isCompact: mainWindow.width < 900
    readonly property bool isMedium: mainWindow.width >= 900 && mainWindow.width < 1200
    readonly property bool isLarge: mainWindow.width >= 1200
}

// 使用
Item {
    width: breakpoints.isCompact ? 60 : 240
    visible: !breakpoints.isCompact

    Behavior on width {
        NumberAnimation { duration: 200 }
    }
}
```

### 自适应间距

```qml
Row {
    spacing: breakpoints.isCompact ? Theme.spacingS : Theme.spacingL
}
```

### 折叠面板

```qml
Item {
    id: sidebar
    width: collapsed ? 60 : 240
    property bool collapsed: false

    Behavior on width {
        NumberAnimation {
            duration: Theme.animNormal
            easing.type: Easing.OutCubic
        }
    }

    // 内容根据宽度调整
    Column {
        anchors.fill: parent
        spacing: Theme.spacingS

        Repeater {
            model: items
            delegate: Item {
                width: parent.width
                height: 40

                AppIcon {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingL
                    size: 20
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 50
                    text: model.label
                    visible: !sidebar.collapsed
                    opacity: sidebar.collapsed ? 0 : 1

                    Behavior on opacity {
                        NumberAnimation { duration: 120 }
                    }
                }
            }
        }
    }
}
```
