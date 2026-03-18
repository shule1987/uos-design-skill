---
inclusion: manual
---

# 骨架屏组件

## Skeleton
> 示例描述：这里定义 `Skeleton` 组件，基于 `Rectangle` 实现，对外暴露 `variant` 和 `lines` 等属性。 尺寸与样式上宽度使用 `variant === "circle" ? 48 : 200`，高度使用 `variant === "circle" ? 48 : (variant === "text" ? 16 : 100)`，圆角使用 `variant === "circle" ? width / 2 : 4`；交互上覆盖过渡动画。

## SkeletonGroup
> 示例描述：这里定义 `SkeletonGroup` 组件，基于 `Column` 实现，对外暴露 `lines` 等属性。 尺寸与样式上间距使用 `Theme.spacingS`；结构上使用 `Repeater` 组织内容。
