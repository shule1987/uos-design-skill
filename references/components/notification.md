---
inclusion: manual
---

# 通知组件

## Notification
> 示例描述：这里定义 `Notification` 组件，基于 `Rectangle` 实现，对外暴露 `type`、`title`、`message` 和 `duration` 等属性。 尺寸与样式上宽度使用 `320`，高度使用 `contentColumn.height + Theme.spacingL * 2`，圆角使用 `Theme.radiusMd`，透明度使用 `0`；结构上使用 `Column`、`IconButton` 和 `Timer` 组织内容；交互上覆盖点击触发、过渡动画。
