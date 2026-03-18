---
inclusion: manual
---

# 菜单组件

- 优先使用 DTK 菜单和菜单项。自定义菜单主要用于复杂 delegate、混排内容或平台控件不足的场景。

## MenuItem

```
┌─────────────────────────┐
│ 🔍 搜索         Ctrl+F  │
│ 📄 新建         Ctrl+N  │
│ 💾 保存         Ctrl+S  │
├─────────────────────────┤
│ ✓ 显示行号              │
│   自动换行              │
├─────────────────────────┤
│ ⚙️ 设置                 │
└─────────────────────────┘
  图标  文本      快捷键
```

> 示例描述：这里定义 `MenuItem` 组件，基于 `Rectangle` 实现，对外暴露 `text`、`iconName`、`shortcut`、`checked`、`checkable` 和 `enabled` 等属性，并通过 `triggered` 发出交互事件。 尺寸与样式上宽度使用 `parent.width`，高度使用 `24`，透明度使用 `enabled ? 1.0 : 0.5`；结构上使用 `Row` 和 `Text` 组织内容；交互上覆盖悬停反馈、点击触发、键盘回车和空格操作、无障碍语义、过渡动画。

## PopupMenu
> 示例描述：这里定义 `PopupMenu` 组件，基于 `Popup` 实现，对外暴露 `entries` 等属性。 尺寸与样式上宽度使用 `Math.max(180, menuColumn.implicitWidth + 12)`，内边距使用 `6`；结构上使用 `Column` 组织内容；交互上覆盖过渡动画。
