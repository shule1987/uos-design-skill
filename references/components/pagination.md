---
inclusion: manual
---

# 分页组件

## Pagination

```
← [1] [2] [3] ... [10] →
  当前页  普通页  省略  末页

示例：
← 1  2  3  4  5 ... 20 →  (第1页)
← 1 ... 5  6  7 ... 20 →  (第6页)
← 1 ... 18 19 20 →        (第20页)
```

> 示例描述：这里定义 `Pagination` 组件，基于 `Row` 实现，对外暴露 `total`、`pageSize`、`current` 和 `totalPages` 等属性，并通过 `pageChanged` 发出交互事件。 尺寸与样式上间距使用 `Theme.spacingS`；结构上使用 `IconButton` 和 `Repeater` 组织内容；交互上覆盖悬停反馈、点击触发、键盘回车和空格操作、无障碍语义、过渡动画。
