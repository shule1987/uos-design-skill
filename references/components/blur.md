---
inclusion: manual
---

# 模糊效果

## GlassLayer
- 用途：用于在侧边栏、浮层和抽屉上叠加轻量玻璃感。
- 规则：默认采用 `模糊层 + 混色层` 的视觉逻辑，但优先使用 DTK 或系统 blur primitive 已内建的混色能力，而不是额外再画一层。
- 规则：如果 `D.StyledBehindWindowBlur`、`D.DWindow` 或经验证的系统装饰路径已经提供 `blendColor`、fallback tint 或等效混色层，不得再叠加第二层自绘半透明 `Rectangle`、纯混色 `ShaderEffect` 或截图着色层。
- 规则：只有在目标平台已验证 blur primitive 不提供混色层时，才允许补一个显式自绘混色层；该实现必须附带 `uos-design: allow-manual-blur-overlay` 说明具体平台和原因。
- 规则：对于带 blur 侧栏的左右分栏桌面应用，不要在 blur 侧栏背后再铺一整块不透明全窗底面。右侧页面底面必须限制在右侧内容区；否则 blur 会在视觉上退化成纯色面板。

## Header Toolbar Glass
- 用途：用于主窗口 header 或 toolbar 需要读出“同窗口内容在磨砂层下方滚动”的场景。
- 默认：先用 `references/components/unified-header.md` 的标准 DTK header recipe，让内容真实 underlap 到 header 下方，再验证 `D.StyledBehindWindowBlur` 是否已经足够。
- 窄例外：如果目标栈实机验证表明 `D.StyledBehindWindowBlur` 只提供 compositor blur/tint，无法读出同窗口内容运动，可在右侧 header content band 上补一层 live sampling：`ShaderEffectSource + MultiEffect`。
- 规则：这层 live sampling 只允许放在右侧 header content surface 上，且其 `sourceItem` 必须指向右侧内容基面，例如 `contentBase`；不要采样整个窗口，不要采样 sidebar blur surface。
- 规则：live sampling 是对“同窗口内容读感”的补充，不是结构替代。`Theme.bg` 内容基面和 `D.StyledBehindWindowBlur` 仍应保留。
- 规则：不要在 live sampling 之后再加一层整面 `Rectangle` 染色层。色相和明度调节优先放在 `MultiEffect` 参数和 `blendColor` token 中处理。
- 规则：header 右侧工具栏叠层的 tint alpha 仍参照 Unote：浅色 `0.7`，深色卡片/仪表板页 `0.6`，深色明细/线性页 `0.8`；但 tint 的 RGB 必须与主窗口背景 `Theme.bg` 一致，不再使用独立 toolbar 色。
- 规则：header live-sampled blur 的参数仍以 `blur: 0.62`、`blurMax: 72`、`saturation: 1.04`、`brightness: Theme.dark ? 0.06 : 0.03` 为基线，但 sampled blur layer 自身的 `opacity` 必须降到旧全强度配方的一半，默认读作 `0.5`。
- 规则：上述 Unote 叠层只属于右侧 header content band。侧边栏顶部任何时候都不允许再单独绘制一条工具栏背景去覆盖 sidebar 自身表面。
- 规则：内容可以 underlap 到 header 下方，但 scrollbar 轨道不可以。所有内容区滚动条都必须从可视内容区顶部开始，不能穿透到 header toolbar 或二级 toolbar 内。
- 规则：只有当页面内容已经真实 underlap 到 header 下方时，这个方案才有意义。若看不到效果，优先检查 shell/page 顶部 margin、header overlap 和 scroll range，而不是盲目加大 blur。

## WindowBlur
- 用途：用于依赖桌面 compositor 的窗口级模糊效果。
- 规则：只在平台支持、性能可接受且产品确实需要时启用；模糊半径保持克制，避免造成内容发灰。
- 规则：不要主观假设窗管或 compositor 一定会“自动补一层”混色。只有在文档、组件契约或运行时验证已经确认时，才能把该层视为系统提供。
- 规则：如果系统或 DTK 已提供混色层，再额外自绘叠层会导致表面发白、发灰或层次浑浊，应视为错误实现而不是视觉微调。

## Shadow
- 用途：用于卡片、对话框和弹出层的层级分离。
- 规则：阴影是辅助层级，不应代替边界、背景和间距本身的结构表达。
