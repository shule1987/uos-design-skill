---
inclusion: manual
---

# 警告提示组件

## Alert
> 示例描述：这里定义 `Alert` 组件，基于 `Rectangle` 实现，对外暴露 `type`、`title`、`message` 和 `closable` 等属性，并通过 `closed` 发出交互事件。 尺寸与样式上宽度使用 `parent.width`，高度使用 `contentRow.height + Theme.spacingL * 2`，圆角使用 `Theme.radiusSm`；结构上使用 `Row` 和 `IconButton` 组织内容；交互上覆盖点击触发。
