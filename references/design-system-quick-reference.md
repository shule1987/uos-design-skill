---
inclusion: manual
---

# 设计系统 - 快速参考指南

## 快速开始

### 导入主题

```qml
import QtQuick
import "../theme"

Item {
    // 使用主题颜色
    Rectangle {
        color: Theme.bg
    }

    // 使用主题字体
    Text {
        font.family: Theme.fontSans
        font.pixelSize: Theme.bodySize
        color: Theme.textPrimary
    }
}
```

---

## 常用颜色速查

### 背景色
```qml
Theme.bg              // 主背景
Theme.bgPanel         // 面板背景
Theme.surface         // 控件表面
Theme.surfaceHover    // 悬停态
Theme.surfaceActive   // 激活态
Theme.popupBg         // 弹窗背景
Theme.cardBg          // 卡片背景
```

### 文字色
```qml
Theme.textPrimary     // 主要文字
Theme.textSecondary   // 次要文字
Theme.textMuted       // 弱化文字
Theme.textDisabled    // 禁用文字
```

### 强调色
```qml
Theme.accent          // 主强调色
Theme.success         // 成功
Theme.warning         // 警告
Theme.danger          // 危险/错误
```

### 边框色
```qml
Theme.border          // 常规边框
Theme.borderStrong    // 强调边框
Theme.divider         // 分割线
```

---

## 常用尺寸速查

### 圆角
```qml
Theme.radiusSm: 6     // 小圆角
Theme.radiusMd: 10    // 中圆角
Theme.radiusLg: 14    // 大圆角
Theme.radiusXl: 18    // 超大圆角
```

### 间距
```qml
Theme.spacingXS: 4    // 超小间距
Theme.spacingS: 8     // 小间距
Theme.spacingM: 12    // 中间距
Theme.spacingL: 16    // 大间距
Theme.spacingXL: 24   // 超大间距
```

### 动画时长
```qml
Theme.animFast: 120      // 快速 (悬停、点击)
Theme.animNormal: 200    // 常规 (展开、切换)
Theme.animSlow: 350      // 慢速 (大型动画)
```

---

## 常用组件模板

### 按钮
```qml
Rectangle {
    width: 100
    height: 36
    radius: Theme.radiusSm
    color: hovered ? Theme.surfaceHover : Theme.surface

    Text {
        anchors.centerIn: parent
        text: "按钮"
        color: Theme.textPrimary
    }

    property bool hovered: false
    HoverHandler { onHoveredChanged: parent.hovered = hovered }
    TapHandler { onTapped: console.log("Clicked") }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

### 输入框
```qml
Rectangle {
    width: 200
    height: 36
    radius: Theme.radiusSm
    color: Theme.surface
    border.color: input.activeFocus ? Theme.accent : Theme.border
    border.width: 1

    TextInput {
        id: input
        anchors.fill: parent
        anchors.margins: Theme.spacingM
        font.pixelSize: 13
        color: Theme.textPrimary
        selectByMouse: true
    }
}
```

### 列表项
```qml
Rectangle {
    width: parent.width
    height: 44
    color: hovered ? Theme.surfaceHover : "transparent"

    Text {
        anchors.centerIn: parent
        text: "列表项"
        color: Theme.textPrimary
    }

    property bool hovered: false
    HoverHandler { onHoveredChanged: parent.hovered = hovered }
    TapHandler { onTapped: console.log("Clicked") }

    Behavior on color { ColorAnimation { duration: 80 } }
}
```

### 卡片
```qml
Rectangle {
    width: 280
    height: 200
    radius: Theme.radiusMd
    color: Theme.cardBg
    border.color: Theme.border
    border.width: 1

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.1)
        shadowBlur: 0.3
        shadowVerticalOffset: 2
    }
}
```

---

## 动画模板

### 颜色过渡
```qml
Behavior on color {
    ColorAnimation { duration: Theme.animFast }
}
```

### 尺寸变化
```qml
Behavior on width {
    NumberAnimation {
        duration: Theme.animNormal
        easing.type: Easing.OutCubic
    }
}
```

### 淡入淡出
```qml
enter: Transition {
    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 120 }
}
exit: Transition {
    NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 80 }
}
```

### 缩放动画
```qml
Behavior on scale {
    NumberAnimation {
        duration: 120
        easing.type: Easing.OutBack
    }
}
```

---

## 布局模式

### 水平布局
```qml
Row {
    spacing: Theme.spacingM
    anchors.centerIn: parent

    AppIcon { name: "user"; size: 20 }
    Text { text: "用户名" }
}
```

### 垂直布局
```qml
Column {
    spacing: Theme.spacingS
    width: parent.width

    Text { text: "标题" }
    Text { text: "描述" }
}
```

### 网格布局
```qml
Grid {
    columns: 3
    spacing: Theme.spacingL

    Repeater {
        model: 9
        delegate: Rectangle {
            width: 100
            height: 100
        }
    }
}
```

---

## 响应式设计

### 断点定义
```qml
QtObject {
    readonly property bool isCompact: width < 600
    readonly property bool isMedium: width >= 600 && width < 1200
    readonly property bool isLarge: width >= 1200
}
```

### 自适应布局
```qml
Item {
    width: breakpoints.isCompact ? 60 : 240

    Behavior on width {
        NumberAnimation { duration: 200 }
    }
}
```

---

## 性能优化清单

### ✅ 推荐做法
- 使用 `Behavior` 而非手动 `Animation`
- 限制 `clip: true` 的使用
- 使用 `Loader` 延迟加载重型组件
- 避免深层嵌套的绑定
- 使用 `readonly property` 优化只读属性

### ❌ 避免做法
- 不要在循环中创建大量对象
- 避免频繁的 `grabToImage` 调用
- 不要过度使用模糊效果
- 避免复杂的 JavaScript 表达式绑定

---

## 可访问性清单

### 键盘导航
```qml
Item {
    focus: true
    Keys.onReturnPressed: activate()
    Keys.onSpacePressed: activate()
    Keys.onEscapePressed: cancel()
}
```

### 对比度要求
- 正文文字：至少 4.5:1
- 大号文字：至少 3:1
- 图标和控件：至少 3:1

### 焦点指示
```qml
Rectangle {
    border.color: activeFocus ? Theme.accent : "transparent"
    border.width: 2
}
```

---

## 调试技巧

### 显示边界
```qml
Rectangle {
    border.color: "red"
    border.width: Settings.debugMode ? 1 : 0
}
```

### 性能计时
```qml
Component.onCompleted: console.time("Load")
Component.onDestruction: console.timeEnd("Load")
```

### 属性监控
```qml
onWidthChanged: console.log("Width:", width)
```

---

## 设计决策流程

### 选择颜色
1. 背景层 → `Theme.bg` / `Theme.bgPanel`
2. 控件表面 → `Theme.surface`
3. 交互状态 → `Theme.surfaceHover` / `Theme.surfaceActive`
4. 强调元素 → `Theme.accent`
5. 功能色 → `Theme.success` / `Theme.warning` / `Theme.danger`

### 选择圆角
- 小控件（按钮、输入框）→ `radiusSm` (6px)
- 中型容器（卡片、面板）→ `radiusMd` (10px)
- 大型容器（对话框）→ `radiusLg` (14px)
- 圆形按钮 → `width/2`

### 选择间距
- 紧密元素 → `spacingXS` (4px)
- 相关元素 → `spacingS` (8px)
- 常规间距 → `spacingM` (12px)
- 区块间距 → `spacingL` (16px)
- 页面边距 → `spacingXL` (24px)

### 选择动画
- 即时反馈（悬停）→ 80-120ms
- 状态切换 → 200ms
- 布局变化 → 350ms

---

## 常见问题

### Q: 如何实现毛玻璃效果？
```qml
GlassLayer {
    anchors.fill: parent
    targetItem: parent
    radius: Theme.radiusMd
    effectEnabled: Settings.enableBlur
}
```

### Q: 如何实现深浅主题切换？
```qml
readonly property bool dark: Theme.mode === "dark" ||
    (Theme.mode === "system" && Qt.styleHints.colorScheme === Qt.ColorScheme.Dark)
```

### Q: 如何优化列表性能？
```qml
ListView {
    cacheBuffer: 200  // 缓存屏幕外内容
    reuseItems: true  // 重用列表项
    clip: true
}
```

### Q: 如何实现拖动排序？
```qml
DragHandler {
    onActiveChanged: {
        if (active) startDrag()
        else endDrag()
    }
}
```

---

## 资源链接

### 相关文档
- `references/foundations/colors.md` - 颜色与主题变量
- `references/foundations/typography.md` - 字体、字号、字重
- `references/foundations/spacing.md` - 间距与圆角
- `references/foundations/animation.md` - 动画时长与缓动
- `references/design-system-window-behavior.md` - 窗口行为规范
- `references/design-system-layout.md` - 布局模式与响应式规范
- `references/components/` - 各组件的独立参考文档

### 示例项目
- Unote - 笔记应用设计参考
- Veyan - 浏览器界面设计参考

---

## 版本历史

**v1.0** - 2026-03-17
- 基于 Unote 和 Veyan 项目整理
- 完整的颜色系统
- 排版和间距规范
- 圆角和动画系统
- 模糊效果实现
- 窗口行为规范
- 完整的控件库
- 最佳实践指南
