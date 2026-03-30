---
inclusion: manual
---

# DTK Unified Header Recipe

Load this file when creating or refactoring a main window and you need the exact DTK unified-header wiring instead of only policy text.

## Default Main-Window Recipe

Use this as the default path for normal resizable main windows:

```qml
import QtQuick
import org.deepin.dtk 1.0 as D

D.ApplicationWindow {
    id: window

    visible: true
    color: "transparent"
    flags: Qt.Window
         | Qt.WindowTitleHint
         | Qt.WindowMinimizeButtonHint
         | Qt.WindowMaximizeButtonHint
         | Qt.WindowCloseButtonHint

    D.DWindow.enabled: true
    D.DWindow.themeType: Theme.dark
        ? D.ApplicationHelper.DarkType
        : D.ApplicationHelper.LightType

    header: D.TitleBar {
        id: titleBar

        content: Component {
            Item { anchors.fill: parent }
        }

        leftContent: Item {
            implicitWidth: 44
            implicitHeight: 36

            ThemedIcon {
                anchors.centerIn: parent
                source: Qt.resolvedUrl("../assets/logo-mark.svg")
                color: Theme.accentBackground
                implicitWidth: 20
                implicitHeight: 20
            }
        }

        menu: D.Menu {
            D.MenuItem { text: qsTr("设置") }
            D.MenuItem { text: qsTr("关于") }
            D.MenuSeparator {}
            D.MenuItem { text: qsTr("退出") }
        }

        D.WindowButtonGroup {
            anchors.top: parent.top
            anchors.right: parent.right
        }
    }
}
```

## Right-Top Button Rules

- 主窗口右上角固定读作：菜单、最小化、最大化 / 还原、关闭。
- 菜单按钮一律来自 `D.TitleBar.menu`。不要自己加第二个 `ToolButton` 菜单触发器。
- `D.WindowButtonGroup` 只负责最小化、最大化 / 还原、关闭，不负责菜单。
- `D.WindowButtonGroup` 必须直接贴在 live header 的真正右上角，不要包在居中的 `RowLayout` 里。
- 固定尺寸窗口去掉 `Qt.WindowMaximizeButtonHint`，让最大化 / 还原自然消失；不要手搓一套“假 disabled maximize”按钮。

## Left Side Rules

- 左上角默认只保留一个稳定的 logo 槽位。
- 所有应用窗口左上角的应用 logo 固定使用 `32x32`。不要在不同窗口、页面或状态里自行改成 16、20、22、24、28 等其他尺寸。
- 所有应用窗口左上角应用 logo 的左边缘固定距窗口左边 `9px`，禁止居中摆放在更宽槽位里后再发生横向漂移。
- 这个 `9px` 必须从 `D.TitleBar` 根边界起算；如果 `leftContent` 槽位自带 DTK 左侧内缩，就禁止把静态应用 logo 放进该槽位里再用 `leftMargin` 计算。
- 控制中心式持久侧栏窗口默认不在顶带里显示应用名文本或页面标题文本。
- 不要在侧栏导航顶部再复制一套 `logo + app name + description` 品牌头。
- 需要侧栏切换按钮时，放在 `leftContent`，与 logo 共享左侧 header 区，而不是塞进页面内容区。

## If Header Needs Extra Controls

Only add app-side controls to `D.TitleBar.content` when the product really needs tabs, a search field, or a compact tool cluster in the top band.

For page-switching tabs, this is the default and required slot.

Header page-switching controls are not document tabs. In the unified header, they must use a locally exported DTK grouped mutually-exclusive button path such as `D.ButtonBox`, `D.ButtonGroup`, or `D.ControlGroup`.

Do not use `TabBar` for main page switching in the unified header.

Header-toolbar action buttons should prefer symbolic 16px functional icons. Use text labels there only when icon-only meaning would be ambiguous or the product requirement explicitly calls for text.

When the header mixes page switching, search, and compact actions, center the visible control cluster within the live header lane instead of pinning it to the left edge. Reserve balanced safe areas against both `leftContent` and the top-right DTK menu/window-control strip, then center the app-side control band inside that remaining lane.

Every symbolic app-side header button other than the application logo slot, including functional `leftContent` affordances and grouped page-switch buttons, should explicitly set a `16x16` icon box. The application logo itself is not a 16px symbolic action icon; it must stay on the fixed `32x32` logo size.

Use this pattern:

```qml
header: D.TitleBar {
    id: titleBar

    readonly property int leftSafeArea: 56
    readonly property int rightSafeArea: Math.max(windowButtons.implicitWidth, windowButtons.width) + 48
    readonly property int balancedSafeArea: Math.max(leftSafeArea, rightSafeArea)
    readonly property int centeredContentWidth: Math.min(580, width - (balancedSafeArea * 2) - 24)

    leftContent: D.ToolButton {
        implicitWidth: 36
        implicitHeight: 36
        display: AbstractButton.IconOnly
        icon.width: 16
        icon.height: 16
    }

    content: Component {
        Item {
            anchors.fill: parent

            Item {
                width: titleBar.centeredContentWidth
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter

                RowLayout {
                    anchors.fill: parent

                    D.SearchEdit {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 260
                    }
                }
            }
        }
    }

    menu: D.Menu {}

    D.WindowButtonGroup {
        id: windowButtons
        anchors.top: parent.top
        anchors.right: parent.right
    }
}
```

Do not let `content` run under the menu button or `D.WindowButtonGroup`.
Do not describe a left-aligned fill-width search row as “centered header content”; the visible control band itself must be centered.

If the header hosts page-switching controls, keep that grouped button strip in this same `content` band instead of duplicating it in the page body or replacing it with a `TabBar`.

## Scroll Under Header

For scrollable desktop pages, keep a three-layer stack:

1. window base surface
2. scrollable content
3. frosted DTK header

Do not stop the visible content at the header line with a separate opaque toolbar slab.

Use this pattern when you need the content to visually continue under the header:

```qml
D.ApplicationWindow {
    id: window

    readonly property int headerOverlap: 52

    color: "transparent"

    header: D.TitleBar {
        id: titleBar

        Item {
            anchors.fill: parent
            z: -1

            D.StyledBehindWindowBlur {
                control: parent
                anchors.fill: parent
            }
        }
    }

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: Theme.bg
        }

        D.ScrollView {
            anchors.fill: parent
            clip: true
            topPadding: window.headerOverlap + 24
            contentHeight: contentColumn.implicitHeight + window.headerOverlap + 24

            ColumnLayout {
                id: contentColumn
                width: parent.width
            }
        }
    }
}
```

The important part is not the exact numbers. The rule is:

- the header remains the live top frosted layer
- content visually underlaps that header
- the scroll range includes the overlap so top and bottom content are not lost
- page content does not create a second toolbar-colored strip under the header

## Persistent-Sidebar Window Recipe

For control-center-style windows, the unified header still exists, but the left sidebar surface and the right content base should visually continue to the top edge under the header controls.

Use this underlay pattern behind the DTK header instead of one separate full-width titleband background:

```qml
header: D.TitleBar {
    Item {
        anchors.fill: parent
        z: -1

        Item {
            id: headerSidebarSurface
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: sidebarWidth

            D.StyledBehindWindowBlur {
                control: headerSidebarSurface
                anchors.fill: parent
                cornerRadius: 0
                blendColor: valid ? Theme.sidebarBlurBlend : Theme.sidebarBlurFallback
            }

            Rectangle {
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                width: 1
                color: Theme.divider
            }
        }

        Rectangle {
            anchors.left: headerSidebarSurface.right
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: Theme.bg
        }
    }
}
```

Below that header, keep the same split:

- 左侧 `sidebar` blur 面板
- 中间 `1px` divider
- 右侧 `content base`

Do not insert a separate full-width `Theme.bgToolbar` or `Theme.titlebarBg` strip that visually becomes a third layer above both panels.

## Live-Sampled Header Glass Fallback

Use this only when all of the following are true:

- the product explicitly wants an Unote-like "moving content behind frosted toolbar" read
- runtime validation on the target stack shows `D.StyledBehindWindowBlur` alone behaves like compositor tint and does not visibly carry same-window scrolling content through the header band
- the window still follows the normal DTK unified-header and persistent-sidebar structure

Keep the standard persistent-sidebar underlay, then scope the sampling layer to the right header content band only:

```qml
import QtQuick.Effects

Rectangle {
    id: headerContentSurface
    anchors.left: headerSidebarSurface.right
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: Theme.bg
    // uos-design: allow-live-header-sampling target stack only exposes compositor blur here,
    // so sample same-window content for the right header band.
    readonly property Item glassSourceItem: contentBase
    readonly property point blurSourcePos: {
        if (!glassSourceItem)
            return Qt.point(0, 0)
        return headerContentSurface.mapToItem(glassSourceItem, 0, 0)
    }

    D.StyledBehindWindowBlur {
        control: headerContentSurface
        anchors.fill: parent
        cornerRadius: 0
        blendColor: valid
                    ? Qt.rgba(
                          Theme.bg.r,
                          Theme.bg.g,
                          Theme.bg.b,
                          Theme.dark ? Theme.headerToolbarOverlayDarkCardOpacity : Theme.headerToolbarOverlayLightOpacity)
                    : Theme.headerBlurFallback
    }

    ShaderEffectSource {
        id: headerBackdropSource
        anchors.fill: parent
        sourceItem: headerContentSurface.glassSourceItem
        sourceRect: Qt.rect(
                        headerContentSurface.blurSourcePos.x,
                        headerContentSurface.blurSourcePos.y,
                        width,
                        height)
        live: true
        hideSource: false
        recursive: false
        smooth: true
        visible: false
    }

    MultiEffect {
        anchors.fill: parent
        source: headerBackdropSource
        blurEnabled: true
        blur: 0.62
        blurMax: 72
        saturation: 1.04
        brightness: Theme.dark ? 0.06 : 0.03
        autoPaddingEnabled: false
        opacity: 0.5
        visible: headerBackdropSource.sourceItem !== null
    }
}
```

Rules for this fallback:

- Keep `Theme.bg` as the right-side header base surface. The sampling layer supplements the DTK/compositor blur path; it does not replace the structural content base.
- Keep `D.StyledBehindWindowBlur` underneath. Do not convert the whole header to a pure custom glass layer.
- Sample only the right content panel such as `contentBase`. Do not sample the whole window and do not sample the sidebar blur surface.
- Do not add a second full-surface `Rectangle` tint overlay after the blur primitives.
- Match the updated Unote-derived toolbar recipe for the right-band tint and sampled blur: tint RGB comes from `Theme.bg`; light opacity is `0.7`; dark opacity is `0.6` for dashboard/card-like pages and `0.8` for dense linear/detail pages; sampled blur uses `blur: 0.62`, `blurMax: 72`, `saturation: 1.04`, `brightness: Theme.dark ? 0.06 : 0.03`, and the sampled blur layer opacity is `0.5`.
- Never apply that toolbar tint recipe to the sidebar top band. The sidebar must visually continue to the top edge as the sidebar surface itself, not as a separately painted toolbar slab.
- Make the page content actually underlap the header. A small tokenized inset such as `headerContentUnderlapInset: 4..12` is usually enough; remove accidental extra top margins in the shell or page wrapper before increasing blur strength.
- Keep the scrollbar geometry scoped to the visible content region. Even when content itself underlaps the header, the vertical scrollbar must begin below the visible header band and below any second-level toolbar band instead of extending through those layers.
- If the target stack already shows the desired moving-content glass with DTK/system blur alone, do not add this fallback.

## Do Not Guess

When local DTK exports `D.ApplicationWindow`, `D.TitleBar`, `D.WindowButtonGroup`, and `D.Menu`, the default answer is:

1. `D.ApplicationWindow`
2. `header: D.TitleBar`
3. `menu: D.Menu`
4. `D.WindowButtonGroup` anchored top-right
5. `leftContent` for logo or sidebar-toggle
6. optional `content` only for real top-band controls

Do not invent custom menu buttons, custom window buttons, or a separate faux titlebar unless a narrow waiver is explicitly justified.
