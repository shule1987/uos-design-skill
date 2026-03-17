---
inclusion: always
---

# 设计系统 - 窗口行为规范

## 窗口系统

### 窗口类型

#### 1. 主窗口（Main Window）
```qml
ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800
    minimumWidth: 800
    minimumHeight: 600
    visible: true
    color: "transparent"  // 支持透明背景

    // 无边框窗口（自定义标题栏）
    flags: Qt.Window | Qt.FramelessWindowHint

    // 背景模糊色调
    Rectangle {
        anchors.fill: parent
        color: Colors.blurTint
    }
}
```

#### 2. 弹窗（Popup Window）
```qml
Popup {
    id: popup
    popupType: Popup.Window  // 独立窗口
    width: 300
    height: 400
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

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

    // 窗口模糊
    WindowBlur {
        window: popup.Window.window
        enabled: popup.visible
        blurRadius: 12
    }
}
```

### 窗口拖动

#### 标题栏拖动区域
```qml
Item {
    id: titleBar
    height: 38
    anchors { left: parent.left; right: parent.right; top: parent.top }

    // 拖动处理
    DragHandler {
        target: null
        onActiveChanged: {
            if (active)
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
        onActiveChanged: if (active) root.Window.window.startSystemMove()
    }

    TapHandler {
        onDoubleTapped: {
            if (root.Window.window.visibility === Window.Maximized)
                root.Window.window.showNormal()
            else
                root.Window.window.showMaximized()
        }
    }
}
```

### 窗口控制按钮

```qml
component WinButton: Item {
    id: winBtn
    property string iconName: ""
    property bool isClose: false
    signal clicked()

    width: 46
    height: 38

    Rectangle {
        anchors.fill: parent
        color: hov.hovered ? Colors.chromeTopHoverFill : "transparent"
        Behavior on color { ColorAnimation { duration: 80 } }
    }

    AppIcon {
        anchors.centerIn: parent
        name: winBtn.iconName
        size: 14
        color: hov.hovered ? Colors.chromeTopIconHover : Colors.chromeTopIconNormal
    }

    HoverHandler { id: hov }
    TapHandler { onTapped: winBtn.clicked() }
}

// 使用
Row {
    id: winButtons
    anchors { right: parent.right; verticalCenter: parent.verticalCenter }
    spacing: 0

    WinButton {
        iconName: "minus"
        onClicked: mainWindow.showMinimized()
    }
    WinButton {
        iconName: "maximize-2"
        onClicked: {
            if (mainWindow.visibility === Window.Maximized)
                mainWindow.showNormal()
            else
                mainWindow.showMaximized()
        }
    }
    WinButton {
        iconName: "x"
        isClose: true
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
        border.color: input.activeFocus ? Theme.accent : "transparent"
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
