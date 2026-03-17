---
inclusion: manual
---

# 设计系统 - 窗口布局规范

## 应用窗口结构

### 标准应用布局（带侧边栏）

```
┌──────────┬──────────────────────────────────────┐
│          │  标题栏 (40px)          ☰  ─  □  ✕  │
│  [Logo]  ├──────────────────────────────────────┤
│  (32px)  │                                      │
│          │                                      │
│  侧边栏  │           主内容区域                  │
│ (240px)  │                                      │
│ [毛玻璃] │                                      │
│          │                                      │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

```qml
ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800

    Row {
        anchors.fill: parent
        spacing: 0

        // 左侧边栏
        Rectangle {
            width: 240
            height: parent.height
            color: Theme.bgPanel

            Column {
                anchors.fill: parent
                spacing: 0

                // 应用 Logo
                Item {
                    width: parent.width
                    height: 60

                    Image {
                        width: 32
                        height: 32
                        anchors.centerIn: parent
                        source: "qrc:/logo.svg"
                    }
                }

                // 侧边栏内容
                Item {
                    width: parent.width
                    height: parent.height - 60
                }
            }

            // 毛玻璃效果
            WindowBlur {
                anchors.fill: parent
                radius: 64
                z: -1
            }
        }

        // 分割线
        Rectangle {
            width: 1
            height: parent.height
            color: Theme.divider
        }

        // 右侧内容区
        Column {
            width: parent.width - 241
            height: parent.height
            spacing: 0

            // 标题栏
            Item {
                width: parent.width
                height: 40

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0

                    IconButton { icon.name: "menu" }
                    IconButton { icon.name: "window-minimize" }
                    IconButton { icon.name: "window-maximize" }
                    IconButton { icon.name: "window-close"; hoverColor: Theme.danger }
                }
            }

            // 主内容
            Item {
                width: parent.width
                height: parent.height - 40
            }
        }
    }
}
```

### 简单应用布局（无侧边栏）

```
┌─────────────────────────────────────────────────┐
│  [Logo]  标题栏 (40px)          ☰  ─  □  ✕     │
│  (32px)                                         │
├─────────────────────────────────────────────────┤
│                                                 │
│                                                 │
│              主内容区域                          │
│                                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

```qml
ApplicationWindow {
    id: mainWindow
    width: 1200
    height: 800

    Column {
        anchors.fill: parent
        spacing: 0

        // 标题栏
        Item {
            width: parent.width
            height: 40

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Image {
                    width: 32
                    height: 32
                    source: "qrc:/logo.svg"
                }

                Text {
                    text: "应用名称"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: Theme.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: 0

                IconButton { icon.name: "menu" }
                IconButton { icon.name: "window-minimize" }
                IconButton { icon.name: "window-maximize" }
                IconButton { icon.name: "window-close"; hoverColor: Theme.danger }
            }
        }

        // 主内容区
        Item {
            width: parent.width
            height: parent.height - 40
        }
    }
}
```

---

## 常见布局模式

### 1. 单栏布局（Simple）

```
┌─────────────────────────────────────────────────┐
│  标题栏                                          │
├─────────────────────────────────────────────────┤
│                                                 │
│          ┌─────────────────────┐                │
│          │                     │                │
│          │    内容区域         │                │
│          │   (max 600px)       │                │
│          │                     │                │
│          └─────────────────────┘                │
│                                                 │
└─────────────────────────────────────────────────┘
```

```qml
// 适用：设置页面、简单表单
Item {
    Column {
        anchors.centerIn: parent
        width: Math.min(600, parent.width - 48)
        spacing: Theme.spacingL

        Text { text: "标题" }
        TextField { }
        BaseButton { text: "提交" }
    }
}
```

### 2. 侧边栏布局（Sidebar）

```
┌─────────────────────────────────────────────────┐
│  标题栏                                          │
├──────────┬──────────────────────────────────────┤
│          │                                      │
│  侧边栏  │                                      │
│ (240px)  │         主内容区域                    │
│  [毛玻璃] │                                      │
│          │                                      │
└──────────┴──────────────────────────────────────┘
```

```qml
// 适用：文件管理器、笔记应用
Row {
    anchors.fill: parent
    spacing: 0

    // 侧边栏
    Rectangle {
        width: 240
        height: parent.height
        color: Theme.bgPanel
    }

    // 分割线
    Rectangle {
        width: 1
        height: parent.height
        color: Theme.divider
    }

    // 主内容
    Item {
        width: parent.width - 241
        height: parent.height
    }
}
```

### 3. 三栏布局（Three Column）

```
┌─────────────────────────────────────────────────┐
│  标题栏                                          │
├────────┬──────────┬───────────────────────────────┤
│        │          │                              │
│ 左侧栏 │  中间栏  │                              │
│(200px) │ (280px)  │        右侧内容区             │
│ [导航] │  [列表]  │                              │
│        │          │                              │
└────────┴──────────┴───────────────────────────────┘
```

```qml
// 适用：邮件客户端、笔记应用
Row {
    anchors.fill: parent
    spacing: 0

    // 左侧边栏（导航）
    Rectangle {
        width: 200
        height: parent.height
        color: Theme.bgPanel
    }

    Rectangle { width: 1; height: parent.height; color: Theme.divider }

    // 中间列表
    Rectangle {
        width: 280
        height: parent.height
        color: Theme.bg
    }

    Rectangle { width: 1; height: parent.height; color: Theme.divider }

    // 右侧内容
    Item {
        width: parent.width - 481
        height: parent.height
    }
}
```

### 4. 主从布局（Master-Detail）

```
┌─────────────────────────────────────────────────┐
│  标题栏                                          │
├──────────────┬──────────────────────────────────┤
│              │                                  │
│   主列表     │                                  │
│   (30%)      │         详情区域 (70%)           │
│              │                                  │
│              │                                  │
└──────────────┴──────────────────────────────────┘
```

```qml
// 适用：设置页面、详情页
Row {
    anchors.fill: parent
    spacing: 0

    // 主列表（30%）
    ListView {
        width: parent.width * 0.3
        height: parent.height
        clip: true
    }

    Rectangle { width: 1; height: parent.height; color: Theme.divider }

    // 详情区（70%）
    Item {
        width: parent.width * 0.7 - 1
        height: parent.height
    }
}
```

### 5. 浏览器布局（Browser）

```
┌─────────────────────────────────────────────────┐
│  标签栏 (38px)    [标签1] [标签2] [+]           │
├─────────────────────────────────────────────────┤
│  导航栏 (44px)    ← → ⟳  [地址栏]      ⋮       │
├─────────────────────────────────────────────────┤
│  书签栏 (32px)    [书签1] [书签2] [书签3]       │
├─────────────────────────────────────────────────┤
│                                                 │
│              网页内容区域                        │
│                                                 │
└─────────────────────────────────────────────────┘
```

```qml
// 适用：浏览器、Web 应用
Column {
    anchors.fill: parent
    spacing: 0

    // 标签栏
    Item { width: parent.width; height: 38 }

    // 导航栏
    Item { width: parent.width; height: 44 }

    // 书签栏（可选）
    Item { width: parent.width; height: visible ? 32 : 0 }

    // 内容区
    Item {
        width: parent.width
        height: parent.height - 38 - 44 - (bookmarkBar.visible ? 32 : 0)
    }
}
```

---

## 响应式布局

### 断点系统
```qml
QtObject {
    id: breakpoints

    // 窗口宽度断点
    readonly property int compact: 600      // 紧凑模式
    readonly property int medium: 900       // 中等模式
    readonly property int large: 1200       // 大屏模式
    readonly property int xlarge: 1600      // 超大屏

    // 当前状态
    readonly property bool isCompact: width < compact
    readonly property bool isMedium: width >= compact && width < large
    readonly property bool isLarge: width >= large && width < xlarge
    readonly property bool isXLarge: width >= xlarge
}
```

### 自适应侧边栏
```qml
Item {
    id: sidebar
    width: {
        if (breakpoints.isCompact) return 0
        if (breakpoints.isMedium) return 60
        return 240
    }
    visible: width > 0

    Behavior on width {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
```

### 折叠式布局
```qml
Row {
    anchors.fill: parent

    // 侧边栏：大屏显示，小屏隐藏
    Loader {
        active: !breakpoints.isCompact
        width: active ? 240 : 0
        sourceComponent: Sidebar { }
    }

    // 主内容：自适应宽度
    Item {
        width: parent.width - (sidebar.active ? 240 : 0)
        height: parent.height
    }
}
```

---

## 内容区布局

### 居中内容
```qml
// 适用：登录页、空状态
Item {
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL
        width: 400

        Text { text: "欢迎" }
        TextField { }
        BaseButton { text: "登录" }
    }
}
```

### 卡片网格
```qml
// 适用：图库、卡片列表
ScrollView {
    anchors.fill: parent

    Flow {
        width: parent.width
        spacing: Theme.spacingL
        padding: Theme.spacingL

        Repeater {
            model: items
            delegate: Card {
                width: 280
                height: 320
            }
        }
    }
}
```

### 列表视图
```qml
// 适用：文件列表、消息列表
ListView {
    anchors.fill: parent
    spacing: 0
    clip: true

    model: items
    delegate: ListItem {
        width: parent.width
        height: 44
    }
}
```

### 表格布局
```qml
// 适用：数据表格
Column {
    anchors.fill: parent
    spacing: 0

    // 表头
    Row {
        width: parent.width
        height: 40

        Repeater {
            model: ["名称", "大小", "日期"]
            delegate: Text {
                width: parent.width / 3
                text: modelData
                font.weight: Font.Medium
            }
        }
    }

    // 表格内容
    ListView {
        width: parent.width
        height: parent.height - 40
        model: tableData
        delegate: Row {
            width: parent.width
            height: 36
            // 单元格
        }
    }
}
```

---

## 分割面板

### 水平分割
```qml
Item {
    id: splitView
    property real splitPosition: 0.3

    Item {
        id: leftPane
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: parent.width * splitPosition
    }

    Rectangle {
        id: divider
        anchors { left: leftPane.right; top: parent.top; bottom: parent.bottom }
        width: 1
        color: Theme.divider
    }

    Rectangle {
        id: handle
        anchors { left: divider.left; top: parent.top; bottom: parent.bottom }
        width: 8
        x: -4
        color: hovered ? Theme.accent : "transparent"
        opacity: 0.3

        property bool hovered: false
        HoverHandler { onHoveredChanged: handle.hovered = hovered }

        DragHandler {
            target: null
            xAxis.enabled: true
            onTranslationChanged: {
                splitPosition = Math.max(0.2, Math.min(0.8,
                    (leftPane.width + translation.x) / splitView.width))
            }
        }
    }

    Item {
        anchors { left: divider.right; right: parent.right; top: parent.top; bottom: parent.bottom }
    }
}
```

### 垂直分割
```qml
Item {
    property real splitPosition: 0.5

    Item {
        anchors { left: parent.left; right: parent.right; top: parent.top }
        height: parent.height * splitPosition
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; top: topPane.bottom }
        height: 1
        color: Theme.divider
    }

    Item {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom; top: divider.bottom }
    }
}
```

---

## 浮动元素

### 浮动面板
```qml
// 浮动在内容之上
Item {
    // 主内容
    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }

    // 浮动面板
    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: Theme.spacingL
            topMargin: Theme.spacingL
            bottomMargin: Theme.spacingL
        }
        width: 320
        radius: Theme.radiusLg
        color: Theme.cardBg
        z: 100

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.2)
            shadowBlur: 0.5
        }
    }
}
```

### 抽屉（Drawer）
```qml
Item {
    id: drawer
    property bool open: false

    Rectangle {
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: 360
        x: drawer.open ? 0 : width
        color: Theme.bgPanel
        z: 200

        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }
    }

    // 遮罩
    Rectangle {
        anchors.fill: parent
        color: Theme.scrim
        opacity: drawer.open ? 1 : 0
        visible: opacity > 0
        z: 199

        TapHandler { onTapped: drawer.open = false }

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }
}
```

---

## 堆叠布局（StackView）

### 页面切换
```qml
StackView {
    id: stackView
    anchors.fill: parent
    initialItem: homePage

    // 推入动画
    pushEnter: Transition {
        PropertyAnimation {
            property: "x"
            from: stackView.width
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    // 推出动画
    pushExit: Transition {
        PropertyAnimation {
            property: "x"
            from: 0
            to: -stackView.width * 0.3
            duration: 250
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            property: "opacity"
            from: 1
            to: 0
            duration: 250
        }
    }

    // 返回动画
    popEnter: Transition {
        PropertyAnimation {
            property: "x"
            from: -stackView.width * 0.3
            to: 0
            duration: 250
            easing.type: Easing.OutCubic
        }
        PropertyAnimation {
            property: "opacity"
            from: 0
            to: 1
            duration: 250
        }
    }

    popExit: Transition {
        PropertyAnimation {
            property: "x"
            from: 0
            to: stackView.width
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
}
```

---

## 标签页布局（TabView）

### 顶部标签
```qml
Column {
    anchors.fill: parent
    spacing: 0

    // 标签栏
    Row {
        width: parent.width
        height: 40
        spacing: 4

        Repeater {
            model: ["首页", "设置", "关于"]
            delegate: Rectangle {
                width: 100
                height: 36
                radius: Theme.radiusSm
                color: index === currentTab ? Theme.surfaceActive : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: Theme.textPrimary
                }

                TapHandler { onTapped: currentTab = index }
            }
        }
    }

    // 内容区
    StackLayout {
        width: parent.width
        height: parent.height - 40
        currentIndex: currentTab

        Item { /* 首页 */ }
        Item { /* 设置 */ }
        Item { /* 关于 */ }
    }
}
```

---

## 网格布局

### 固定列数
```qml
Grid {
    anchors.fill: parent
    columns: 4
    spacing: Theme.spacingL
    padding: Theme.spacingL

    Repeater {
        model: 12
        delegate: Card {
            width: (parent.width - parent.spacing * 3 - parent.padding * 2) / 4
            height: 200
        }
    }
}
```

### 响应式网格
```qml
Grid {
    anchors.fill: parent
    columns: {
        if (width < 600) return 1
        if (width < 900) return 2
        if (width < 1200) return 3
        return 4
    }
    spacing: Theme.spacingL
    padding: Theme.spacingL

    Repeater {
        model: items
        delegate: Card {
            width: (parent.width - parent.spacing * (parent.columns - 1) - parent.padding * 2) / parent.columns
        }
    }
}
```

---

## 滚动区域

### 垂直滚动
```qml
ScrollView {
    anchors.fill: parent
    clip: true

    Column {
        width: parent.width
        spacing: Theme.spacingL
        padding: Theme.spacingL

        Repeater {
            model: 50
            delegate: ListItem { }
        }
    }
}
```

### 水平滚动
```qml
ScrollView {
    width: parent.width
    height: 200
    contentWidth: row.width
    clip: true

    Row {
        id: row
        spacing: Theme.spacingM

        Repeater {
            model: 20
            delegate: Card { width: 200; height: 180 }
        }
    }
}
```

---

## 空状态布局

### 空列表
```qml
Item {
    anchors.fill: parent

    Column {
        anchors.centerIn: parent
        spacing: Theme.spacingL
        width: 300

        AppIcon {
            anchors.horizontalCenter: parent.horizontalCenter
            name: "inbox"
            size: 64
            color: Theme.textMuted
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "暂无内容"
            font.pixelSize: 18
            font.weight: Font.Medium
            color: Theme.textPrimary
        }

        Text {
            width: parent.width
            text: "开始添加你的第一个项目"
            font.pixelSize: 14
            color: Theme.textSecondary
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        BaseButton {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "添加项目"
            primary: true
        }
    }
}
```

---

## 加载状态布局

### 骨架屏
```qml
Column {
    anchors.fill: parent
    spacing: Theme.spacingM
    padding: Theme.spacingL

    Repeater {
        model: 5
        delegate: Row {
            width: parent.width - parent.padding * 2
            spacing: Theme.spacingM

            Rectangle {
                width: 48
                height: 48
                radius: 24
                color: Theme.surface
            }

            Column {
                spacing: Theme.spacingS
                width: parent.width - 48 - parent.spacing

                Rectangle {
                    width: parent.width * 0.6
                    height: 16
                    radius: 4
                    color: Theme.surface
                }

                Rectangle {
                    width: parent.width * 0.4
                    height: 12
                    radius: 4
                    color: Theme.surface
                }
            }
        }
    }
}
```

---

## 布局最佳实践

### 1. 使用 anchors 而非固定坐标
```qml
// ✅ 好
Rectangle {
    anchors { left: parent.left; right: parent.right; top: parent.top }
    height: 40
}

// ❌ 避免
Rectangle {
    x: 0
    y: 0
    width: 800
    height: 40
}
```

### 2. 合理使用 spacing 和 padding
```qml
Column {
    spacing: Theme.spacingM  // 子元素间距
    padding: Theme.spacingL  // 容器内边距
}
```

### 3. 响应式优先
```qml
Item {
    width: Math.min(600, parent.width - 48)  // 最大宽度 + 边距
}
```

### 4. 避免嵌套过深
```qml
// ✅ 扁平化
Row {
    Item { }
    Item { }
}

// ❌ 过度嵌套
Item {
    Item {
        Item {
            Row { }
        }
    }
}
```

### 5. 使用 Loader 延迟加载
```qml
Loader {
    active: visible
    sourceComponent: HeavyComponent { }
}
```
```
