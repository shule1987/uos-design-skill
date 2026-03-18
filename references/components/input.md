---
inclusion: manual
---

# 输入框组件

## TextField

```
普通状态：
┌─────────────────────────┐
│ 请输入文本...            │
└─────────────────────────┘

聚焦状态：
┏━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 输入的文本|              ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━┛
  (活动色边框，光标闪烁)
```

## SearchField

```
┌─────────────────────────┐
│ 🔍 搜索...            ✕ │
└─────────────────────────┘
  图标   占位符      清除
```

> 示例描述：这里定义 `TextField` 组件，基于 `Rectangle` 实现，对外暴露 `text`、`placeholderText` 和 `accessibleName` 等属性。 尺寸与样式上宽度使用 `200`，高度使用 `36`，圆角使用 `Theme.radiusSm`；结构上使用 `TextInput` 和 `Text` 组织内容；交互上覆盖无障碍语义、过渡动画。

## SearchField
> 示例描述：这里定义 `SearchField` 组件，基于 `Rectangle` 实现，对外暴露 `text` 和 `accessibleName` 等属性，并通过 `searchRequested` 发出交互事件。 尺寸与样式上宽度使用 `240`，高度使用 `32`，圆角使用 `Theme.radiusSm`；结构上使用 `AppIcon`、`TextInput` 和 `IconButton` 组织内容；交互上覆盖点击触发、无障碍语义、过渡动画。
