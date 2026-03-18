---
inclusion: manual
---

# 列表组件

## ListItem
> 示例描述：这里定义 `ListItem` 组件，基于 `Rectangle` 实现，对外暴露 `title`、`subtitle`、`iconName` 和 `selected` 等属性，并通过 `clicked` 发出交互事件。 尺寸与样式上宽度使用 `parent.width`，高度使用 `subtitle ? 56 : 44`；结构上使用 `Row` 组织内容；交互上覆盖悬停反馈、点击触发、键盘回车和空格操作、无障碍语义、过渡动画。
