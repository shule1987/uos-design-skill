#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_LIB_DIR="${SCRIPT_DIR}/lib"
# shellcheck source=/dev/null
source "${AUDIT_LIB_DIR}/layout_density.sh"
# shellcheck source=/dev/null
source "${AUDIT_LIB_DIR}/sidebar.sh"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<'EOF'
Usage: audit_uos_qml.sh [repo-root]

Heuristic audit for UOS/Deepin QML desktop projects.
It reports blocking findings for:
- missing DTK imports/build hooks when DTK is installed locally
- misuse of locally exported DTK controls such as rebuilding window buttons despite local WindowButtonGroup
- WindowButtonGroup clusters offset away from the actual top-right edge
- titlebar content or drag zones that span the full D.TitleBar width without reserving the DTK trailing control strip
- D.TitleBar or WindowButtonGroup paths nested inside clipped ancestors that can crop top-right controls when maximized
- main windows that omit the DTK standard header, omit D.TitleBar.menu, or omit D.WindowButtonGroup
- main windows whose explicit window flags drop minimize, maximize, or close button hints required by the DTK header strip
- DTK main windows that still use Qt.CustomizeWindowHint or explicitly drop Qt.WindowTitleHint from the title-bar flag set
- transparent non-sidebar DTK main windows whose live title-band background is left visually transparent instead of using a theme surface token
- transparent DTK main windows whose right-side content base surface starts only below the title-band height, leaving the toolbar to blend against the desktop
- forced non-DTK global styles
- frameless top-level windows without waivers
- transparent top-level windows without an explicit theme-backed base surface
- full-window opaque base surfaces placed underneath blurred persistent sidebars
- Popup.Window usage without waivers
- sidebar components that never establish an explicit sidebar panel surface
- persistent-sidebar splits that leave a visible seam or consume width between sidebar and content instead of keeping zero gap with a divider on the sidebar edge
- single-group sidebars that still render a group header, or multi-group sidebar groups that do not keep a 20px gap
- operational unlock/pay/service notices rendered outside a sidebar-bottom card area
- sidebar navigation rows that look selectable but do not expose a real row-level click/tap target
- sidebar navigation items that still draw separate icon background tiles or use selected icon colors that differ from selected text
- sidebar operational-card buttons that do not maximize the usable card width
- full-window blur in persistent-left-sidebar applications without waivers
- page skeletons that never consume theme background tokens
- theme background tokens defined but never used by live surfaces
- self-drawn visual overlays stacked above DTK/system blur surfaces
- top-of-app operational or restricted-mode banners that should instead use sidebar-bottom operational cards
- sidebar operational cards whose only action is an in-app page jump
- reusable container implicitHeight contracts derived from anchored plain Item wrappers
- self-referential property bindings inside delegates or row primitives
- fake table screens with separate header/row width plans
- DTK controls left on default palette while the project uses a separate custom theme layer
- application main menus missing `System` / `Light` / `Dark` theme switching
- repeated trailing-control rows that do not expose a dedicated right-side control slot
- shadowed delegate role names that can blank or corrupt repeated rows
- list rows that omit the required leading icon, use a nonstandard `16px` or `24px` icon size, or use live object icons outside truthful file/app lists
- multi-line list row primitives whose leading icon lane is not top-aligned with the text column
- list leading icons that still draw self-made background tiles or capsules
- standalone in-content settings buttons when the app already exposes a main menu
- oversized card shells with obviously large fixed heights
- focal card content that binds to zero-padding card edges without an inner safe area
- card background layers that omit the required fixed 1px stroke or scale that stroke with UI helpers
- card shells that render their primary 1px stroke through an antialiased Rectangle.border instead of a dedicated stroke ring or layer
- card live-content containers that bind to card edges without a real inner inset, especially on the bottom edge
- auto-generated structural thumbnails that appear in cards without an explicit subdued mode
- structural thumbnail components that omit a fixed 1px edge stroke or still render preview ink with pure strong black/white semantics
- page-level manual card-pair equalization helpers instead of reusable audited 2-column card-band primitives
- row-aware metric, scene, or gallery card primitives mounted under plain GridLayout instead of the responsive equalization host they require
- focal graphic wrappers that advertise less height than the contained focal visual and therefore collapse surrounding spacing
- fill-anchored layout children inside column-flow card primitives that rely on Layout.fillHeight spacers and therefore bypass the card sizing flow
- repeated functional-row delegates that hardcode one literal bundled icon for all rows
- functional list models that reuse one bundled icon asset across distinct item identities
- action buttons with uncapped or oversized widths
- negative-spacing or same-center text/button stacks that can overlap in one parent
- multiple direct live-content containers that fill or center inside the same parent and can visibly stack
- explicit horizontal-scrolling list/table patterns in primary desktop surfaces
- width-constrained dynamic text that lacks explicit wrap or elide handling and can be cut off horizontally
- unclipped list or flickable viewports, and child blocks that bleed outside cards or viewport hosts
- runtime geometry findings, when the repo exposes the `UOS_DESIGN_VISUAL_AUDIT` hook, for rendered text overlap, horizontal cutoff, content escaping preview/card/viewport hosts, main scroll surfaces that shrink away from the content base, vertical scrollbars that drift off the far-right edge or run up into the header band, card-internal repeated rows that collapse the card floor inset, near-height card rows that still fail to align, and equal-height 2-column card rows that leave one sparse card with a large dead vertical gap
- scrollbars whose visible thickness exceeds 20px
- internal textless progress indicators whose visible thickness exceeds 20px or lacks an explicit cap
- dense icon/text/button clusters with explicit zero spacing
- cards whose explicit content inset falls below 8px
- selected sidebar items that add a border or outline
- persistent-sidebar collapse toggles that use generic chevrons or arrows
- moving or duplicated top-left logo slots across sidebar expand/collapse
- persistent-sidebar top bands that paint a standalone full-width titleband surface instead of carrying the left and right panel surfaces up to the top edge
- persistent-sidebar titlebars that keep a pure color content-side surface but never mount a real titlebar blur layer
- persistent-sidebar sidebars that duplicate a second app brand block above navigation even though the DTK header already owns the logo slot
- unified-toolbar page titles that were not explicitly requested
- detailed center text inside rings, gauges, or chart-center overlays
- oversized default desktop window shells
- undersized DTK settings dialogs
- `Settings.SettingsDialog` roots that omit the standard top-left icon slot
- standard DTK About/settings surfaces that are forced back to a system title bar
- checkbox-style settings rows that bypass local `Settings.CheckBox`
- restore-default actions incorrectly surfaced as ordinary rows inside settings groups
- custom settings-row fallback primitives that inject project theme rhythm into DTK settings content
- theme baselines that drift away from the documented neutral DTK/UOS palette
- sidebar blur tint values that are too opaque or too chromatic to read as control-center-like glass
- circular score widgets with fixed large typography consumed below their safe size
- app-side top-level window decoration tuning for radius, border, or shadow
- hex color literals outside Theme.qml without waivers
- interactive icon tint using Theme.textMuted without waivers
- DTK controls with replaced structural templates without waivers
- custom in-app notifications without waivers
- DTK FloatingMessage payloads that still push custom iconName fields through app-side toast wrappers without waivers
- direct D.FloatingMessage instantiation in app code instead of routing transient notifications through D.DTK.sendMessage(...)
- rasterized functional-icon pipelines without waivers
- functional icon-source controls that skip explicit theme-driven alpha tint
- DTK buttons or toolbuttons that still feed symbolic SVG assets through icon.source instead of the audited alpha-tint path
- button-contained functional icons that do not use the same 16px box as pure icon buttons
- inline derived navigation colors in sidebar/nav files without waivers
- custom main-menu triggers without waivers
- application main menus that do not use D.TitleBar.menu
- D.TitleBar-based windows that still add a separate self-drawn main-menu trigger
- main-menu triggers next to the minimize cluster that still use project SVG assets or custom chrome
- manual main-menu popup coordinates without waivers
- large title labels above 16px that exceed 400 weight
- content-area page headers or other large in-content titles that still prepend icons
- large numeric labels with units rendered as one full-size text run instead of a value-plus-half-size-unit treatment
- custom progress components whose foreground fill or stroke lacks a same-color shadow treatment
- circular or ring progress shadows that are too strong, clip at the component edge, or allow no-text strokes above 20px
- gradient cards that leave neutral padding or inset seams around the live gradient surface
- duplicated badge/tag status and plain-text status within one surface
- option/settings rows that still rely on a shared placeholder icon or omit explicit per-item icons
- list rows that keep generic placeholder icons where a real app/file icon should be used
- charts without labeled axes, tick marks, or animated data changes
- chart curves or polylines rendered as flat lines without a same-color shadow and top-to-bottom same-hue gradient
- search edits whose placeholder hints remain visible while inactive
- search/filter bands where the search control does not clearly dominate the layout share
- variable-length file/app/data list rows or reusable cards that allow wrapped text to sprawl beyond a compact 1-2 line baseline
- variable-length file/app/program/startup/service/data page lists that still use per-item standalone cards or legacy oversized settings-row templates instead of compact responsive rows
- manually placed list-lane content blocks that shrink inside a wider host without balanced horizontal centering
- mutually exclusive filter/mode/state button sets that ignore local DTK grouped-button controls or wrap across multiple rows without waivers
- mutually exclusive button groups that leave more than 10px between adjacent peer buttons
- D.ButtonBox children rebound into a second external ButtonGroup instead of using ButtonBox.group
- one surface rendering the same numeric ratio through both circular/ring progress and horizontal progress
- popup-style `D.Dialog` usage in desktop app code when local `DialogWindow` exists and no waiver explains the exception
- `D.DialogWindow` bodies that hand-build a bare `RowLayout` / `Flow` button footer instead of routing actions through `D.DialogButtonBox`
- DTK dialog footers that keep page-style vertical margins around the action row, fail to evenly split multi-action footer width, or wrap `D.DialogButtonBox` through custom structural overrides
- DTK dialogs that stack multiple separate action-button rows instead of one standard action row
- vertically stacked multi-button action areas inside normal cards or dialogs
- self-drawn overlay layers inside DTK dialogs
- non-DTK dialogs or dialog shells in projects where DTK dialogs are available locally
- DTK dialogs whose body restyles normal text colors, adds oversized secondary headings, centers hero text, or embeds page-style widgets
- collapsible sidebars that visually collapse by width squeeze instead of translate-out / translate-in motion
- list surfaces that are artificially capped to a few rows instead of consuming the remaining available height
- unified toolbars whose merged top band is not 50px high or still adds an extra divider line
- custom About dialogs without waivers
- plain Qt Quick Controls `Button`, `TextField`, `ComboBox`, `Switch`, `CheckBox`, `ProgressBar`, or `ScrollBar` usage where the same DTK control is exported locally
- `Settings.SettingsDialog` bodies that use plain or DTK-generic combo-box or line-edit controls instead of locally exported `Settings.ComboBox` or `Settings.LineEdit`
EOF
    exit 0
fi

ROOT_INPUT="${1:-$PWD}"
if [[ ! -d "$ROOT_INPUT" ]]; then
    echo "repo root does not exist: $ROOT_INPUT" >&2
    exit 64
fi

ROOT="$(cd "$ROOT_INPUT" && pwd)"
findings=0
main_menu_candidates=()
settings_button_candidates=()
surface_token_pattern='Theme\.(bg|bgPanel|bgToolbar|surface|panelBg|titlebarBg)([^A-Za-z0-9_]|$)'
dtk_qmldir=""
dtk_settings_qmldir=""

log_fail() {
    local code="$1"
    local detail="$2"
    printf 'FAIL [%s] %s\n' "$code" "$detail"
    findings=$((findings + 1))
}

grep_repo() {
    local pattern="$1"
    shift
    grep -RInE \
        --exclude-dir=.git \
        --exclude-dir=.idea \
        --exclude-dir=.vscode \
        --exclude-dir=.cache \
        --exclude-dir=.codex \
        --exclude-dir=build \
        --exclude-dir=build-deb \
        --exclude-dir=build-codex \
        --exclude-dir=cmake-build-debug \
        --exclude-dir=cmake-build-release \
        --exclude-dir=_CPack_Packages \
        --exclude-dir=dist \
        --exclude-dir=node_modules \
        "$pattern" \
        "$ROOT" \
        "$@" 2>/dev/null || true
}

list_qml_files() {
    find "$ROOT" \
        \( -path "$ROOT/.git" \
        -o -path "$ROOT/.idea" \
        -o -path "$ROOT/.vscode" \
        -o -path "$ROOT/.cache" \
        -o -path "$ROOT/.codex" \
        -o -path "$ROOT/build" \
        -o -path "$ROOT/build-deb" \
        -o -path "$ROOT/build-codex" \
        -o -path "$ROOT/cmake-build-debug" \
        -o -path "$ROOT/cmake-build-release" \
        -o -path "$ROOT/_CPack_Packages" \
        -o -path "$ROOT/dist" \
        -o -path "$ROOT/node_modules" \) -prune \
        -o -type f -name '*.qml' -print0
}

list_source_files() {
    find "$ROOT" \
        \( -path "$ROOT/.git" \
        -o -path "$ROOT/.idea" \
        -o -path "$ROOT/.vscode" \
        -o -path "$ROOT/.cache" \
        -o -path "$ROOT/.codex" \
        -o -path "$ROOT/build" \
        -o -path "$ROOT/build-deb" \
        -o -path "$ROOT/build-codex" \
        -o -path "$ROOT/cmake-build-debug" \
        -o -path "$ROOT/cmake-build-release" \
        -o -path "$ROOT/_CPack_Packages" \
        -o -path "$ROOT/dist" \
        -o -path "$ROOT/node_modules" \) -prune \
        -o -type f \( -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' -o -name '*.h' -o -name '*.hpp' \) -print0
}

detect_cmake_project_binary_name() {
    local cmake_file="$ROOT/CMakeLists.txt"
    [[ -f "$cmake_file" ]] || return 0

    sed -nE 's/^[[:space:]]*project[[:space:]]*\(([A-Za-z0-9_.-]+).*/\1/p' "$cmake_file" | head -n 1
}

detect_visual_audit_executable() {
    local binary_name="$1"
    [[ -n "$binary_name" ]] || return 0

    local candidate
    for candidate in \
        "$ROOT/build-codex/$binary_name" \
        "$ROOT/build/$binary_name" \
        "$ROOT/cmake-build-debug/$binary_name" \
        "$ROOT/cmake-build-release/$binary_name"
    do
        if [[ -x "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
}

dtk_has_export() {
    local export_name="$1"
    [[ -n "$dtk_qmldir" ]] && grep -qE "^${export_name}[[:space:]]" "$dtk_qmldir"
}

dtk_settings_has_export() {
    local export_name="$1"
    [[ -n "$dtk_settings_qmldir" ]] && grep -qE "^${export_name}[[:space:]]" "$dtk_settings_qmldir"
}

max3() {
    local a="$1"
    local b="$2"
    local c="$3"
    local max="$a"
    (( b > max )) && max="$b"
    (( c > max )) && max="$c"
    printf '%s\n' "$max"
}

min3() {
    local a="$1"
    local b="$2"
    local c="$3"
    local min="$a"
    (( b < min )) && min="$b"
    (( c < min )) && min="$c"
    printf '%s\n' "$min"
}

hex_rgb_metrics() {
    local hex="${1#\#}"
    local alpha="-1"
    local rgb="$hex"
    if [[ ${#hex} -eq 8 ]]; then
        alpha=$((16#${hex:0:2}))
        rgb="${hex:2:6}"
    fi
    local r=$((16#${rgb:0:2}))
    local g=$((16#${rgb:2:2}))
    local b=$((16#${rgb:4:2}))
    local max_v
    local min_v
    max_v="$(max3 "$r" "$g" "$b")"
    min_v="$(min3 "$r" "$g" "$b")"
    printf '%s %s %s %s %s\n' "$r" "$g" "$b" "$alpha" "$((max_v - min_v))"
}

hex_is_neutral_light() {
    local metrics
    metrics="$(hex_rgb_metrics "$1")"
    local r g b alpha spread
    read -r r g b alpha spread <<<"$metrics"
    (( r >= 244 && g >= 244 && b >= 244 && spread <= 8 ))
}

hex_is_neutral_dark() {
    local metrics
    metrics="$(hex_rgb_metrics "$1")"
    local r g b alpha spread
    read -r r g b alpha spread <<<"$metrics"
    (( r <= 24 && g <= 24 && b <= 24 && spread <= 8 ))
}

hex_alpha_is_sidebar_blend() {
    local metrics
    metrics="$(hex_rgb_metrics "$1")"
    local r g b alpha spread
    read -r r g b alpha spread <<<"$metrics"
    (( alpha >= 184 && alpha <= 216 ))
}

theme_property_line() {
    local file="$1"
    local token="$2"
    grep -nE "^[[:space:]]*(readonly[[:space:]]+)?property[[:space:]]+color[[:space:]]+${token}[[:space:]]*:" "$file" | head -n 1 || true
}

detect_manual_blur_overlay_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            stack = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{[[:space:]]*(\/\/.*)?$/) {
                stack++
                type[stack] = line
                sub(/^[[:space:]]*/, "", type[stack])
                sub(/[[:space:]]*\{.*/, "", type[stack])
                depth[stack] = 0
                child_blur_count[stack] = 0
                child_overlay_count[stack] = 0
                child_overlay_line[stack] = 0
                child_overlay_text[stack] = ""
                rect_fill_parent[stack] = 0
                rect_color_line[stack] = 0
                rect_color_text[stack] = ""
            }

            if (stack > 0) {
                if (depth[stack] == 1 && type[stack] == "Rectangle") {
                    if (line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                        rect_fill_parent[stack] = 1
                    if (line ~ /^[[:space:]]*color[[:space:]]*:/) {
                        rect_color_line[stack] = NR
                        rect_color_text[stack] = line
                    }
                }

                depth[stack] += delta
                while (stack > 0 && depth[stack] <= 0) {
                    closed = stack
                    parent = stack - 1

                    if (type[closed] ~ /StyledBehindWindowBlur$/ && parent >= 1)
                        child_blur_count[parent]++

                    if (type[closed] == "Rectangle" && rect_fill_parent[closed] && rect_color_line[closed] > 0 \
                        && rect_color_text[closed] !~ /transparent/ && parent >= 1) {
                        child_overlay_count[parent]++
                        if (child_overlay_line[parent] == 0) {
                            child_overlay_line[parent] = rect_color_line[closed]
                            child_overlay_text[parent] = rect_color_text[closed]
                        }
                    }

                    if (child_blur_count[closed] > 0 && child_overlay_count[closed] > 0)
                        print child_overlay_line[closed] ":" child_overlay_text[closed]

                    delete type[closed]
                    delete depth[closed]
                    delete child_blur_count[closed]
                    delete child_overlay_count[closed]
                    delete child_overlay_line[closed]
                    delete child_overlay_text[closed]
                    delete rect_fill_parent[closed]
                    delete rect_color_line[closed]
                    delete rect_color_text[closed]
                    stack--
                }
            }
        }
    ' "$file"
}

detect_dialog_overlay_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_dialog = 0
            dialog_depth = 0
            in_rect = 0
            rect_depth = 0
            rect_fill_parent = 0
            rect_color = ""
            rect_color_line = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_dialog && line ~ /^[[:space:]]*D\.(Dialog|DialogWindow)[[:space:]]*\{/) {
                in_dialog = 1
                dialog_depth = 0
            }

            if (in_dialog) {
                if (line ~ /StyledBehindWindowBlur[[:space:]]*\{/)
                    printf "%s: DTK dialog adds a manual blur layer inside the dialog surface\n", NR

                if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                    in_rect = 1
                    rect_depth = delta
                    rect_fill_parent = 0
                    rect_color = ""
                    rect_color_line = 0
                } else if (in_rect) {
                    if (rect_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                        rect_fill_parent = 1
                    if (rect_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:/) {
                        rect_color = line
                        rect_color_line = NR
                    }

                    rect_depth += delta
                    if (rect_depth <= 0) {
                        if (rect_fill_parent && rect_color_line > 0 && rect_color !~ /transparent/)
                            printf "%s: DTK dialog adds a self-drawn full-surface Rectangle overlay\n", rect_color_line
                        in_rect = 0
                    }
                }

                dialog_depth += delta
                if (dialog_depth <= 0) {
                    in_dialog = 0
                    in_rect = 0
                }
            }
        }
    ' "$file"
}

file_has_root_dtk_template_control() {
    local file="$1"
    awk '
        /^[[:space:]]*(import|pragma)([[:space:]]|$)/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\/\// { next }
        {
            if ($0 ~ /^[[:space:]]*D\.(Switch|CheckBox|ComboBox|Button|TextField|Menu|Dialog|DialogButtonBox|ProgressBar)[[:space:]]*\{/) {
                print "yes"
            }
            exit
        }
    ' "$file"
}

file_has_root_application_window() {
    local file="$1"
    awk '
        /^[[:space:]]*(import|pragma)([[:space:]]|$)/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\/\// { next }
        {
            if ($0 ~ /^[[:space:]]*(([A-Za-z_][A-Za-z0-9_]*\.)?ApplicationWindow|([A-Za-z_][A-Za-z0-9_]*\.)?Window)[[:space:]]*\{/) {
                print "yes"
            }
            exit
        }
    ' "$file"
}

file_has_root_item() {
    local file="$1"
    awk '
        /^[[:space:]]*(import|pragma)([[:space:]]|$)/ { next }
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*\/\// { next }
        {
            if ($0 ~ /^[[:space:]]*Item[[:space:]]*\{/) {
                print "yes"
            }
            exit
        }
    ' "$file"
}

file_has_fill_parent_rectangle() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_rect = 0
            rect_depth = 0
            rect_fill_parent = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                in_rect = 1
                rect_depth = 0
                rect_fill_parent = 0
            }

            if (in_rect) {
                if (line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                    rect_fill_parent = 1
                }

                rect_depth += delta
                if (rect_depth <= 0) {
                    if (rect_fill_parent) {
                        print "yes"
                        exit
                    }
                    in_rect = 0
                }
            }
        }
    ' "$file"
}

looks_like_fake_table() {
    local file="$1"
    local header_count
    local right_align_count

    header_count=$(grep -Ec 'Layout\.preferredWidth[[:space:]]*:' "$file" || true)
    right_align_count=$(grep -Ec 'horizontalAlignment[[:space:]]*:[[:space:]]*Text\.AlignRight' "$file" || true)

    if grep -q 'Repeater' "$file" \
        && (( header_count >= 3 )) \
        && (( right_align_count >= 2 )) \
        && ! grep -qE 'TableView|HorizontalHeaderView|columnWidths|columnPlan|sharedColumn' "$file"
    then
        return 0
    fi

    return 1
}

detect_anchored_item_implicit_height_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_item() {
            in_item = 0
            item_depth = 0
            item_id = ""
            item_start = 0
            item_fill_parent = 0
        }

        BEGIN {
            reset_item()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_item && line ~ /^[[:space:]]*Item[[:space:]]*\{/) {
                in_item = 1
                item_depth = 0
                item_id = ""
                item_start = NR
                item_fill_parent = 0
            }

            if (in_item) {
                if (item_id == "" && line ~ /id[[:space:]]*:[[:space:]]*[A-Za-z_][A-Za-z0-9_]*/) {
                    item_id = line
                    sub(/.*id[[:space:]]*:[[:space:]]*/, "", item_id)
                    sub(/[^A-Za-z0-9_].*/, "", item_id)
                }
                if (line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                    item_fill_parent = 1
                }

                item_depth += delta
                if (item_depth <= 0) {
                    if (item_id != "" && item_fill_parent) {
                        anchored_item[item_id] = item_start
                    }
                    reset_item()
                }
            }

            if (line ~ /^[[:space:]]*implicitHeight[[:space:]]*:[[:space:]]*[A-Za-z_][A-Za-z0-9_]*\.implicitHeight/) {
                print_refs[NR] = line
                sub(/^[[:space:]]*implicitHeight[[:space:]]*:[[:space:]]*/, "", print_refs[NR])
                sub(/\.implicitHeight.*/, "", print_refs[NR])
            }
        }

        END {
            for (line_no in print_refs) {
                if (print_refs[line_no] in anchored_item) {
                    printf "%s: implicitHeight references anchored Item '%s'\n", line_no, print_refs[line_no]
                }
            }
        }
    ' "$file"
}

detect_self_binding_hits() {
    local file="$1"
    grep -nE '^[[:space:]]*(title|description|subtitle|text|label|name|statusText|iconName|value|checked|enabled|visible|selected|currentIndex|source|modelData)[[:space:]]*:[[:space:]]*\1([[:space:]]*(//.*)?$)' "$file" || true
}

detect_custom_window_button_hits() {
    local file="$1"
    if grep -qE 'showMinimized\(|showMaximized\(|showNormal\(' "$file" \
        && grep -qE '(^|[[:space:]])(D\.)?ToolButton([[:space:]]|\{)|(^|[[:space:]])(D\.)?Button([[:space:]]|\{)' "$file" \
        && ( grep -qE 'text[[:space:]]*:[[:space:]]*"(最小化|最大化|还原|关闭)"' "$file" \
            || grep -qE 'icon\.source[[:space:]]*:[[:space:]]*".*(minus|square|close|x)\.svg"' "$file" \
            || [[ "$(basename "$file")" == *WindowControls*.qml ]] ) \
        && ! grep -q 'WindowButtonGroup' "$file"
    then
        grep -nE 'showMinimized\(|showMaximized\(|showNormal\(' "$file" || true
    fi
}

detect_window_button_group_placement_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_block = 0
            depth = 0
            start = 0
            has_top = 0
            has_right = 0
            has_layout_align = 0
            has_center = 0
            top_margin = -1
            right_margin = -1
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*D\.WindowButtonGroup[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_top = 0
                has_right = 0
                has_layout_align = 0
                has_center = 0
                top_margin = -1
                right_margin = -1
            }

            if (in_block) {
                if (depth == 1 && line ~ /anchors\.top[[:space:]]*:[[:space:]]*parent\.top/)
                    has_top = 1
                if (depth == 1 && line ~ /anchors\.right[[:space:]]*:[[:space:]]*parent\.right/)
                    has_right = 1
                if (depth == 1 && line ~ /Layout\.alignment[[:space:]]*:.*Qt\.AlignRight/ && line ~ /Qt\.AlignTop/)
                    has_layout_align = 1
                if (depth == 1 && line ~ /anchors\.centerIn[[:space:]]*:/)
                    has_center = 1
                if (depth == 1 && line ~ /anchors\.topMargin[[:space:]]*:[[:space:]]*[0-9]+/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    top_margin = value + 0
                }
                if (depth == 1 && line ~ /anchors\.rightMargin[[:space:]]*:[[:space:]]*[0-9]+/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    right_margin = value + 0
                }

                depth += delta
                if (depth <= 0) {
                    if (has_center)
                        printf "%s: WindowButtonGroup is centered inside a wrapper instead of sitting on the top-right edge\n", start
                    if (top_margin > 0 || right_margin > 0)
                        printf "%s: WindowButtonGroup uses positive top/right margins and therefore leaves a visible edge gap\n", start
                    if (!has_center && !has_layout_align && !(has_top && has_right))
                        printf "%s: WindowButtonGroup is not explicitly aligned to the top-right edge\n", start
                    in_block = 0
                }
            }
        }
    ' "$file"
}

detect_required_main_window_header_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function root_window_start(s) {
            return s ~ /^[[:space:]]*(([A-Za-z_][A-Za-z0-9_]*\.)?ApplicationWindow|([A-Za-z_][A-Za-z0-9_]*\.)?Window)[[:space:]]*\{/
        }

        function numeric_value(s, name,   value) {
            if (s ~ ("^[[:space:]]*" name "[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(//.*)?$)")) {
                value = s
                sub(/.*:[[:space:]]*/, "", value)
                gsub(/[^0-9]/, "", value)
                return value + 0
            }

            return -1
        }

        BEGIN {
            root_seen = 0
            root_depth = 0
            root_start = 0
            in_titlebar = 0
            titlebar_depth = 0
            titlebar_start = 0
            current_titlebar_has_menu = 0
            has_titlebar = 0
            has_titlebar_menu = 0
            has_window_button_group = 0
            min_width = -1
            max_width = -1
            min_height = -1
            max_height = -1
            has_flags = 0
            has_minimize_hint = 0
            has_maximize_hint = 0
            has_close_hint = 0
            disables_dtk_window = 0
        }

        /^[[:space:]]*(import|pragma)([[:space:]]|$)/ && !root_seen { next }
        /^[[:space:]]*$/ && !root_seen { next }
        /^[[:space:]]*\/\// && !root_seen { next }

        {
            line = $0
            delta = brace_delta(line)

            if (!root_seen) {
                if (root_window_start(line)) {
                    root_seen = 1
                    root_depth = 0
                    root_start = NR
                } else {
                    exit
                }
            }

            if (root_depth == 1) {
                value = numeric_value(line, "minimumWidth")
                if (value >= 0)
                    min_width = value

                value = numeric_value(line, "maximumWidth")
                if (value >= 0)
                    max_width = value

                value = numeric_value(line, "minimumHeight")
                if (value >= 0)
                    min_height = value

                value = numeric_value(line, "maximumHeight")
                if (value >= 0)
                    max_height = value

                if (line ~ /^[[:space:]]*flags[[:space:]]*:/) {
                    has_flags = 1
                    if (line ~ /Qt\.WindowMinimizeButtonHint/ || line ~ /Qt\.WindowMinMaxButtonsHint/)
                        has_minimize_hint = 1
                    if (line ~ /Qt\.WindowMaximizeButtonHint/ || line ~ /Qt\.WindowMinMaxButtonsHint/)
                        has_maximize_hint = 1
                    if (line ~ /Qt\.WindowCloseButtonHint/)
                        has_close_hint = 1
                }

                if (line ~ /^[[:space:]]*D\.DWindow\.enabled[[:space:]]*:[[:space:]]*false\b/)
                    disables_dtk_window = 1

                if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                    in_titlebar = 1
                    titlebar_depth = 0
                    titlebar_start = NR
                    current_titlebar_has_menu = 0
                    has_titlebar = 1
                }
            }

            if (in_titlebar) {
                if (line ~ /(^|[[:space:]])menu[[:space:]]*:/)
                    current_titlebar_has_menu = 1
                if (line ~ /D\.WindowButtonGroup[[:space:]]*\{/)
                    has_window_button_group = 1

                titlebar_depth += delta
                if (titlebar_depth <= 0) {
                    if (current_titlebar_has_menu)
                        has_titlebar_menu = 1
                    in_titlebar = 0
                }
            }

            root_depth += delta
            if (root_seen && root_depth <= 0) {
                fixed_size = (min_width >= 0 && max_width >= 0 && min_height >= 0 && max_height >= 0 \
                    && min_width == max_width && min_height == max_height)

                if (!has_titlebar)
                    printf "%s: main window must declare a DTK standard D.TitleBar header\n", root_start
                if (!has_titlebar_menu)
                    printf "%s: main window must attach the application menu through D.TitleBar.menu\n", (has_titlebar ? titlebar_start : root_start)
                if (!has_window_button_group)
                    printf "%s: main window must expose D.WindowButtonGroup inside the DTK header\n", (has_titlebar ? titlebar_start : root_start)
                if (disables_dtk_window)
                    printf "%s: main window must not disable DTK window chrome with D.DWindow.enabled: false\n", root_start

                if (has_flags && !has_minimize_hint)
                    printf "%s: explicit main-window flags omit the minimize button hint required by the DTK header strip\n", root_start
                if (has_flags && !fixed_size && !has_maximize_hint)
                    printf "%s: explicit main-window flags omit the maximize button hint required by the DTK header strip for resizable windows\n", root_start
                if (has_flags && !has_close_hint)
                    printf "%s: explicit main-window flags omit the close button hint required by the DTK header strip\n", root_start
                exit
            }
        }
    ' "$file"
}

detect_titlebar_safe_area_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_content() {
            in_content = 0
            content_depth = 0
            content_start = 0
            content_fill_parent = 0
            content_has_trailing_reserve = 0
            in_mouse = 0
            mouse_depth = 0
            mouse_start = 0
            mouse_fill_parent = 0
        }

        BEGIN {
            in_titlebar = 0
            depth = 0
            direct_mouse = 0
            direct_mouse_depth = 0
            direct_mouse_start = 0
            direct_mouse_fill_parent = 0
            reset_content()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                depth = 0
                direct_mouse = 0
                direct_mouse_depth = 0
                direct_mouse_start = 0
                direct_mouse_fill_parent = 0
                reset_content()
            }

            if (in_titlebar) {
                if (!in_content && depth == 1 && line ~ /^[[:space:]]*content[[:space:]]*:[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/) {
                    in_content = 1
                    content_depth = 0
                    content_start = NR
                    content_fill_parent = 0
                    content_has_trailing_reserve = 0
                    in_mouse = 0
                    mouse_depth = 0
                    mouse_start = 0
                    mouse_fill_parent = 0
                }

                if (!direct_mouse && depth == 1 && line ~ /^[[:space:]]*MouseArea[[:space:]]*\{/) {
                    direct_mouse = 1
                    direct_mouse_depth = 0
                    direct_mouse_start = NR
                    direct_mouse_fill_parent = 0
                }

                if (in_content) {
                    if (!in_mouse && line ~ /^[[:space:]]*MouseArea[[:space:]]*\{/) {
                        in_mouse = 1
                        mouse_depth = 0
                        mouse_start = NR
                        mouse_fill_parent = 0
                    }

                    if (content_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                        content_fill_parent = 1

                    if (content_depth == 1 && line ~ /anchors\.rightMargin[[:space:]]*:/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /Layout\.rightMargin[[:space:]]*:/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /rightPadding[[:space:]]*:/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /anchors\.right[[:space:]]*:[[:space:]]*[A-Za-z_][A-Za-z0-9_]*\.left/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /width[[:space:]]*:[[:space:]]*parent\.width[[:space:]]*-/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /Layout\.maximumWidth[[:space:]]*:/)
                        content_has_trailing_reserve = 1
                    if (content_depth == 1 && line ~ /maximumWidth[[:space:]]*:/)
                        content_has_trailing_reserve = 1

                    if (in_mouse) {
                        if (mouse_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                            mouse_fill_parent = 1

                        mouse_depth += delta
                        if (mouse_depth <= 0) {
                            if (mouse_fill_parent)
                                printf "%s: MouseArea fills D.TitleBar.content and can cover the DTK trailing control strip\n", mouse_start
                            in_mouse = 0
                        }
                    }

                    content_depth += delta
                    if (content_depth <= 0) {
                        if (content_fill_parent && !content_has_trailing_reserve)
                            printf "%s: D.TitleBar.content fills the full titlebar width without reserving the DTK trailing control safe area\n", content_start
                        reset_content()
                    }
                }

                if (direct_mouse) {
                    if (direct_mouse_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                        direct_mouse_fill_parent = 1

                    direct_mouse_depth += delta
                    if (direct_mouse_depth <= 0) {
                        if (direct_mouse_fill_parent)
                            printf "%s: MouseArea fills the full D.TitleBar and can steal the DTK trailing control strip\n", direct_mouse_start
                        direct_mouse = 0
                    }
                }

                depth += delta
                if (depth <= 0) {
                    in_titlebar = 0
                    reset_content()
                    direct_mouse = 0
                }
            }
        }
    ' "$file"
}

detect_centered_titlebar_content_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_titlebar = 0
            depth = 0
            in_content = 0
            content_depth = 0
            content_start = 0
            content_has_center = 0
            content_has_group = 0
            in_search = 0
            search_depth = 0
            search_fill_width = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                depth = 0
                in_content = 0
            }

            if (in_titlebar) {
                if (!in_content && depth == 1 && line ~ /^[[:space:]]*content[[:space:]]*:[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/) {
                    in_content = 1
                    content_depth = 0
                    content_start = NR
                    content_has_center = 0
                    content_has_group = 0
                    in_search = 0
                    search_depth = 0
                    search_fill_width = 0
                }

                if (in_content) {
                    if (line ~ /^[[:space:]]*(D\.)?(ButtonBox|ButtonGroup|ControlGroup)[[:space:]]*\{/)
                        content_has_group = 1

                    if (line ~ /anchors\.horizontalCenter[[:space:]]*:/ \
                        || line ~ /anchors\.centerIn[[:space:]]*:[[:space:]]*parent/ \
                        || line ~ /Layout\.alignment[[:space:]]*:.*AlignHCenter/)
                        content_has_center = 1

                    if (!in_search && line ~ /^[[:space:]]*(D\.)?SearchEdit[[:space:]]*\{/) {
                        in_search = 1
                        search_depth = 0
                    }

                    if (in_search) {
                        if (search_depth == 1 && line ~ /Layout\.fillWidth[[:space:]]*:[[:space:]]*true/)
                            search_fill_width = 1

                        search_depth += delta
                        if (search_depth <= 0)
                            in_search = 0
                    }

                    content_depth += delta
                    if (content_depth <= 0) {
                        if (content_has_group && search_fill_width && !content_has_center)
                            printf "%s: D.TitleBar.content uses an expanding search row but does not center the visible header control cluster\n", content_start
                        in_content = 0
                    }
                }

                depth += delta
                if (depth <= 0)
                    in_titlebar = 0
            }
        }
    ' "$file"
}

detect_header_button_icon_size_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_titlebar = 0
            depth = 0
            in_button = 0
            button_depth = 0
            button_start = 0
            button_has_icon = 0
            button_width_ok = 0
            button_height_ok = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                depth = 0
            }

            if (in_titlebar) {
                if (!in_button && line ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*)?D\.(ToolButton|Button|RecommandButton|WarningButton)[[:space:]]*\{/) {
                    in_button = 1
                    button_depth = 0
                    button_start = NR
                    button_has_icon = 0
                    button_width_ok = 0
                    button_height_ok = 0
                }

                if (in_button) {
                    if (button_depth == 1 && line ~ /icon\.(name|source)[[:space:]]*:/)
                        button_has_icon = 1
                    if (button_depth == 1 && line ~ /display[[:space:]]*:[[:space:]]*AbstractButton\.(IconOnly|TextBesideIcon|TextUnderIcon|IconBesideText)/)
                        button_has_icon = 1
                    if (button_depth == 1 && line ~ /icon\.width[[:space:]]*:[[:space:]]*16([^0-9]|$)/)
                        button_width_ok = 1
                    if (button_depth == 1 && line ~ /icon\.height[[:space:]]*:[[:space:]]*16([^0-9]|$)/)
                        button_height_ok = 1

                    button_depth += delta
                    if (button_depth <= 0) {
                        if (button_has_icon && (!button_width_ok || !button_height_ok))
                            printf "%s: symbolic app-side header buttons must explicitly set a 16x16 icon box\n", button_start
                        in_button = 0
                    }
                }

                depth += delta
                if (depth <= 0)
                    in_titlebar = 0
            }
        }
    ' "$file"
}

detect_titlebar_clipped_ancestor_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function object_type(s,   line) {
            line = s
            sub(/^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*/, "", line)
            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*([[:space:]]+on[[:space:]]+[A-Za-z_][A-Za-z0-9_]*)?[[:space:]]*\{/) {
                sub(/^[[:space:]]*/, "", line)
                sub(/[[:space:]]*\{.*/, "", line)
                sub(/[[:space:]].*/, "", line)
                return line
            }
            return ""
        }

        BEGIN {
            level = 0
        }

        {
            line = $0
            type = object_type(line)
            if (type != "") {
                level++
                stack_type[level] = type
                stack_start[level] = NR
                stack_clip[level] = 0

                if (type == "D.TitleBar" || type == "TitleBar" || type == "D.WindowButtonGroup" || type == "WindowButtonGroup") {
                    for (i = level - 1; i >= 1; --i) {
                        if (stack_clip[i]) {
                            printf "%s: %s is nested inside clipped ancestor %s from line %s\n", NR, type, stack_type[i], stack_start[i]
                            break
                        }
                    }
                }
            }

            if (level > 0 && line ~ /^[[:space:]]*clip[[:space:]]*:[[:space:]]*true/)
                stack_clip[level] = 1

            delta = brace_delta(line)
            if (delta < 0) {
                for (i = 0; i < -delta; ++i) {
                    delete stack_type[level]
                    delete stack_start[level]
                    delete stack_clip[level]
                    level--
                }
            }
        }
    ' "$file"
}

detect_risky_titlebar_flag_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE '(^|[[:space:]])D\.TitleBar([[:space:]]|\{)' "$file"; then
        return
    fi

    if grep -qE '^[[:space:]]*flags[[:space:]]*:.*Qt\.CustomizeWindowHint' "$file"; then
        grep -nE '^[[:space:]]*flags[[:space:]]*:.*Qt\.CustomizeWindowHint' "$file" \
            | sed 's/$/: DTK main window uses Qt.CustomizeWindowHint in the normal title-bar path/'
    fi

    if grep -qE '^[[:space:]]*flags[[:space:]]*:' "$file" \
        && ! grep -qE '^[[:space:]]*flags[[:space:]]*:.*Qt\.WindowTitleHint' "$file"
    then
        grep -nE '^[[:space:]]*flags[[:space:]]*:' "$file" \
            | sed 's/$/: explicit DTK main-window flags omit Qt.WindowTitleHint/'
    fi
}

detect_transparent_titlebar_background_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE '(^|[[:space:]])D\.TitleBar([[:space:]]|\{)' "$file"; then
        return
    fi

    if ! grep -qE '^[[:space:]]*color[[:space:]]*:[[:space:]]*["'\'']transparent["'\'']' "$file"; then
        return
    fi

    if grep -qE 'StyledBehindWindowBlur|sidebarWidth|sidebarShell|sidebarHost|onCollapseRequested' "$file"; then
        return
    fi

    if ! grep -qE 'Theme\.(titlebarBg|bgToolbar)([^A-Za-z0-9_]|$)' "$file"; then
        grep -nE 'D\.TitleBar[[:space:]]*\{' "$file" \
            | sed 's/$/: transparent main window uses D.TitleBar but no explicit title-band background surface token was found/'
    fi
}

detect_titleband_underlay_gap_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE '(^|[[:space:]])D\.TitleBar([[:space:]]|\{)' "$file"; then
        return
    fi

    if ! grep -qE '^[[:space:]]*color[[:space:]]*:[[:space:]]*["'\'']transparent["'\'']' "$file"; then
        return
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_block = 0
            depth = 0
            start = 0
            has_top = 0
            has_top_margin = 0
            has_right = 0
            has_theme_base = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Rectangle|Item)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_top = 0
                has_top_margin = 0
                has_right = 0
                has_theme_base = 0
            }

            if (in_block) {
                if (depth == 1 && line ~ /anchors\.top[[:space:]]*:[[:space:]]*parent\.top/)
                    has_top = 1
                if (depth == 1 && line ~ /anchors\.topMargin[[:space:]]*:[[:space:]]*.*chromeHeight/)
                    has_top_margin = 1
                if (depth == 1 && line ~ /anchors\.right[[:space:]]*:[[:space:]]*parent\.right/)
                    has_right = 1
                if (depth == 1 && line ~ /color[[:space:]]*:[[:space:]]*Theme\.(panelBg|bg|bgPanel)/)
                    has_theme_base = 1

                depth += delta
                if (depth <= 0) {
                    if (has_top && has_top_margin && has_right && has_theme_base)
                        printf "%s: content-side base surface starts below chromeHeight instead of extending under the title band\n", start
                    in_block = 0
                }
            }
        }
    ' "$file"
}

detect_large_window_size_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((D\.)?ApplicationWindow|Window)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
            }

            if (in_root) {
                if (depth == 1 && line ~ /^[[:space:]]*(width|height|minimumWidth|minimumHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    prop = line
                    sub(/^[[:space:]]*/, "", prop)
                    split(prop, parts, ":")
                    key = parts[1]
                    value = parts[2]
                    gsub(/[^0-9]/, "", value)
                    num = value + 0

                    if (key == "width" && num > 1280)
                        printf "%s: width %d exceeds 1280 baseline\n", NR, num
                    if (key == "height" && num > 840)
                        printf "%s: height %d exceeds 840 baseline\n", NR, num
                    if (key == "minimumWidth" && num > 1040)
                        printf "%s: minimumWidth %d exceeds 1040 baseline\n", NR, num
                    if (key == "minimumHeight" && num > 720)
                        printf "%s: minimumHeight %d exceeds 720 baseline\n", NR, num
                }

                depth += delta
                if (depth <= 0)
                    in_root = 0
            }
        }
    ' "$file"
}

detect_small_settings_dialog_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
            }

            if (in_root) {
                if (depth == 1 && line ~ /^[[:space:]]*(width|height)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    prop = line
                    sub(/^[[:space:]]*/, "", prop)
                    split(prop, parts, ":")
                    key = parts[1]
                    value = parts[2]
                    gsub(/[^0-9]/, "", value)
                    num = value + 0

                    if (key == "width" && num < 960)
                        printf "%s: settings dialog width %d is below 960 baseline\n", NR, num
                    if (key == "height" && num < 680)
                        printf "%s: settings dialog height %d is below 680 baseline\n", NR, num
                }

                depth += delta
                if (depth <= 0)
                    in_root = 0
            }
        }
    ' "$file"
}

detect_settings_dialog_missing_icon_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
            root_line = 0
            has_icon = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
                root_line = NR
                has_icon = 0
            }

            if (in_root) {
                if (depth == 1 && line ~ /^[[:space:]]*icon[[:space:]]*:/)
                    has_icon = 1

                depth += delta
                if (depth <= 0) {
                    if (!has_icon)
                        printf "%s: Settings.SettingsDialog root omits icon; populate the standard top-left icon slot\n", root_line
                    in_root = 0
                }
            }
        }
    ' "$file"
}

detect_standard_dtk_surface_system_titlebar_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_target = 0
            depth = 0
            root_line = 0
            target_type = ""
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_target && line ~ /^[[:space:]]*((D\.)?AboutDialog|(Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_target = 1
                depth = 0
                root_line = NR
                target_type = line
                sub(/^[[:space:]]*/, "", target_type)
                sub(/[[:space:]]*\{.*/, "", target_type)
            }

            if (in_target) {
                if (depth == 1 && line ~ /^[[:space:]]*D\.DWindow\.enabled[[:space:]]*:[[:space:]]*false\b/) {
                    printf "%s: %s should keep the local DTK title bar; do not force a system title bar with D.DWindow.enabled: false\n", NR, target_type
                }

                depth += delta
                if (depth <= 0) {
                    in_target = 0
                    target_type = ""
                }
            }
        }
    ' "$file"
}

detect_settings_checkbox_fallback_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
            }

            if (in_root) {
                if (line ~ /(^|[^A-Za-z0-9_.])(D\.)?CheckBox[[:space:]]*\{/) {
                    printf "%s: checkbox-style settings rows should use Settings.CheckBox when it is exported locally\n", NR
                }

                depth += delta
                if (depth <= 0)
                    in_root = 0
            }
        }
    ' "$file"
}

detect_settings_combobox_fallback_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
            }

            if (in_root) {
                if (line ~ /(^|[^A-Za-z0-9_.])(D\.)?ComboBox[[:space:]]*\{/) {
                    printf "%s: combo-box settings rows should use Settings.ComboBox when it is exported locally\n", NR
                }

                depth += delta
                if (depth <= 0)
                    in_root = 0
            }
        }
    ' "$file"
}

detect_settings_lineedit_fallback_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{/) {
                in_root = 1
                depth = 0
            }

            if (in_root) {
                if (line ~ /(^|[^A-Za-z0-9_.])(D\.)?(LineEdit|TextField)[[:space:]]*\{/) {
                    printf "%s: editable settings rows should use Settings.LineEdit when it is exported locally\n", NR
                }

                depth += delta
                if (depth <= 0)
                    in_root = 0
            }
        }
    ' "$file"
}

detect_plain_dtk_control_fallback_hits() {
    local file="$1"
    local control="$2"

    case "$control" in
        Button)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?Button[[:space:]]*\{' "$file" || true
            ;;
        TextField)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?TextField[[:space:]]*\{' "$file" || true
            ;;
        ComboBox)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?ComboBox[[:space:]]*\{' "$file" || true
            ;;
        Switch)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?Switch[[:space:]]*\{' "$file" || true
            ;;
        CheckBox)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?CheckBox[[:space:]]*\{' "$file" || true
            ;;
        Menu)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?Menu[[:space:]]*\{' "$file" || true
            ;;
        ProgressBar)
            grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?ProgressBar[[:space:]]*\{' "$file" || true
            ;;
        ScrollBar)
            {
                grep -nE 'ScrollBar\.(horizontal|vertical)[[:space:]]*:[[:space:]]*(QQC\.)?ScrollBar[[:space:]]*\{' "$file" || true
                grep -nE '(^|[^A-Za-z0-9_.])(QQC\.)?ScrollBar[[:space:]]*\{' "$file" || true
            } | awk '!seen[$0]++'
            ;;
    esac
}

detect_settings_option_delegate_theme_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_delegate = 0
            depth = 0
            theme_line = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_delegate && line ~ /Settings\.OptionDelegate[[:space:]]*\{/) {
                in_delegate = 1
                depth = 0
                theme_line = 0
            }

            if (in_delegate) {
                if (!theme_line && line ~ /Theme\./)
                    theme_line = NR

                depth += delta
                if (depth <= 0) {
                    if (theme_line)
                        printf "%s: custom settings fallback row uses project Theme metrics instead of staying on DTK settings rhythm\n", theme_line
                    in_delegate = 0
                }
            }
        }
    ' "$file"
}

detect_shadowed_delegate_role_hits() {
    local file="$1"
    if grep -qE 'SettingRow[[:space:]]*\{|SectionCard[[:space:]]*\{|MetricCard[[:space:]]*\{|PageHeader[[:space:]]*\{|StatusBadge[[:space:]]*\{|CircularScore[[:space:]]*\{' "$file" \
        && grep -qE 'required[[:space:]]+property[[:space:]]+[A-Za-z0-9_.]+[[:space:]]+(title|description|subtitle|text|statusText|label|name|valueText|captionText|secondaryText|primaryText)\b' "$file" \
        && grep -qE '^[[:space:]]*(title|description|subtitle|text|statusText|label|name|valueText|captionText|secondaryText|primaryText)[[:space:]]*:' "$file"
    then
        grep -nE 'required[[:space:]]+property[[:space:]]+[A-Za-z0-9_.]+[[:space:]]+(title|description|subtitle|text|statusText|label|name|valueText|captionText|secondaryText|primaryText)\b' "$file" || true
    fi
}

detect_small_circular_score_usage_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_block = 0
            depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*CircularScore[[:space:]]*\{/) {
                in_block = 1
                depth = 0
            }

            if (in_block) {
                if (depth == 1 && line ~ /^[[:space:]]*(width|height|Layout\.preferredWidth|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > 0 && num < 220)
                        printf "%s: CircularScore consumed at %d, below 220 safe-size baseline\n", NR, num
                }

                depth += delta
                if (depth <= 0)
                    in_block = 0
            }
        }
    ' "$file"
}

detect_multiline_setting_row_missing_icon_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_row = 0
            depth = 0
            start = 0
            has_multiline = 0
            has_leading = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*SettingRow[[:space:]]*\{/) {
                in_row = 1
                depth = 0
                start = NR
                has_multiline = 0
                has_leading = 0
            }

            if (in_row) {
                if (depth == 1 && line ~ /^[[:space:]]*description[[:space:]]*:/ && line !~ /""[[:space:]]*$/) {
                    has_multiline = 1
                }
                if (depth == 1 && (line ~ /^[[:space:]]*leading[[:space:]]*:/ || line ~ /^[[:space:]]*leadingWidth[[:space:]]*:[[:space:]]*[1-9][0-9]*/)) {
                    has_leading = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (has_multiline && !has_leading) {
                        printf "%s: SettingRow with multi-line description lacks a leading icon slot\n", start
                    }
                    in_row = 0
                }
            }
        }
    ' "$file"
}

detect_multiline_setting_row_icon_size_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_row = 0
            depth = 0
            start = 0
            has_multiline = 0
            leading_width = -1
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*SettingRow[[:space:]]*\{/) {
                in_row = 1
                depth = 0
                start = NR
                has_multiline = 0
                leading_width = -1
            }

            if (in_row) {
                if (depth == 1 && line ~ /^[[:space:]]*description[[:space:]]*:/ && line !~ /""[[:space:]]*$/) {
                    has_multiline = 1
                }
                if (depth == 1 && line ~ /^[[:space:]]*leadingWidth[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    leading_width = value + 0
                }

                depth += delta
                if (depth <= 0) {
                    if (has_multiline && leading_width > 0 && leading_width != 24) {
                        printf "%s: multi-line SettingRow uses leadingWidth %d; expected 24 icon baseline\n", start, leading_width
                    }
                    if (!has_multiline && leading_width > 0 && leading_width != 16) {
                        printf "%s: single-line SettingRow uses leadingWidth %d; expected 16 icon baseline\n", start, leading_width
                    }
                    in_row = 0
                }
            }
        }
    ' "$file"
}

detect_list_leading_icon_background_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_row = 0
            row_depth = 0
            in_leading = 0
            leading_depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*(SettingRow|SettingsOptionRow)[[:space:]]*\{/) {
                in_row = 1
                row_depth = 0
                in_leading = 0
                leading_depth = 0
            }

            if (in_row) {
                if (row_depth == 1 && line ~ /^[[:space:]]*iconBackground([A-Za-z]+)?[[:space:]]*:/ \
                    && line !~ /(false|Qt\.transparent|transparent|""|undefined|null)/)
                {
                    printf "%s: list leading icon must not declare a self-drawn background\n", NR
                }

                if (!in_leading && row_depth == 1 \
                    && line ~ /^[[:space:]]*(leading|iconDelegate|iconItem)[[:space:]]*:[[:space:]]*Component[[:space:]]*\{/)
                {
                    in_leading = 1
                    leading_depth = 0
                }

                if (in_leading) {
                    if (line ~ /^[[:space:]]*(Rectangle|D\.BoxPanel|D\.BackgroundPanel)[[:space:]]*\{/) {
                        printf "%s: list leading icon must not be wrapped in a self-drawn background block\n", NR
                    }

                    leading_depth += delta
                    if (leading_depth <= 0)
                        in_leading = 0
                }

                row_depth += delta
                if (row_depth <= 0)
                    in_row = 0
            }
        }
    ' "$file"
}

detect_multiline_row_top_alignment_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    case "$base" in
        SettingRow.qml|TaskRow.qml)
            ;;
        *)
            return 0
            ;;
    esac

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_column = 0
            depth = 0
            start = 0
            has_top_alignment = 0
            saw_wrapped_text = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_column && line ~ /^[[:space:]]*ColumnLayout[[:space:]]*\{/) {
                in_column = 1
                depth = 0
                start = NR
                has_top_alignment = 0
                saw_wrapped_text = 0
            }

            if (in_column) {
                if (depth == 1 && line ~ /^[[:space:]]*Layout\.alignment[[:space:]]*:/ && line ~ /Qt\.AlignTop/)
                    has_top_alignment = 1
                if (line ~ /wrapMode[[:space:]]*:[[:space:]]*Text\.WordWrap/)
                    saw_wrapped_text = 1

                depth += delta
                if (depth <= 0) {
                    if (saw_wrapped_text && !has_top_alignment)
                        printf "%s: multi-line row text column is not top-aligned, so the leading icon will read as vertically centered\n", start
                    in_column = 0
                }
            }
        }
    ' "$file"
}

detect_secondary_settings_entry_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_button = 0
            depth = 0
            start = 0
            has_settings_text = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_button && line ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton|ToolButton|IconButton)|QQC\.Button)[[:space:]]*\{/) {
                in_button = 1
                depth = 0
                start = NR
                has_settings_text = 0
            }

            if (in_button) {
                if (depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:[[:space:]]*"设置"[[:space:]]*$/) {
                    has_settings_text = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (has_settings_text) {
                        printf "%s: standalone settings button found outside the main menu path\n", start
                    }
                    in_button = 0
                }
            }
        }
    ' "$file"
}

detect_wide_button_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_button = 0
            depth = 0
            start = 0
            has_fill = 0
            has_max = 0
            wide_width = -1
            footer_top = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*(DialogActionFooter|D\.DialogButtonBox)[[:space:]]*\{/) {
                footer_top++
                footer_depth[footer_top] = 0
            }

            if (!in_button && line ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/) {
                in_button = 1
                depth = 0
                start = NR
                has_fill = 0
                has_max = 0
                wide_width = -1
                button_inside_dialog_footer = (footer_top > 0)
            }

            if (in_button) {
                if (depth == 1 && line ~ /^[[:space:]]*(Layout\.fillWidth|fillWidth)[[:space:]]*:[[:space:]]*true[[:space:]]*$/) {
                    has_fill = 1
                }
                if (depth == 1 && line ~ /^[[:space:]]*width[[:space:]]*:[[:space:]]*[^0-9]*parent\.width/) {
                    has_fill = 1
                }
                if (depth == 1 && line ~ /^[[:space:]]*(Layout\.maximumWidth|maximumWidth)[[:space:]]*:/) {
                    has_max = 1
                }
                if (depth == 1 && line ~ /^[[:space:]]*(width|Layout\.preferredWidth)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > 260)
                        wide_width = num
                }

                depth += delta
                if (depth <= 0) {
                    if (!button_inside_dialog_footer && wide_width > 0) {
                        printf "%s: button width %d exceeds the capped-width baseline\n", start, wide_width
                    }
                    if (!button_inside_dialog_footer && has_fill && !has_max) {
                        printf "%s: fill-width button lacks maximumWidth or Layout.maximumWidth\n", start
                    }
                    in_button = 0
                }
            }

            if (footer_top > 0) {
                footer_depth[footer_top] += delta
                while (footer_top > 0 && footer_depth[footer_top] <= 0) {
                    delete footer_depth[footer_top]
                    footer_top--
                }
            }
        }
    ' "$file"
}

detect_horizontal_scroll_risk_hits() {
    local file="$1"
    {
        grep -nE 'flickableDirection[[:space:]]*:[[:space:]]*Flickable\.(HorizontalFlick|AutoFlickDirection)' "$file" || true
        grep -nE 'ScrollBar\.horizontal\.(policy|visible)[[:space:]]*:[[:space:]]*(true|ScrollBar\.(AsNeeded|AlwaysOn))' "$file" || true
        grep -nE 'contentWidth[[:space:]]*:[[:space:]]*([0-9]+|.*childrenRect\.width|.*implicitWidth)' "$file" || true
    } | awk '!seen[$0]++'
}

detect_horizontal_scrollbar_thickness_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function flush_bar() {
            if (in_bar) {
                if (orientation == "horizontal" && max_height > 20)
                    printf "%s: horizontal ScrollBar thickness %d exceeds the 20px limit\n", start, max_height
                else if (orientation == "vertical" && max_width > 20)
                    printf "%s: vertical ScrollBar thickness %d exceeds the 20px limit\n", start, max_width
            }

            in_bar = 0
            depth = 0
            start = 0
            orientation = ""
            max_height = 0
            max_width = 0
        }

        BEGIN {
            flush_bar()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_bar && line ~ /ScrollBar\.horizontal[[:space:]]*:[[:space:]]*(QQC\.)?ScrollBar[[:space:]]*\{/) {
                in_bar = 1
                depth = 0
                start = NR
                orientation = "horizontal"
                max_height = 0
                max_width = 0
            } else if (!in_bar && line ~ /ScrollBar\.vertical[[:space:]]*:[[:space:]]*(QQC\.)?ScrollBar[[:space:]]*\{/) {
                in_bar = 1
                depth = 0
                start = NR
                orientation = "vertical"
                max_height = 0
                max_width = 0
            } else if (!in_bar && line ~ /^[[:space:]]*(QQC\.)?ScrollBar[[:space:]]*\{/) {
                in_bar = 1
                depth = 0
                start = NR
                orientation = ""
                max_height = 0
                max_width = 0
            }

            if (in_bar) {
                if (depth == 1 && line ~ /^[[:space:]]*orientation[[:space:]]*:[[:space:]]*Qt\.Horizontal/)
                    orientation = "horizontal"
                else if (depth == 1 && line ~ /^[[:space:]]*orientation[[:space:]]*:[[:space:]]*Qt\.Vertical/)
                    orientation = "vertical"

                if (line ~ /(^|[^A-Za-z0-9_])(height|implicitHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > max_height)
                        max_height = num
                }

                if (line ~ /(^|[^A-Za-z0-9_])(width|implicitWidth)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > max_width)
                        max_width = num
                }

                depth += delta
                if (depth <= 0)
                    flush_bar()
            }
        }

        END {
            if (in_bar)
                flush_bar()
        }
    ' "$file"
}

detect_duplicate_progress_mode_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function normalize_expr(s,   expr) {
            expr = s
            sub(/^[^:]*:[[:space:]]*/, "", expr)
            sub(/[[:space:]]*(\/\/.*)?$/, "", expr)
            gsub(/[[:space:]]+/, "", expr)
            gsub(/\/100(\.0+)?/, "", expr)
            gsub(/[()]/, "", expr)
            return expr
        }

        function start_block(kind_name) {
            in_block = 1
            block_kind = kind_name
            depth = 0
            start = NR
        }

        BEGIN {
            in_block = 0
            block_kind = ""
            depth = 0
            circular_count = 0
            linear_count = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*CircularScore[[:space:]]*\{/) {
                start_block("circular")
            } else if (!in_block && line ~ /^[[:space:]]*(D\.)?ProgressBar[[:space:]]*\{/) {
                start_block("linear")
            }

            if (in_block) {
                if (depth == 1 && line ~ /^[[:space:]]*value[[:space:]]*:/) {
                    expr = normalize_expr(line)
                    if (expr != "") {
                        if (block_kind == "circular") {
                            circular_count++
                            circular_expr[circular_count] = expr
                            circular_line[circular_count] = start
                        } else if (block_kind == "linear") {
                            linear_count++
                            linear_expr[linear_count] = expr
                            linear_line[linear_count] = start
                        }
                    }
                }

                depth += delta
                if (depth <= 0) {
                    in_block = 0
                    block_kind = ""
                }
            }
        }

        END {
            for (i = 1; i <= circular_count; ++i) {
                for (j = 1; j <= linear_count; ++j) {
                    if (circular_expr[i] != "" && circular_expr[i] == linear_expr[j]) {
                        printf "%s: same ratio is rendered by both circular/ring and horizontal progress in this file; choose one form only\n", circular_line[i]
                        exit
                    }
                }
            }
        }
    ' "$file"
}

detect_legacy_page_list_row_hits() {
    local file="$1"
    case "$file" in
        */pages/*.qml) ;;
        *) return ;;
    esac

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_repeat() {
            in_repeat = 0
            repeat_depth = 0
            repeat_targets_object_list = 0
        }

        function is_object_list_signal(s) {
            return s ~ /(software|startup|service|program|file|data)[A-Za-z0-9_]*(Items|Model|List|Results|Entries)/ \
                || s ~ /(visibleItems|filteredSoftwareItems|softwareItems|startupItemsModel)/
        }

        BEGIN {
            reset_repeat()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_repeat && line ~ /^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{/) {
                in_repeat = 1
                repeat_depth = 0
                repeat_targets_object_list = 0
            }

            if (in_repeat) {
                if (is_object_list_signal(line))
                    repeat_targets_object_list = 1

                if (repeat_targets_object_list && line ~ /^[[:space:]]*(SettingRow|SettingsOptionRow)[[:space:]]*\{/) {
                    row_type = line
                    sub(/^[[:space:]]*/, "", row_type)
                    sub(/[[:space:]]*\{.*$/, "", row_type)
                    printf "%s: variable-length page list should not rely on legacy %s defaults; use a compact responsive row plan\n", NR, row_type
                }

                repeat_depth += delta
                if (repeat_depth <= 0)
                    reset_repeat()
            }
        }
    ' "$file"
}

detect_variable_object_list_card_hits() {
    local file="$1"
    case "$file" in
        */pages/*.qml) ;;
        *) return ;;
    esac

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_repeat() {
            in_repeat = 0
            repeat_depth = 0
            repeat_targets_object_list = 0
        }

        function is_object_list_signal(s) {
            return s ~ /(software|startup|service|program|file|data)[A-Za-z0-9_]*(Items|Model|List|Results|Entries)/ \
                || s ~ /(visibleItems|filteredSoftwareItems|softwareItems|startupItemsModel)/
        }

        BEGIN {
            reset_repeat()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_repeat && line ~ /^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{/) {
                in_repeat = 1
                repeat_depth = 0
                repeat_targets_object_list = 0
            }

            if (in_repeat) {
                if (is_object_list_signal(line))
                    repeat_targets_object_list = 1

                if (repeat_targets_object_list && line ~ /^[[:space:]]*SectionCard[[:space:]]*\{/) {
                    printf "%s: variable-length page list should not render each item as a standalone SectionCard; use compact responsive rows instead\n", NR
                }

                repeat_depth += delta
                if (repeat_depth <= 0)
                    reset_repeat()
            }
        }
    ' "$file"
}

detect_textless_progress_thickness_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    awk -v base="$base" '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_block() {
            in_block = 0
            depth = 0
            start = 0
            has_text = 0
            has_cap = 0
            max_cap = -1
        }

        function line_is_linear_progress_decl(s) {
            return s ~ /^[[:space:]]*((D\.)?ProgressBar|[A-Za-z0-9_]*Progress(Bar|Strip|Track|Line|Rail|Indicator)?)[[:space:]]*\{/ \
                && s !~ /(Circular|Ring|Arc|Busy|Score|Gauge)/
        }

        function line_is_root_progress_shell(s) {
            return base ~ /Progress\.qml$/ \
                && base !~ /(Circular|Ring|Arc|Busy|Score|Gauge)/ \
                && s ~ /^[[:space:]]*(Item|Rectangle|Control)[[:space:]]*\{/
        }

        function capture_cap(s,   value, num) {
            has_cap = 1
            if (s ~ /:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                value = s
                sub(/.*:[[:space:]]*/, "", value)
                gsub(/[^0-9]/, "", value)
                num = value + 0
                if (num > max_cap)
                    max_cap = num
            } else if (s ~ /Math\.min\([^)]*20/ || s ~ /:[[:space:]]*20([[:space:]]*(\/\/.*)?$)/) {
                if (20 > max_cap)
                    max_cap = 20
            }
        }

        function flush_block() {
            if (in_block && !has_text) {
                if (!has_cap) {
                    printf "%s: textless progress indicator lacks an explicit <=20px thickness cap\n", start
                } else if (max_cap > 20) {
                    printf "%s: textless progress indicator thickness %d exceeds the 20px limit\n", start, max_cap
                }
            }
            reset_block()
        }

        BEGIN {
            reset_block()
            root_checked = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line_is_linear_progress_decl(line)) {
                in_block = 1
                depth = 0
                start = NR
            } else if (!in_block && !root_checked && line_is_root_progress_shell(line)) {
                in_block = 1
                depth = 0
                start = NR
                root_checked = 1
            }

            if (in_block) {
                if (depth >= 1 && line ~ /^[[:space:]]*((D\.)?Label|Text|MetricValueLabel)[[:space:]]*\{/)
                    has_text = 1

                if (depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|maximumHeight|minimumHeight|Layout\.preferredHeight|Layout\.maximumHeight|Layout\.minimumHeight)[[:space:]]*:/)
                    capture_cap(line)

                depth += delta
                if (depth <= 0)
                    flush_block()
            }
        }

        END {
            if (in_block)
                flush_block()
        }
    ' "$file"
}

detect_fixed_score_hero_card_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function flush_card() {
            if (in_card && fixed_height >= 360 && has_score && has_centered_layout)
                printf "%s: fixed tall score hero card should use content-driven spacing instead of a large static shell\n", start

            in_card = 0
            depth = 0
            start = 0
            fixed_height = 0
            has_score = 0
            has_centered_layout = 0
        }

        BEGIN {
            flush_card()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card && line ~ /^[[:space:]]*SectionCard[[:space:]]*\{/) {
                in_card = 1
                depth = 0
                start = NR
                fixed_height = 0
                has_score = 0
                has_centered_layout = 0
            }

            if (in_card) {
                if (depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > fixed_height)
                        fixed_height = num
                }

                if (line ~ /CircularScore[[:space:]]*\{/)
                    has_score = 1
                if (line ~ /anchors\.centerIn[[:space:]]*:[[:space:]]*parent/)
                    has_centered_layout = 1

                depth += delta
                if (depth <= 0)
                    flush_card()
            }
        }

        END {
            if (in_card)
                flush_card()
        }
    ' "$file"
}

detect_focal_wrapper_mismatch_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function numeric_value(s,   value) {
            value = s
            sub(/.*:[[:space:]]*/, "", value)
            gsub(/[^0-9.]/, "", value)
            return value + 0
        }

        function reset_wrapper() {
            in_wrapper = 0
            wrapper_depth = 0
            wrapper_start = 0
            wrapper_height = -1
            in_focal = 0
            focal_depth = 0
            focal_height = -1
        }

        BEGIN {
            reset_wrapper()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_wrapper && line ~ /^[[:space:]]*(Item|Rectangle)[[:space:]]*\{/) {
                in_wrapper = 1
                wrapper_depth = 0
                wrapper_start = NR
                wrapper_height = -1
                in_focal = 0
                focal_depth = 0
                focal_height = -1
            }

            if (in_wrapper) {
                if (wrapper_depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = numeric_value(line)
                    if (value > wrapper_height)
                        wrapper_height = value
                }

                if (!in_focal && wrapper_depth == 1 && line ~ /^[[:space:]]*(CircularScore|PerformanceChart)[[:space:]]*\{/) {
                    in_focal = 1
                    focal_depth = 0
                    focal_height = -1
                }

                if (in_focal) {
                    if (focal_depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                        value = numeric_value(line)
                        if (value > focal_height)
                            focal_height = value
                    }

                    focal_depth += delta
                    if (focal_depth <= 0) {
                        if (wrapper_height > 0 && focal_height > wrapper_height)
                            printf "%s: focal wrapper height %d is smaller than contained focal visual height %d\n", wrapper_start, wrapper_height, focal_height
                        in_focal = 0
                        focal_depth = 0
                        focal_height = -1
                    }
                }

                wrapper_depth += delta
                if (wrapper_depth <= 0)
                    reset_wrapper()
            }
        }
    ' "$file"
}

detect_fill_anchored_card_layout_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_card() {
            in_card = 0
            card_depth = 0
            card_start = 0
            in_layout = 0
            layout_depth = 0
            layout_start = 0
            layout_fill_anchor = 0
            layout_fill_spacer = 0
        }

        BEGIN {
            reset_card()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card && line ~ /^[[:space:]]*SectionCard[[:space:]]*\{/) {
                in_card = 1
                card_depth = 0
                card_start = NR
                in_layout = 0
            }

            if (in_card) {
                if (!in_layout && card_depth == 1 && line ~ /^[[:space:]]*(ColumnLayout|RowLayout)[[:space:]]*\{/) {
                    in_layout = 1
                    layout_depth = 0
                    layout_start = NR
                    layout_fill_anchor = 0
                    layout_fill_spacer = 0
                }

                if (in_layout) {
                    if (layout_depth == 1 && line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent/)
                        layout_fill_anchor = 1
                    if (line ~ /Layout\.fillHeight[[:space:]]*:[[:space:]]*true/)
                        layout_fill_spacer = 1

                    layout_depth += delta
                    if (layout_depth <= 0) {
                        if (layout_fill_anchor && layout_fill_spacer)
                            printf "%s: direct fill-anchored layout inside SectionCard uses Layout.fillHeight spacers and may bypass the card sizing flow\n", layout_start
                        in_layout = 0
                    }
                }

                card_depth += delta
                if (card_depth <= 0)
                    reset_card()
            }
        }
    ' "$file"
}

detect_oversized_card_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_card = 0
            depth = 0
            start = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card && line ~ /^[[:space:]]*(SectionCard|MetricCard)[[:space:]]*\{/) {
                in_card = 1
                depth = 0
                start = NR
            }

            if (in_card) {
                if (depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    num = value + 0
                    if (num > 400)
                        printf "%s: card shell height %d exceeds the oversized-card baseline\n", start, num
                }

                depth += delta
                if (depth <= 0)
                    in_card = 0
            }
        }
    ' "$file"
}

detect_fixed_card_shell_size_hits() {
    local file="$1"
    awk -v file_path="$file" '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function starts_object(line) {
            return line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/
        }

        function starts_card_object(line) {
            return line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*Card[[:space:]]*\{/
        }

        function is_fixed_rhs(expr,   rhs) {
            rhs = expr
            sub(/^[^:]*:[[:space:]]*/, "", rhs)
            sub(/[[:space:]]*(\/\/.*)?$/, "", rhs)
            gsub(/[[:space:]]+/, "", rhs)
            return rhs ~ /^[0-9]+(\.[0-9]+)?$/ \
                || rhs ~ /^[A-Za-z_][A-Za-z0-9_.]*\?[0-9]+(\.[0-9]+)?:[0-9]+(\.[0-9]+)?$/
        }

        BEGIN {
            in_card = 0
            depth = 0
            card_file = (file_path ~ /(^|\/)[^\/]*Card[^\/]*\.qml$/)
            card_file_root_seen = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card) {
                if (card_file && !card_file_root_seen && starts_object(line)) {
                    in_card = 1
                    depth = 0
                    card_file_root_seen = 1
                } else if (starts_card_object(line)) {
                    in_card = 1
                    depth = 0
                }
            }

            if (in_card) {
                if (depth == 1 \
                    && line ~ /^[[:space:]]*(width|height|implicitWidth|implicitHeight|Layout\.preferredWidth|Layout\.preferredHeight)[[:space:]]*:/ \
                    && is_fixed_rhs(line)) {
                    prop = line
                    sub(/^[[:space:]]*/, "", prop)
                    sub(/[[:space:]]*:.*$/, "", prop)
                    value = line
                    sub(/^[^:]*:[[:space:]]*/, "", value)
                    sub(/[[:space:]]*(\/\/.*)?$/, "", value)
                    printf "%s: card shell uses fixed %s '\''%s'\''; use responsive content-driven sizing plus min/max bounds instead\n", NR, prop, value
                }

                depth += delta
                if (depth <= 0) {
                    in_card = 0
                    depth = 0
                }
            }
        }
    ' "$file"
}

detect_card_focal_content_edge_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function numeric_value(s,   value) {
            value = s
            sub(/.*:[[:space:]]*/, "", value)
            gsub(/[^0-9.]/, "", value)
            return value + 0
        }

        function starts_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/
        }

        function starts_card_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*Card[[:space:]]*\{/
        }

        BEGIN {
            in_card = 0
            card_depth = 0
            card_padding = -1
            in_block = 0
            block_depth = 0
            block_start = 0
            block_has_focal = 0
            block_fill = 0
            block_left = 0
            block_right = 0
            block_top = 0
            block_bottom = 0
            block_margin = 0
            card_file = (FILENAME ~ /(^|\/)[^\/]*Card[^\/]*\.qml$/)
            card_file_root_seen = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card) {
                if (card_file && !card_file_root_seen && starts_object(line)) {
                    in_card = 1
                    card_depth = 0
                    card_padding = -1
                    in_block = 0
                    card_file_root_seen = 1
                } else if (starts_card_object(line)) {
                    in_card = 1
                    card_depth = 0
                    card_padding = -1
                    in_block = 0
                }
            }

            if (in_card) {
                if (card_depth == 1 && line ~ /^[[:space:]]*padding[[:space:]]*:[[:space:]]*([0-9]+|0\.[0-9]+)/)
                    card_padding = numeric_value(line)

                if (!in_block && line ~ /^[[:space:]]*(Item|Rectangle|Row|Column|Grid|RowLayout|ColumnLayout|GridLayout|Loader|Canvas|Image|SvgIcon|CircularScore|PerformanceChart|MetricValueLabel)[[:space:]]*\{/) {
                    in_block = 1
                    block_depth = 0
                    block_start = NR
                    block_has_focal = (line ~ /(Canvas|Image|SvgIcon|CircularScore|PerformanceChart)[[:space:]]*\{/)
                    block_fill = 0
                    block_left = 0
                    block_right = 0
                    block_top = 0
                    block_bottom = 0
                    block_margin = 0
                }

                if (in_block) {
                    if (line ~ /CircularScore[[:space:]]*\{|PerformanceChart[[:space:]]*\{|Canvas[[:space:]]*\{|Image[[:space:]]*\{|SvgIcon[[:space:]]*\{/)
                        block_has_focal = 1
                    if (line ~ /^[[:space:]]*valueSize[[:space:]]*:[[:space:]]*([2-9][8-9]|[3-9][0-9]|[1-9][0-9][0-9])([^0-9]|$)/)
                        block_has_focal = 1

                    if (block_depth == 1 && line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                        block_fill = 1
                    if (block_depth == 1 && line ~ /^[[:space:]]*anchors\.left[[:space:]]*:[[:space:]]*parent\.left/)
                        block_left = 1
                    if (block_depth == 1 && line ~ /^[[:space:]]*anchors\.right[[:space:]]*:[[:space:]]*parent\.right/)
                        block_right = 1
                    if (block_depth == 1 && line ~ /^[[:space:]]*anchors\.top[[:space:]]*:[[:space:]]*parent\.top/)
                        block_top = 1
                    if (block_depth == 1 && line ~ /^[[:space:]]*anchors\.bottom[[:space:]]*:[[:space:]]*parent\.bottom/)
                        block_bottom = 1
                    if (block_depth == 1 \
                        && line ~ /^[[:space:]]*anchors\.(margins|leftMargin|rightMargin|topMargin|bottomMargin)[[:space:]]*:/ \
                        && line !~ /:[[:space:]]*0([[:space:]]*(\/\/.*)?$)/ \
                        && line !~ /:[[:space:]]*0\.0+([[:space:]]*(\/\/.*)?$)/)
                        block_margin = 1

                    block_depth += delta
                    if (block_depth <= 0) {
                        if (card_padding == 0 && block_has_focal && !block_margin && (block_fill || (block_left && block_right) || (block_top && block_bottom)))
                            printf "%s: zero-padding card lets focal foreground content bind to parent edges without an inner safe area\n", block_start
                        in_block = 0
                    }
                }

                card_depth += delta
                if (card_depth <= 0)
                    in_card = 0
            }
        }
    ' "$file"
}

detect_card_live_content_inset_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function starts_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/
        }

        function starts_card_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*Card[[:space:]]*\{/
        }

        function starts_live_container(s) {
            return s ~ /^[[:space:]]*(Item|Rectangle|Row|Column|Grid|Flow|Pane|Frame|Control|RowLayout|ColumnLayout|GridLayout|Flickable|ScrollView|ListView|GridView|PathView)[[:space:]]*\{/
        }

        BEGIN {
            in_card = 0
            card_depth = 0
            in_block = 0
            block_depth = 0
            block_start = 0
            card_file = (FILENAME ~ /(^|\/)[^\/]*Card[^\/]*\.qml$/)
            card_file_root_seen = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card) {
                if (card_file && !card_file_root_seen && starts_object(line)) {
                    in_card = 1
                    card_depth = 0
                    in_block = 0
                    card_file_root_seen = 1
                } else if (starts_card_object(line)) {
                    in_card = 1
                    card_depth = 0
                    in_block = 0
                }
            }

            if (in_card) {
                if (!in_block && card_depth == 1 && starts_live_container(line)) {
                    in_block = 1
                    block_depth = 0
                    block_start = NR
                    block_has_live = 0
                    block_fill = 0
                    block_left = 0
                    block_right = 0
                    block_top = 0
                    block_bottom = 0
                    block_parent_width = 0
                    block_parent_height = 0
                    block_any_margin = 0
                    block_h_margin = 0
                    block_v_margin = 0
                    block_bottom_margin = 0
                    block_padding = 0
                    block_bottom_padding = 0
                }

                if (in_block) {
                    if (line ~ /(Text|D\.Label|Label|((D\.)?(Button|RecommandButton|WarningButton|ToolButton|IconButton|Switch|CheckBox|ComboBox|TextField|SearchEdit))|Repeater|Flickable|ScrollView|ListView|GridView|PathView|Canvas|Image|SvgIcon|SymbolIcon)[[:space:]]*\{/)
                        block_has_live = 1

                    if (block_depth == 1) {
                        if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                            block_fill = 1
                        if (line ~ /^[[:space:]]*anchors\.left[[:space:]]*:[[:space:]]*parent\.left/)
                            block_left = 1
                        if (line ~ /^[[:space:]]*anchors\.right[[:space:]]*:[[:space:]]*parent\.right/)
                            block_right = 1
                        if (line ~ /^[[:space:]]*anchors\.top[[:space:]]*:[[:space:]]*parent\.top/)
                            block_top = 1
                        if (line ~ /^[[:space:]]*anchors\.bottom[[:space:]]*:[[:space:]]*parent\.bottom/)
                            block_bottom = 1
                        if (line ~ /^[[:space:]]*(width|implicitWidth)[[:space:]]*:[[:space:]]*parent\.width([[:space:]]*(\/\/.*)?$)/)
                            block_parent_width = 1
                        if (line ~ /^[[:space:]]*(height|implicitHeight)[[:space:]]*:[[:space:]]*parent\.height([[:space:]]*(\/\/.*)?$)/)
                            block_parent_height = 1

                        if (line ~ /^[[:space:]]*anchors\.margins[[:space:]]*:/) {
                            block_any_margin = 1
                            block_h_margin = 1
                            block_v_margin = 1
                            block_bottom_margin = 1
                        }
                        if (line ~ /^[[:space:]]*anchors\.(leftMargin|rightMargin)[[:space:]]*:/) {
                            block_any_margin = 1
                            block_h_margin = 1
                        }
                        if (line ~ /^[[:space:]]*anchors\.(topMargin|bottomMargin)[[:space:]]*:/) {
                            block_any_margin = 1
                            block_v_margin = 1
                        }
                        if (line ~ /^[[:space:]]*anchors\.bottomMargin[[:space:]]*:/) {
                            block_any_margin = 1
                            block_v_margin = 1
                            block_bottom_margin = 1
                        }
                        if (line ~ /^[[:space:]]*(padding|horizontalPadding|verticalPadding)[[:space:]]*:/)
                            block_padding = 1
                        if (line ~ /^[[:space:]]*(padding|bottomPadding|verticalPadding)[[:space:]]*:/)
                            block_bottom_padding = 1
                    }

                    block_depth += delta
                    if (block_depth <= 0) {
                        if (block_has_live && (block_fill || (block_left && block_right && block_top && block_bottom) || (block_parent_width && block_parent_height))) {
                            if (!block_any_margin && !block_padding)
                                printf "%s: card live-content container fills the card without any inner inset\n", block_start
                            else if (!block_bottom_margin && !block_v_margin && !block_bottom_padding)
                                printf "%s: card live-content container reaches the bottom edge without a real bottom inset\n", block_start
                        } else if (block_has_live && (block_fill || block_bottom || block_parent_height)) {
                            if (!block_bottom_margin && !block_v_margin && !block_bottom_padding)
                                printf "%s: card live-content container anchors into the bottom edge without a real bottom inset\n", block_start
                        }
                        in_block = 0
                    }
                }

                card_depth += delta
                if (card_depth <= 0)
                    in_card = 0
            }
        }
    ' "$file"
}

detect_dense_cluster_zero_spacing_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_block = 0
            depth = 0
            start = 0
            spacing_zero = 0
            has_graphic = 0
            has_text = 0
            has_button = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Row|Column|RowLayout|ColumnLayout)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                spacing_zero = 0
                has_graphic = 0
                has_text = 0
                has_button = 0
            }

            if (in_block) {
                if (depth == 1 && line ~ /^[[:space:]]*spacing[[:space:]]*:[[:space:]]*0([[:space:]]*(\/\/.*)?$)/)
                    spacing_zero = 1
                if (line ~ /SvgIcon|AppLogo|CircularScore|Image[[:space:]]*\{/)
                    has_graphic = 1
                if (line ~ /D\.Label[[:space:]]*\{|Label[[:space:]]*\{/)
                    has_text = 1
                if (line ~ /((D\.)?(Button|RecommandButton|WarningButton|ToolButton|IconButton)|QQC\.Button)[[:space:]]*\{/)
                    has_button = 1

                depth += delta
                if (depth <= 0) {
                    if (spacing_zero && ((has_graphic && has_text) || (has_graphic && has_button) || (has_text && has_button))) {
                        printf "%s: dense icon/text/button cluster uses spacing 0\n", start
                    }
                    in_block = 0
                }
            }
        }
    ' "$file"
}

detect_text_button_overlap_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function base_type(name,   t) {
            t = name
            sub(/^.*\./, "", t)
            return t
        }

        function is_container(name,   t) {
            t = base_type(name)
            return t ~ /^(Item|Rectangle|Row|Column|Grid|Flow|Pane|Frame|Control|RowLayout|ColumnLayout|GridLayout)$/
        }

        function is_text_button(name,   t) {
            t = base_type(name)
            return t ~ /^(Label|Text|Button|ToolButton|IconButton|RecommandButton|WarningButton)$/
        }

        function clear_slot(i) {
            delete type[i]
            delete start[i]
            delete depth[i]
            delete spacing_negative[i]
            delete child_tb_count[i]
            delete child_centered_tb_count[i]
            delete child_fill_tb_count[i]
            delete self_centered[i]
            delete self_fill[i]
        }

        BEGIN {
            stack = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{[[:space:]]*(\/\/.*)?$/) {
                stack++
                type[stack] = line
                sub(/^[[:space:]]*/, "", type[stack])
                sub(/[[:space:]]*\{.*/, "", type[stack])
                start[stack] = NR
                depth[stack] = 0
                spacing_negative[stack] = 0
                child_tb_count[stack] = 0
                child_centered_tb_count[stack] = 0
                child_fill_tb_count[stack] = 0
                self_centered[stack] = 0
                self_fill[stack] = 0
            }

            if (stack > 0) {
                if (depth[stack] == 1) {
                    if (is_container(type[stack]) && line ~ /^[[:space:]]*spacing[[:space:]]*:[[:space:]]*-[0-9]/)
                        spacing_negative[stack] = 1

                    if (is_text_button(type[stack])) {
                        if (line ~ /^[[:space:]]*anchors\.centerIn[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                            self_centered[stack] = 1
                        if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                            self_fill[stack] = 1
                    }
                }

                depth[stack] += delta
                while (stack > 0 && depth[stack] <= 0) {
                    closed = stack
                    parent = stack - 1

                    if (parent >= 1 && is_container(type[parent]) && is_text_button(type[closed])) {
                        child_tb_count[parent]++
                        if (self_centered[closed])
                            child_centered_tb_count[parent]++
                        if (self_fill[closed])
                            child_fill_tb_count[parent]++
                    }

                    if (is_container(type[closed])) {
                        if (spacing_negative[closed] && child_tb_count[closed] >= 2)
                            printf "%s: container uses negative spacing between direct text/button children and can overlap them\n", start[closed]
                        if (child_centered_tb_count[closed] > 1)
                            printf "%s: multiple direct text/button children center themselves in the same parent and can overlap\n", start[closed]
                        if (child_fill_tb_count[closed] > 1 || (child_fill_tb_count[closed] >= 1 && child_tb_count[closed] > child_fill_tb_count[closed]))
                            printf "%s: a direct text/button child fills the parent while peer controls share the same container\n", start[closed]
                    }

                    clear_slot(closed)
                    stack--
                }
            }
        }
    ' "$file"
}

detect_direct_content_stack_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function base_type(name,   t) {
            t = name
            sub(/^.*\./, "", t)
            return t
        }

        function is_container(name,   t) {
            t = base_type(name)
            return t ~ /^(Item|Rectangle|Row|Column|Grid|Flow|Pane|Frame|Control|RowLayout|ColumnLayout|GridLayout)$/
        }

        function is_live_content(name,   t) {
            t = base_type(name)
            return t ~ /^(Label|Text|Button|ToolButton|IconButton|RecommandButton|WarningButton|Switch|CheckBox|ComboBox|TextField|SearchEdit|Row|Column|Grid|Flow|RowLayout|ColumnLayout|GridLayout|ListView|GridView|PathView|Flickable|ScrollView|Loader)$/
        }

        function clear_slot(i) {
            delete type[i]
            delete start[i]
            delete depth[i]
            delete self_centered[i]
            delete self_fill[i]
            delete child_layer_count[i]
            delete child_centered_count[i]
            delete child_fill_count[i]
        }

        BEGIN {
            stack = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{[[:space:]]*(\/\/.*)?$/) {
                stack++
                type[stack] = line
                sub(/^[[:space:]]*/, "", type[stack])
                sub(/[[:space:]]*\{.*/, "", type[stack])
                start[stack] = NR
                depth[stack] = 0
                self_centered[stack] = 0
                self_fill[stack] = 0
                child_layer_count[stack] = 0
                child_centered_count[stack] = 0
                child_fill_count[stack] = 0
            }

            if (stack > 0) {
                if (depth[stack] == 1 && is_live_content(type[stack])) {
                    if (line ~ /^[[:space:]]*anchors\.centerIn[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                        self_centered[stack] = 1
                    if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                        self_fill[stack] = 1
                }

                depth[stack] += delta
                while (stack > 0 && depth[stack] <= 0) {
                    closed = stack
                    parent = stack - 1

                    if (parent >= 1 && is_container(type[parent]) && is_live_content(type[closed]) && (self_centered[closed] || self_fill[closed])) {
                        child_layer_count[parent]++
                        if (self_centered[closed])
                            child_centered_count[parent]++
                        if (self_fill[closed])
                            child_fill_count[parent]++
                    }

                    if (is_container(type[closed])) {
                        if (child_centered_count[closed] > 1)
                            printf "%s: multiple direct live-content children center themselves in the same parent and can visibly stack\n", start[closed]
                        if (child_fill_count[closed] > 1 || (child_fill_count[closed] >= 1 && child_layer_count[closed] > child_fill_count[closed]))
                            printf "%s: direct live-content children share one parent while one or more fill the parent and can visibly stack\n", start[closed]
                    }

                    clear_slot(closed)
                    stack--
                }
            }
        }
    ' "$file"
}

detect_dynamic_text_cutoff_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_block() {
            in_block = 0
            depth = 0
            start = 0
            has_text = 0
            dynamic_text = 0
            constrained = 0
            has_left = 0
            has_right = 0
            wrapped = 0
            elided = 0
        }

        function is_simple_static_text(s) {
            return s ~ /^[[:space:]]*text[[:space:]]*:[[:space:]]*"[^"]*"[[:space:]]*(\/\/.*)?$/ \
                || s ~ /^[[:space:]]*text[[:space:]]*:[[:space:]]*qsTr\("[^"]*"\)[[:space:]]*(\/\/.*)?$/
        }

        BEGIN {
            reset_block()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*\.)?(Label|Text)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_text = 0
                dynamic_text = 0
                constrained = 0
                has_left = 0
                has_right = 0
                wrapped = 0
                elided = 0
            }

            if (in_block) {
                if (depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:/) {
                    has_text = 1
                    if (!is_simple_static_text(line))
                        dynamic_text = 1
                }

                if (depth == 1) {
                    if (line ~ /^[[:space:]]*(Layout\.)?fillWidth[[:space:]]*:[[:space:]]*true([[:space:]]*(\/\/.*)?$)/)
                        constrained = 1
                    if (line ~ /^[[:space:]]*(width|implicitWidth|Layout\.preferredWidth|Layout\.minimumWidth|Layout\.maximumWidth|maximumWidth|minimumWidth)[[:space:]]*:/)
                        constrained = 1
                    if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                        constrained = 1
                    if (line ~ /^[[:space:]]*anchors\.left[[:space:]]*:/)
                        has_left = 1
                    if (line ~ /^[[:space:]]*anchors\.right[[:space:]]*:/)
                        has_right = 1
                    if (line ~ /wrapMode[[:space:]]*:[[:space:]]*Text\.(WordWrap|WrapAnywhere)/)
                        wrapped = 1
                    if (line ~ /elide[[:space:]]*:[[:space:]]*Text\./)
                        elided = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (has_text && dynamic_text && (constrained || (has_left && has_right)) && !wrapped && !elided)
                        printf "%s: width-constrained dynamic text lacks wrapMode or elide and can be cut off horizontally\n", start
                    reset_block()
                }
            }
        }
    ' "$file"
}

detect_unclipped_viewport_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_view() {
            in_view = 0
            depth = 0
            start = 0
            view_type = ""
            has_clip = 0
        }

        BEGIN {
            reset_view()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_view && line ~ /^[[:space:]]*(ListView|GridView|PathView|Flickable)[[:space:]]*\{/) {
                in_view = 1
                depth = 0
                start = NR
                view_type = line
                sub(/^[[:space:]]*/, "", view_type)
                sub(/[[:space:]]*\{.*/, "", view_type)
                has_clip = 0
            }

            if (in_view) {
                if (depth == 1 && line ~ /^[[:space:]]*clip[[:space:]]*:[[:space:]]*true([[:space:]]*(\/\/.*)?$)/)
                    has_clip = 1

                depth += delta
                if (depth <= 0) {
                    if (!has_clip)
                        printf "%s: %s must set clip: true so content stays inside the visible viewport\n", start, view_type
                    reset_view()
                }
            }
        }
    ' "$file"
}

detect_container_overflow_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function base_type(name,   t) {
            t = name
            sub(/^.*\./, "", t)
            return t
        }

        function is_region_host(name,   t) {
            t = base_type(name)
            return t ~ /Card$/ || t ~ /^(ListView|GridView|PathView|Flickable|ScrollView|Pane|Frame)$/
        }

        function clear_slot(i) {
            delete type[i]
            delete start[i]
            delete depth[i]
            delete neg_margin[i]
            delete neg_offset[i]
            delete oversize_width[i]
            delete oversize_height[i]
        }

        BEGIN {
            stack = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{[[:space:]]*(\/\/.*)?$/) {
                stack++
                type[stack] = line
                sub(/^[[:space:]]*/, "", type[stack])
                sub(/[[:space:]]*\{.*/, "", type[stack])
                start[stack] = NR
                depth[stack] = 0
                neg_margin[stack] = 0
                neg_offset[stack] = 0
                oversize_width[stack] = 0
                oversize_height[stack] = 0
            }

            if (stack > 0) {
                if (depth[stack] == 1) {
                    if (line ~ /^[[:space:]]*anchors\.(margins|leftMargin|rightMargin|topMargin|bottomMargin)[[:space:]]*:[[:space:]]*-[0-9]/)
                        neg_margin[stack] = 1
                    if (line ~ /^[[:space:]]*[xy][[:space:]]*:[[:space:]]*-[0-9]/)
                        neg_offset[stack] = 1
                    if (line ~ /^[[:space:]]*(width|implicitWidth|Layout\.preferredWidth|Layout\.minimumWidth|Layout\.maximumWidth)[[:space:]]*:[[:space:]]*parent\.width[[:space:]]*\+[[:space:]]*[1-9][0-9]*/)
                        oversize_width[stack] = 1
                    if (line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight|Layout\.minimumHeight|Layout\.maximumHeight)[[:space:]]*:[[:space:]]*parent\.height[[:space:]]*\+[[:space:]]*[1-9][0-9]*/)
                        oversize_height[stack] = 1
                }

                depth[stack] += delta
                while (stack > 0 && depth[stack] <= 0) {
                    closed = stack
                    parent = stack - 1

                    if (parent >= 1 && is_region_host(type[parent])) {
                        if (neg_margin[closed])
                            printf "%s: child block uses negative margins and can bleed outside its parent region\n", start[closed]
                        if (neg_offset[closed])
                            printf "%s: child block uses negative x/y offsets and can escape its parent region\n", start[closed]
                        if (oversize_width[closed])
                            printf "%s: child block widens itself beyond parent.width and can overflow horizontally\n", start[closed]
                        if (oversize_height[closed])
                            printf "%s: child block grows beyond parent.height and can overflow vertically\n", start[closed]
                    }

                    clear_slot(closed)
                    stack--
                }
            }
        }
    ' "$file"
}

detect_tight_card_padding_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function numeric_value(s,   value) {
            value = s
            sub(/.*:[[:space:]]*/, "", value)
            gsub(/[^0-9.]/, "", value)
            return value + 0
        }

        function starts_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/
        }

        function starts_card_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*Card[[:space:]]*\{/
        }

        BEGIN {
            in_card = 0
            depth = 0
            start = 0
            card_file = (FILENAME ~ /(^|\/)[^\/]*Card[^\/]*\.qml$/)
            card_file_root_seen = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card) {
                if (card_file && !card_file_root_seen && starts_object(line)) {
                    in_card = 1
                    depth = 0
                    start = NR
                    card_file_root_seen = 1
                } else if (starts_card_object(line)) {
                    in_card = 1
                    depth = 0
                    start = NR
                }
            }

            if (in_card) {
                if (depth == 1) {
                    if (line ~ /^[[:space:]]*(padding|leftPadding|rightPadding|topPadding|bottomPadding|horizontalPadding|verticalPadding)[[:space:]]*:[[:space:]]*([0-9]+|[0-9]+\.[0-9]+)([[:space:]]*(\/\/.*)?$)/) {
                        value = numeric_value(line)
                        if (value < 8)
                            printf "%s: card content inset %.3g is below the 8px minimum\n", NR, value
                    }
                    if (line ~ /^[[:space:]]*(padding|leftPadding|rightPadding|topPadding|bottomPadding|horizontalPadding|verticalPadding)[[:space:]]*:[[:space:]]*Theme\.spacingXS([^A-Za-z0-9_]|$)/)
                        printf "%s: card content inset uses Theme.spacingXS and falls below the 8px minimum\n", NR
                }

                depth += delta
                if (depth <= 0) {
                    in_card = 0
                    start = 0
                }
            }
        }
    ' "$file"
}

detect_detailed_gauge_center_text_hits() {
    local file="$1"
    {
        grep -nE 'captionText[[:space:]]*:' "$file" || true
        if [[ "$(basename "$file")" == *CircularScore*.qml ]]; then
            grep -nE 'property[[:space:]]+string[[:space:]]+captionText' "$file" || true
        fi
    } | awk '!seen[$0]++'
}

detect_live_header_sampling_contract_hits() {
    local file="$1"
    if ! grep -q 'uos-design: allow-live-header-sampling' "$file"; then
        return
    fi

    if ! grep -q 'ShaderEffectSource[[:space:]]*{' "$file"; then
        printf '1: live header sampling waiver requires a ShaderEffectSource capture stage\n'
    fi
    if ! grep -q 'MultiEffect[[:space:]]*{' "$file"; then
        printf '1: live header sampling waiver requires a MultiEffect blur stage\n'
    fi
    if ! grep -qE 'sourceItem[[:space:]]*:[[:space:]]*.*contentBase|glassSourceItem[[:space:]]*:[[:space:]]*contentBase' "$file"; then
        printf '1: live header sampling must sample the right content base, not an unrelated surface\n'
    fi
    if ! grep -q 'StyledBehindWindowBlur[[:space:]]*{' "$file"; then
        printf '1: live header sampling does not replace the structural StyledBehindWindowBlur layer\n'
    fi
}

detect_scroll_header_glass_audit_prep_hits() {
    local file="$1"

    if ! grep -q 'headerGlassProgress' "$file" || ! grep -q 'pageScrollViewport' "$file"; then
        return
    fi

    if ! grep -q 'function prepareVisualAuditSection' "$file"; then
        printf '1: scroll-driven header glass pages must expose prepareVisualAuditSection for runtime overlap validation\n'
        return
    fi

    if ! grep -q 'flick\.contentY[[:space:]]*=' "$file"; then
        printf '1: prepareVisualAuditSection must drive the main Flickable into a real header-overlap state\n'
    fi
}

detect_top_operational_banner_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_block() {
            in_block = 0
            depth = 0
            start = 0
            has_visible_gate = 0
            has_top_band_shape = 0
            has_operational_copy = 0
        }

        BEGIN {
            reset_block()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Rectangle|Item|Row|Column|RowLayout|ColumnLayout)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_visible_gate = 0
                has_top_band_shape = 0
                has_operational_copy = 0
            }

            if (in_block) {
                if (line ~ /(anchors\.top|Layout\.preferredHeight|Layout\.minimumHeight|Layout\.fillWidth[[:space:]]*:[[:space:]]*true|height[[:space:]]*:)/)
                    has_top_band_shape = 1
                if (line ~ /visible[[:space:]]*:[[:space:]].*(restrictedMode|adminMode|unlock|paywall|subscribe|service|付费|订阅|会员|权益|受限|提权)/)
                    has_visible_gate = 1
                if (line ~ /text[[:space:]]*:[[:space:]]*".*(受限模式|提权|解锁|付费|订阅|会员|权益|服务|管理员权限|完整能力|升级).*"/)
                    has_operational_copy = 1

                depth += delta
                if (depth <= 0) {
                    if (has_visible_gate && has_top_band_shape && has_operational_copy)
                        printf "%s: top-of-app operational prompt should move into the sidebar operational-card area\n", start
                    reset_block()
                }
            }
        }
    ' "$file"
}

detect_large_title_weight_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_label() {
            in_label = 0
            depth = 0
            start = 0
            is_large = 0
            is_heavy = 0
            looks_numeric = 0
        }

        BEGIN {
            reset_label()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_label && line ~ /^[[:space:]]*(D\.)?(Label|Text)[[:space:]]*\{/) {
                in_label = 1
                depth = 0
                start = NR
                is_large = 0
                is_heavy = 0
                looks_numeric = 0
            }

            if (in_label) {
                if (depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:/) {
                    if (line ~ /[%分]|MB|GB|KB|TB|Mbps|Kbps|Gbps|ms|MHz|GHz|分值|得分|[0-9]/)
                        looks_numeric = 1
                }

                if (depth == 1 && line ~ /^[[:space:]]*font\.pixelSize[[:space:]]*:/) {
                    if (line ~ /Theme\.(sectionTitleSize|titleSize|headingSize)/) {
                        is_large = 1
                    } else if (line ~ /[0-9]+/) {
                        value = line
                        sub(/.*:[[:space:]]*/, "", value)
                        gsub(/[^0-9]/, "", value)
                        if ((value + 0) > 16)
                            is_large = 1
                    }
                }

                if (depth == 1 && line ~ /^[[:space:]]*font\.bold[[:space:]]*:[[:space:]]*true/)
                    is_heavy = 1

                if (depth == 1 && line ~ /^[[:space:]]*font\.weight[[:space:]]*:/) {
                    if (line !~ /(Font\.Normal|Font\.Light|Font\.ExtraLight|Font\.Thin|400([^0-9]|$))/)
                        is_heavy = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (is_large && is_heavy && !looks_numeric)
                        printf "%s: large title label exceeds the 400-weight baseline\n", start
                    reset_label()
                }
            }
        }
    ' "$file"
}

detect_large_unit_label_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_label() {
            in_label = 0
            depth = 0
            start = 0
            is_large = 0
            has_unit = 0
        }

        BEGIN {
            reset_label()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_label && line ~ /^[[:space:]]*(D\.)?(Label|Text)[[:space:]]*\{/) {
                in_label = 1
                depth = 0
                start = NR
                is_large = 0
                has_unit = 0
            }

            if (in_label) {
                if (depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:/) {
                    expr = line
                    sub(/^[^:]*:[[:space:]]*/, "", expr)
                    if (expr ~ /^"[-+0-9.]+[[:space:]]*(%|分|MB|GB|KB|TB|Mbps|Kbps|Gbps|ms|MHz|GHz)/ \
                        || expr ~ /^(Math\.[A-Za-z0-9_.()[:space:]]+|[A-Za-z_][A-Za-z0-9_.()[:space:]]*)[[:space:]]*\+[[:space:]]*"(%|分|MB|GB|KB|TB|Mbps|Kbps|Gbps|ms|MHz|GHz)/)
                    {
                        has_unit = 1
                    }
                }

                if (depth == 1 && line ~ /^[[:space:]]*font\.pixelSize[[:space:]]*:/) {
                    if (line ~ /Theme\.(sectionTitleSize|titleSize|headingSize)/) {
                        is_large = 1
                    } else if (line ~ /[0-9]+/) {
                        value = line
                        sub(/.*:[[:space:]]*/, "", value)
                        gsub(/[^0-9]/, "", value)
                        if ((value + 0) > 16)
                            is_large = 1
                    }
                }

                depth += delta
                if (depth <= 0) {
                    if (is_large && has_unit)
                        printf "%s: large numeric label still renders units as part of one full-size text run\n", start
                    reset_label()
                }
            }
        }
    ' "$file"
}

detect_page_header_icon_hits() {
    local file="$1"
    case "$(basename "$file")" in
        PageHeader.qml)
            {
                grep -nE 'property[[:space:]]+(url|string)[[:space:]]+icon(Source|Name)' "$file" || true
                grep -nE 'SvgIcon[[:space:]]*\{' "$file" || true
            } | awk '!seen[$0]++'
            ;;
        *)
            awk '
                function brace_delta(s,   tmp, opens, closes) {
                    tmp = s
                    opens = gsub(/\{/, "{", tmp)
                    closes = gsub(/\}/, "}", tmp)
                    return opens - closes
                }

                BEGIN {
                    in_header = 0
                    depth = 0
                    start = 0
                    has_icon = 0
                }

                {
                    line = $0
                    delta = brace_delta(line)

                    if (!in_header && line ~ /^[[:space:]]*PageHeader[[:space:]]*\{/) {
                        in_header = 1
                        depth = 0
                        start = NR
                        has_icon = 0
                    }

                    if (in_header) {
                        if (depth == 1 && line ~ /^[[:space:]]*icon(Source|Name)[[:space:]]*:/)
                            has_icon = 1

                        depth += delta
                        if (depth <= 0) {
                            if (has_icon)
                                printf "%s: PageHeader still declares a leading icon\n", start
                            in_header = 0
                        }
                    }
                }
            ' "$file"
            ;;
    esac
}

detect_gradient_card_whitespace_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_card = 0
            card_depth = 0
            card_start = 0
            card_has_gradient = 0
            card_padding_zero = 0
            in_rect = 0
            rect_depth = 0
            rect_start = 0
            rect_has_gradient = 0
            rect_has_margin = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card && line ~ /^[[:space:]]*SectionCard[[:space:]]*\{/) {
                in_card = 1
                card_depth = 0
                card_start = NR
                card_has_gradient = 0
                card_padding_zero = 0
            }

            if (in_card) {
                if (card_depth == 1 && line ~ /^[[:space:]]*padding[[:space:]]*:[[:space:]]*0([[:space:]]*(\/\/.*)?$)/)
                    card_padding_zero = 1

                if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                    in_rect = 1
                    rect_depth = 0
                    rect_start = NR
                    rect_has_gradient = 0
                    rect_has_margin = 0
                }

                if (in_rect) {
                    if (line ~ /gradient[[:space:]]*:[[:space:]]*Gradient/)
                        rect_has_gradient = 1
                    if (rect_depth >= 1 && line ~ /anchors\.(margins|leftMargin|rightMargin|topMargin|bottomMargin)[[:space:]]*:[[:space:]]*[1-9][0-9]*/)
                        rect_has_margin = 1

                    rect_depth += delta
                    if (rect_depth <= 0) {
                        if (rect_has_gradient && rect_has_margin)
                            printf "%s: gradient background keeps inset margins and leaves visible whitespace around the card edge\n", rect_start
                        if (rect_has_gradient)
                            card_has_gradient = 1
                        in_rect = 0
                    }
                }

                card_depth += delta
                if (card_depth <= 0) {
                    if (card_has_gradient && !card_padding_zero)
                        printf "%s: SectionCard with a live gradient must set padding to 0\n", card_start
                    in_card = 0
                }
            }
        }
    ' "$file"
}

detect_status_duplication_hits() {
    local file="$1"
    if ! grep -q 'StatusBadge' "$file"; then
        return
    fi

    {
        grep -nE 'label[[:space:]]*:[[:space:]]*"状态"' "$file" || true
        grep -nE 'text[[:space:]]*:[[:space:]]*"当前状态[^"]*"' "$file" || true
    } | awk '!seen[$0]++'
}

detect_option_row_icon_hits() {
    local file="$1"
    case "$(basename "$file")" in
        SettingsOptionRow.qml)
            awk '
                /^[[:space:]]*property[[:space:]]+url[[:space:]]+iconSource[[:space:]]*:/ {
                    if ($0 !~ /""[[:space:]]*$/)
                        printf "%s: SettingsOptionRow must not define a non-empty default iconSource\n", NR
                }
            ' "$file"
            ;;
        *SettingsDialog.qml)
            awk '
                function brace_delta(s,   tmp, opens, closes) {
                    tmp = s
                    opens = gsub(/\{/, "{", tmp)
                    closes = gsub(/\}/, "}", tmp)
                    return opens - closes
                }

                BEGIN {
                    in_row = 0
                    depth = 0
                    start = 0
                    has_icon = 0
                }

                {
                    line = $0
                    delta = brace_delta(line)

                    if (!in_row && line ~ /^[[:space:]]*SettingsOptionRow[[:space:]]*\{/) {
                        in_row = 1
                        depth = 0
                        start = NR
                        has_icon = 0
                    }

                    if (in_row) {
                        if (depth == 1 && line ~ /^[[:space:]]*iconSource[[:space:]]*:/ && line !~ /""[[:space:]]*$/)
                            has_icon = 1

                        depth += delta
                        if (depth <= 0) {
                            if (!has_icon)
                                printf "%s: SettingsOptionRow is missing an explicit per-item iconSource\n", start
                            in_row = 0
                        }
                    }
                }
            ' "$file"
            ;;
    esac
}

detect_repeated_functional_row_icon_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_repeat = 0
            repeat_depth = 0
            repeat_has_model = 0
            in_row = 0
            row_depth = 0
            row_icon_line = ""
            in_leading = 0
            leading_depth = 0
            leading_icon_line = ""
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_repeat && line ~ /^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{/) {
                in_repeat = 1
                repeat_depth = 0
                repeat_has_model = 0
                in_row = 0
            }

            if (in_repeat) {
                if (repeat_depth == 1 && line ~ /^[[:space:]]*model[[:space:]]*:/)
                    repeat_has_model = 1

                if (!in_row && line ~ /^[[:space:]]*(SettingRow|SettingsOptionRow)[[:space:]]*\{/) {
                    in_row = 1
                    row_depth = 0
                    row_icon_line = ""
                    in_leading = 0
                    leading_depth = 0
                    leading_icon_line = ""
                }

                if (in_row) {
                    if (row_depth == 1 && line ~ /^[[:space:]]*iconSource[[:space:]]*:[[:space:]]*"qrc:[^"]+"/)
                        row_icon_line = NR ":" line

                    if (!in_leading && line ~ /^[[:space:]]*leading[[:space:]]*:[[:space:]]*Component[[:space:]]*\{/) {
                        in_leading = 1
                        leading_depth = 0
                        leading_icon_line = ""
                    }

                    if (in_leading) {
                        if (line ~ /^[[:space:]]*source[[:space:]]*:[[:space:]]*"qrc:[^"]+"/)
                            leading_icon_line = NR ":" line

                        leading_depth += delta
                        if (leading_depth <= 0)
                            in_leading = 0
                    }

                    row_depth += delta
                    if (row_depth <= 0) {
                        if (repeat_has_model && row_icon_line != "")
                            print row_icon_line " (repeated functional rows must bind icon identity from item data or a resolver, not one constant asset)"
                        if (repeat_has_model && leading_icon_line != "")
                            print leading_icon_line " (repeated functional rows must bind icon identity from item data or a resolver, not one constant asset)"
                        in_row = 0
                    }
                }

                repeat_depth += delta
                if (repeat_depth <= 0)
                    in_repeat = 0
            }
        }
    ' "$file"
}

detect_unified_toolbar_height_hits() {
    local file="$1"
    if ! grep -q 'WindowButtonGroup' "$file"; then
        return
    fi

    awk '
        /^[[:space:]]*(readonly[[:space:]]+)?property[[:space:]]+int[[:space:]]+chromeHeight[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/ {
            value = $0
            sub(/.*chromeHeight[[:space:]]*:[[:space:]]*/, "", value)
            gsub(/[^0-9]/, "", value)
            if ((value + 0) != 50)
                printf "%s: unified toolbar chromeHeight %d must be 50\n", NR, value + 0
        }
    ' "$file"

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_block = 0
            depth = 0
            start = 0
            has_window_buttons = 0
            height_value = -1
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Rectangle|Item|RowLayout|ColumnLayout)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_window_buttons = 0
                height_value = -1
            }

            if (in_block) {
                if (line ~ /WindowButtonGroup/)
                    has_window_buttons = 1

                if (depth == 1 && line ~ /^[[:space:]]*(height|implicitHeight|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/) {
                    value = line
                    sub(/.*:[[:space:]]*/, "", value)
                    gsub(/[^0-9]/, "", value)
                    height_value = value + 0
                }

                depth += delta
                if (depth <= 0) {
                    if (has_window_buttons && height_value > 0 && height_value != 50)
                        printf "%s: unified toolbar height %d must be 50\n", start, height_value
                    in_block = 0
                }
            }
        }
    ' "$file"
}

detect_unified_toolbar_divider_hits() {
    local file="$1"
    if ! grep -q 'WindowButtonGroup' "$file"; then
        return
    fi

    {
        grep -nE 'titlebarDivider' "$file" || true
        awk '
            function brace_delta(s,   tmp, opens, closes) {
                tmp = s
                opens = gsub(/\{/, "{", tmp)
                closes = gsub(/\}/, "}", tmp)
                return opens - closes
            }

            BEGIN {
                in_dialog = 0
                dialog_depth = 0
                in_rect = 0
                depth = 0
                start = 0
                has_height = 0
                has_color = 0
            }

            {
                line = $0
                delta = brace_delta(line)

                if (!in_dialog && line ~ /^[[:space:]]*D\.DialogWindow[[:space:]]*\{/) {
                    in_dialog = 1
                    dialog_depth = 0
                }

                if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                    in_rect = 1
                    depth = 0
                    start = NR
                    has_height = 0
                    has_color = 0
                }

                if (in_rect) {
                    if (depth == 1 && line ~ /^[[:space:]]*(height|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*1([[:space:]]*(\/\/.*)?$)/)
                        has_height = 1
                    if (depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:[[:space:]]*Theme\.(divider|titlebarDivider)([^A-Za-z0-9_]|$)/)
                        has_color = 1

                    depth += delta
                    if (depth <= 0) {
                        if (!in_dialog && has_height && has_color)
                            printf "%s: unified toolbar must not add an extra divider line\n", start
                        in_rect = 0
                    }
                }

                if (in_dialog) {
                    dialog_depth += delta
                    if (dialog_depth <= 0)
                        in_dialog = 0
                }
            }
        ' "$file"
    } | awk '!seen[$0]++'
}

detect_search_placeholder_inactive_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_search = 0
            depth = 0
            start = 0
            bad_placeholder = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_search && line ~ /^[[:space:]]*D\.SearchEdit[[:space:]]*\{/) {
                in_search = 1
                depth = 0
                start = NR
                bad_placeholder = 0
            }

            if (in_search) {
                if (depth == 1 && line ~ /^[[:space:]]*placeholderText[[:space:]]*:/ && line !~ /activeFocus|focus|whenActive|whenFocused|\?/) {
                    bad_placeholder = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (bad_placeholder)
                        printf "%s: SearchEdit keeps placeholder hints visible while inactive\n", start
                    in_search = 0
                }
            }
        }
    ' "$file"
}

detect_search_filter_ratio_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_block() {
            in_block = 0
            depth = 0
            block_type = ""
            block_start = 0
            search_fill = 0
            search_dominant = 0
            filter_constrained = 0
        }

        function finish_block() {
            if (block_type == "search") {
                saw_search = 1
                if (search_fill)
                    search_fill_seen = 1
                if (search_dominant)
                    search_dominant_seen = 1
            } else if (block_type == "filter") {
                saw_filter = 1
                if (filter_constrained)
                    filter_constrained_seen = 1
            }
            reset_block()
        }

        BEGIN {
            reset_block()
            saw_search = 0
            saw_filter = 0
            search_fill_seen = 0
            search_dominant_seen = 0
            filter_constrained_seen = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*D\.(SearchEdit|ComboBox)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                block_start = NR
                block_type = (line ~ /SearchEdit/) ? "search" : "filter"
                search_fill = 0
                search_dominant = 0
                filter_constrained = 0
            }

            if (in_block) {
                if (depth == 1 && block_type == "search") {
                    if (line ~ /Layout\.fillWidth[[:space:]]*:[[:space:]]*true/)
                        search_fill = 1
                    if (line ~ /Layout\.columnSpan[[:space:]]*:[[:space:]]*[2-9]/ \
                        || line ~ /Layout\.horizontalStretchFactor[[:space:]]*:[[:space:]]*[2-9]/ \
                        || line ~ /Layout\.preferredWidth[[:space:]]*:[[:space:]]*[2-9][0-9]{2,}/ \
                        || line ~ /Layout\.minimumWidth[[:space:]]*:[[:space:]]*[2-9][0-9]{2,}/)
                    {
                        search_dominant = 1
                    }
                }

                if (depth == 1 && block_type == "filter") {
                    if (line ~ /(Layout\.)?(preferredWidth|maximumWidth|minimumWidth|implicitWidth)[[:space:]]*:/)
                        filter_constrained = 1
                }

                depth += delta
                if (depth <= 0)
                    finish_block()
            }
        }

        END {
            if (saw_search && saw_filter && !(search_dominant_seen || (search_fill_seen && filter_constrained_seen))) {
                print "1: search-and-filter band does not give the search control a clearly larger share than the filters"
            }
        }
    ' "$file"
}

detect_compact_list_text_hits() {
    local file="$1"
    local scan_all=0
    case "$(basename "$file")" in
        *Row*.qml|*Item*.qml|*List*.qml|*Card*.qml)
            scan_all=1
            ;;
        *)
            if ! grep -qE '^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{|^[[:space:]]*delegate[[:space:]]*:[[:space:]].*\{' "$file"; then
                return
            fi
        ;;
    esac

    awk -v scan_all="$scan_all" '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_label() {
            in_label = 0
            depth = 0
            start = 0
            wrapped = 0
            capped = 0
        }

        BEGIN {
            reset_label()
            in_repeat = 0
            repeat_depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!scan_all && !in_repeat && line ~ /^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{/) {
                in_repeat = 1
                repeat_depth = 0
            }

            if (!scan_all && !in_repeat && line ~ /^[[:space:]]*delegate[[:space:]]*:[[:space:]].*\{/) {
                in_repeat = 1
                repeat_depth = 0
            }

            if ((scan_all || in_repeat) && !in_label && line ~ /^[[:space:]]*(D\.)?(Label|Text)[[:space:]]*\{/) {
                in_label = 1
                depth = 0
                start = NR
                wrapped = 0
                capped = 0
            }

            if (in_label) {
                if (depth == 1 && line ~ /wrapMode[[:space:]]*:[[:space:]]*Text\.(WordWrap|WrapAnywhere)/)
                    wrapped = 1
                if (depth == 1 && (line ~ /maximumLineCount[[:space:]]*:[[:space:]]*[12]/ || line ~ /elide[[:space:]]*:[[:space:]]*Text\./))
                    capped = 1

                depth += delta
                if (depth <= 0) {
                    if (wrapped && !capped)
                        printf "%s: variable-length file/app/data/reusable list text should stay on a compact 1-2 line baseline\n", start
                    reset_label()
                }
            }

            if (!scan_all && in_repeat) {
                repeat_depth += delta
                if (repeat_depth <= 0)
                    in_repeat = 0
            }
        }
    ' "$file"
}

detect_list_lane_centering_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function numeric_value(s,   value) {
            value = s
            sub(/.*:[[:space:]]*/, "", value)
            sub(/[[:space:]]*(\/\/.*)?$/, "", value)
            gsub(/[^0-9.]/, "", value)
            return value + 0
        }

        function reset_block() {
            in_block = 0
            depth = 0
            start = 0
            has_text = 0
            has_affordance = 0
            fill = 0
            center = 0
            left = 0
            right = 0
            has_left_margin = 0
            has_right_margin = 0
            has_x_num = 0
            x_num = 0
            has_x_expr = 0
            has_width_minus_const = 0
            width_minus_const = 0
            has_width_ratio = 0
            has_width_alias = 0
            has_manual_geometry = 0
        }

        BEGIN {
            reset_block()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Row|RowLayout)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
            }

            if (in_block) {
                if (line ~ /(Text|D\.Label|Label)[[:space:]]*\{/)
                    has_text = 1
                if (line ~ /(((D\.)?(Button|RecommandButton|WarningButton|ToolButton|IconButton|Switch|CheckBox|ComboBox|TextField|SearchEdit))|SvgIcon|SymbolIcon|Image)[[:space:]]*\{/)
                    has_affordance = 1

                if (depth == 1) {
                    if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/) {
                        fill = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*anchors\.horizontalCenter[[:space:]]*:/) {
                        center = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*anchors\.left[[:space:]]*:[[:space:]]*parent\.left/) {
                        left = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*anchors\.right[[:space:]]*:[[:space:]]*parent\.right/) {
                        right = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*anchors\.leftMargin[[:space:]]*:/) {
                        has_left_margin = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*anchors\.rightMargin[[:space:]]*:/) {
                        has_right_margin = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*x[[:space:]]*:[[:space:]]*[0-9.]+([[:space:]]*(\/\/.*)?$)/) {
                        has_x_num = 1
                        x_num = numeric_value(line)
                        has_manual_geometry = 1
                    } else if (line ~ /^[[:space:]]*x[[:space:]]*:/) {
                        has_x_expr = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*width[[:space:]]*:[[:space:]]*parent\.width[[:space:]]*-[[:space:]]*[0-9.]+([[:space:]]*(\/\/.*)?$)/) {
                        has_width_minus_const = 1
                        width_minus_const = numeric_value(line)
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*width[[:space:]]*:.*parent\.width[[:space:]]*\*[[:space:]]*0\.[0-9]+/) {
                        has_width_ratio = 1
                        has_manual_geometry = 1
                    }
                    if (line ~ /^[[:space:]]*width[[:space:]]*:.*(laneWidth|usableWidth|availableWidth|contentWidth|viewportWidth)/) {
                        has_width_alias = 1
                        has_manual_geometry = 1
                    }
                }

                depth += delta
                if (depth <= 0) {
                    if (has_text && (has_affordance || has_manual_geometry)) {
                        if ((has_left_margin && !has_right_margin) || (!has_left_margin && has_right_margin))
                            printf "%s: list-lane content block uses only one horizontal margin and will drift off-center inside its host\n", start
                        else if (has_x_num && has_width_minus_const && (width_minus_const < (x_num * 2 - 1) || width_minus_const > (x_num * 2 + 1)) && !center && !right)
                            printf "%s: manually placed list-lane content width does not stay horizontally centered within its host\n", start
                        else if (has_width_minus_const && !has_x_num && !center && !left && !right && !fill)
                            printf "%s: manually sized list-lane content block is not horizontally centered within its host\n", start
                        else if (has_width_ratio && !center && !left && !right && !fill)
                            printf "%s: capped-width list-lane content must be centered within the wider host lane\n", start
                        else if (has_x_expr && !center && !right && !fill && !has_width_alias && !has_left_margin && !has_right_margin)
                            printf "%s: manually offset list-lane content needs an explicit centered lane contract, not a one-sided x offset\n", start
                    }
                    reset_block()
                }
            }
        }
    ' "$file"
}

detect_root_scroll_surface_inset_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_surface() {
            in_surface = 0
            depth = 0
            start = 0
            fill = 0
            margin = 0
            manual_xy = 0
            reduced_width = 0
            reduced_height = 0
            has_scrollbar = 0
        }

        BEGIN {
            reset_surface()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_surface && line ~ /^[[:space:]]*(Flickable|ScrollView)[[:space:]]*\{/) {
                in_surface = 1
                depth = 0
                start = NR
                fill = 0
                margin = 0
                manual_xy = 0
                reduced_width = 0
                reduced_height = 0
                has_scrollbar = 0
            }

            if (in_surface) {
                if (depth == 1) {
                    if (line ~ /^[[:space:]]*anchors\.fill[[:space:]]*:[[:space:]]*parent([[:space:]]*(\/\/.*)?$)/)
                        fill = 1
                    if (line ~ /^[[:space:]]*anchors\.(margins|topMargin|rightMargin|bottomMargin|leftMargin)[[:space:]]*:/)
                        margin = 1
                    if (line ~ /^[[:space:]]*(x|y)[[:space:]]*:/)
                        manual_xy = 1
                    if (line ~ /^[[:space:]]*width[[:space:]]*:.*parent\.width[[:space:]]*([-*][[:space:]]*[0-9.]+|[[:space:]]*\/)/)
                        reduced_width = 1
                    if (line ~ /^[[:space:]]*height[[:space:]]*:.*parent\.height[[:space:]]*([-*][[:space:]]*[0-9.]+|[[:space:]]*\/)/)
                        reduced_height = 1
                    if (line ~ /^[[:space:]]*ScrollBar\.vertical[[:space:]]*:/)
                        has_scrollbar = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (has_scrollbar) {
                        if (!fill)
                            printf "%s: primary scroll surface should fill its parent content base directly\n", start
                        if (margin || manual_xy || reduced_width || reduced_height)
                            printf "%s: primary scroll surface uses outer inset geometry; keep padding inside page content instead\n", start
                    }
                    reset_surface()
                }
            }
        }
    ' "$file"
}

detect_placeholder_list_icon_hits() {
    local file="$1"
    case "$(basename "$file")" in
        AppStore.qml)
            awk '
                BEGIN { in_items = 0 }
                /property var softwareItems:[[:space:]]*\[/ { in_items = 1 }
                in_items && /\][[:space:]]*$/ { in_items = 0 }
                in_items && /iconSource[[:space:]]*:[[:space:]]*"qrc:\/qml\/assets\/icons\/(apps|package|hard-drive|file|document)\.svg"/ { print NR ":" $0 }
            ' "$file"
            ;;
        *Software*.qml|*File*.qml)
            awk '
                function brace_delta(s,   tmp, opens, closes) {
                    tmp = s
                    opens = gsub(/\{/, "{", tmp)
                    closes = gsub(/\}/, "}", tmp)
                    return opens - closes
                }

                BEGIN {
                    in_repeat = 0
                    depth = 0
                }

                {
                    line = $0
                    delta = brace_delta(line)

                    if (!in_repeat && line ~ /(Repeater|delegate)[^A-Za-z0-9_]*\{/) {
                        in_repeat = 1
                        depth = 0
                    }

                    if (in_repeat) {
                        if (line ~ /(iconSource|source)[[:space:]]*:[[:space:]]*"qrc:\/qml\/assets\/icons\/(apps|package|hard-drive|file|document)\.svg"/)
                            print NR ":" line

                        depth += delta
                        if (depth <= 0)
                            in_repeat = 0
                    }
                }
            ' "$file"
            ;;
    esac
}

detect_shared_functional_model_icon_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function extract_string(s,   value) {
            value = s
            sub(/^[^"]*"/, "", value)
            sub(/".*$/, "", value)
            return value
        }

        function flush_element() {
            if (elem_has_description && elem_icon != "" && elem_id != "") {
                if (!(elem_icon in seen_icon_id)) {
                    seen_icon_id[elem_icon] = elem_id
                } else if (seen_icon_id[elem_icon] != elem_id) {
                    printf "%s: distinct functional list items reuse bundled icon %s; keep per-item icon identity\n", elem_icon_line, elem_icon
                }
            }

            in_element = 0
            element_depth = 0
            elem_id = ""
            elem_icon = ""
            elem_icon_line = 0
            elem_has_description = 0
        }

        BEGIN {
            in_model = 0
            model_depth = 0
            in_element = 0
            element_depth = 0
            elem_id = ""
            elem_icon = ""
            elem_icon_line = 0
            elem_has_description = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_model && line ~ /^[[:space:]]*ListModel[[:space:]]*\{/) {
                in_model = 1
                model_depth = 0
                delete seen_icon_id
                in_element = 0
            }

            if (in_model) {
                if (!in_element && line ~ /^[[:space:]]*ListElement[[:space:]]*\{/) {
                    in_element = 1
                    element_depth = 0
                    elem_id = ""
                    elem_icon = ""
                    elem_icon_line = 0
                    elem_has_description = 0
                }

                if (in_element) {
                    if (element_depth == 1 && elem_id == "" && line ~ /^[[:space:]]*key[[:space:]]*:[[:space:]]*"/)
                        elem_id = extract_string(line)
                    if (element_depth == 1 && elem_id == "" && line ~ /^[[:space:]]*title[[:space:]]*:[[:space:]]*"/)
                        elem_id = extract_string(line)
                    if (element_depth == 1 && line ~ /^[[:space:]]*description[[:space:]]*:[[:space:]]*"/)
                        elem_has_description = 1
                    if (element_depth == 1 && line ~ /^[[:space:]]*iconSource[[:space:]]*:[[:space:]]*"qrc:[^"]+"/) {
                        elem_icon = extract_string(line)
                        elem_icon_line = NR
                    }

                    element_depth += delta
                    if (element_depth <= 0)
                        flush_element()
                }

                model_depth += delta
                if (model_depth <= 0)
                    in_model = 0
            }
        }
    ' "$file"
}

detect_list_height_cap_hits() {
    local file="$1"
    grep -nE '(height|Layout\.preferredHeight)[[:space:]]*:[[:space:]]*Math\.min\(contentHeight[[:space:]]*,' "$file" || true
}

detect_chart_missing_axes_hits() {
    local file="$1"
    if [[ "$(basename "$file")" == *Chart*.qml ]] || ( grep -q 'Canvas' "$file" && grep -qE 'cpuSeries|memorySeries|drawSeries|chart' "$file" ); then
        if ! grep -qE 'xLabels|yTicks|axis|tick|刻度|seconds|timeLabels|usageLabel' "$file"; then
            printf '1: chart surface lacks explicit axis labels or tick metadata\n'
        fi
    fi
}

detect_chart_missing_animation_hits() {
    local file="$1"
    if [[ "$(basename "$file")" == *Chart*.qml ]] || ( grep -q 'Canvas' "$file" && grep -qE 'cpuSeries|memorySeries|drawSeries|chart' "$file" ); then
        if ! grep -qE 'Behavior on|NumberAnimation|SmoothedAnimation|SequentialAnimation|ParallelAnimation|revealProgress|animated' "$file"; then
            printf '1: chart surface lacks animated data transitions\n'
        fi
    fi
}

detect_chart_curve_style_hits() {
    local file="$1"
    if [[ "$(basename "$file")" == *Chart*.qml ]] || ( grep -q 'Canvas' "$file" && grep -qE 'cpuSeries|memorySeries|drawSeries|chart' "$file" ); then
        if grep -qE 'drawSeries|ctx\.lineTo|lineTo\(' "$file"; then
            if ! grep -q 'createLinearGradient' "$file"; then
                printf '1: chart curve lacks a top-to-bottom gradient treatment\n'
            fi

            if ! grep -qE 'ctx\.shadowColor|shadowColor|ctx\.shadowBlur|shadowBlur' "$file"; then
                printf '1: chart curve lacks a same-color shadow treatment\n'
            fi

            if ! grep -qE 'Qt\.rgba\(tone\.r|tone\.r,[[:space:]]*tone\.g,[[:space:]]*tone\.b|function[[:space:]]+toneWithAlpha' "$file"; then
                printf '1: chart curve styling does not appear to derive gradient and shadow from the line color\n'
            fi
        fi
    fi
}

detect_progress_shadow_hits() {
    local file="$1"
    local base
    local has_custom_progress=0
    base="$(basename "$file")"

    if [[ "$base" != *Progress*.qml ]] \
        && [[ "$base" != *Score*.qml ]] \
        && [[ "$base" != *Gauge*.qml ]] \
        && ! grep -qE 'CircularProgress|LinearProgress|RingProgress|ProgressRing|ProgressArc|CircularScore|ringCanvas|gauge' "$file"
    then
        return
    fi

    if grep -qE 'Canvas|Shape|ShapePath|ctx\.arc|ctx\.lineTo' "$file"; then
        has_custom_progress=1
    elif [[ "$base" == *Progress*.qml ]] \
        && grep -q 'Rectangle[[:space:]]*{' "$file" \
        && grep -qE 'property[[:space:]]+(real|int)[[:space:]]+(value|progress)' "$file"
    then
        has_custom_progress=1
    fi

    if (( ! has_custom_progress )); then
        return
    fi

    if grep -qE '(^|[[:space:]])D\.ProgressBar([[:space:]]|\{)' "$file" \
        && ! grep -qE 'Canvas|Shape|ShapePath|ctx\.arc|ctx\.lineTo|layer\.effect|DropShadow|MultiEffect' "$file"
    then
        return
    fi

    if ! grep -qE 'drawSeries|cpuSeries|memorySeries|xLabels|yTicks|chartCanvas' "$file" \
        && ! grep -qE 'DropShadow|MultiEffect|layer\.effect|ctx\.shadowColor|shadowColor|shadow\.color|foregroundShadow' "$file"
    then
        printf '1: custom progress foreground lacks a same-color shadow treatment\n'
    fi
}

detect_ring_progress_style_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    if [[ "$base" != *Progress*.qml ]] \
        && [[ "$base" != *Score*.qml ]] \
        && [[ "$base" != *Gauge*.qml ]] \
        && ! grep -qE 'CircularScore|RingProgress|ProgressRing|ProgressArc|ctx\.arc|gauge' "$file"
    then
        return
    fi

    if ! grep -qE 'ctx\.arc|ShapePath' "$file"; then
        return
    fi

    if grep -q 'showCenterText' "$file"; then
        if grep -q 'ctx\.lineWidth[[:space:]]*=[[:space:]]*root\.lineWidth' "$file"; then
            printf '1: ring progress does not hard-cap no-text stroke thickness before painting\n'
        elif ! grep -qE 'effectiveLineWidth|Math\.min\([^)]*20' "$file"; then
            printf '1: ring progress is missing an explicit no-text 20px stroke cap\n'
        fi
    fi

    if ! grep -qE 'safeStrokeInset|shadowInset|clipMargin' "$file" \
        || ! grep -qE 'radius[[:space:]]*=.*(safeStrokeInset|shadowInset|clipMargin)' "$file"
    then
        printf '1: ring progress shadow may clip because no safe inset is reserved in the radius calculation\n'
    fi

    if grep -qE 'foregroundShadowColor.*0\.(2[0-9]|[3-9][0-9])|shadowColor[[:space:]]*=.*0\.(2[0-9]|[3-9][0-9])' "$file"; then
        printf '1: ring progress shadow is heavier than the light-shadow baseline\n'
    fi
}

detect_custom_main_menu_icon_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_button = 0
            depth = 0
            start = 0
            is_main_menu = 0
            has_custom_icon = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_button && line ~ /^[[:space:]]*((D\.)?(ToolButton|Button)|QQC\.Button)[[:space:]]*\{/) {
                in_button = 1
                depth = 0
                start = NR
                is_main_menu = 0
                has_custom_icon = 0
            }

            if (in_button) {
                if (depth == 1 && (line ~ /id[[:space:]]*:[[:space:]]*mainMenuButton/ || line ~ /text[[:space:]]*:[[:space:]]*"主菜单"/))
                    is_main_menu = 1
                if (depth == 1 && (line ~ /icon\.source[[:space:]]*:/ || line ~ /SvgIcon[[:space:]]*\{/))
                    has_custom_icon = 1

                depth += delta
                if (depth <= 0) {
                    if (is_main_menu && has_custom_icon)
                        printf "%s: main-menu trigger still uses a custom project icon path or custom icon item\n", start
                    in_button = 0
                }
            }
        }
    ' "$file"
}

detect_main_menu_without_titlebar_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE '(^|[[:space:]])D\.TitleBar([[:space:]]|\{)' "$file"; then
        if grep -qE 'ThemeMenu|AboutAction|HelpAction|QuitAction|text[[:space:]]*:[[:space:]]*"(设置|关于|退出|主菜单|更多|跟随系统主题|浅色模式|深色模式)"' "$file"; then
            printf '1: application main menu exists but the window does not use D.TitleBar.menu\n'
        fi
        return
    fi

    if ! grep -qE 'D\.TitleBar[[:space:]]*\{[[:space:][:print:]]*menu[[:space:]]*:' "$file" \
        && ! grep -qE '^[[:space:]]*menu[[:space:]]*:' "$file"
    then
        if grep -qE 'ThemeMenu|AboutAction|HelpAction|QuitAction|text[[:space:]]*:[[:space:]]*"(设置|关于|退出|主菜单|更多|跟随系统主题|浅色模式|深色模式)"' "$file"; then
            printf '1: application main menu exists but is not attached through D.TitleBar.menu\n'
        fi
    fi
}

detect_titlebar_menu_attachment_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_titlebar = 0
            depth = 0
            start = 0
            has_menu_property = 0
            has_menu_content = 0
            has_custom_trigger = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                depth = 0
                start = NR
                has_menu_property = 0
                has_menu_content = 0
                has_custom_trigger = 0
            }

            if (in_titlebar) {
                if (depth == 1 && line ~ /^[[:space:]]*menu[[:space:]]*:/)
                    has_menu_property = 1
                if (line ~ /D\.(ThemeMenu|AboutAction|HelpAction|QuitAction)[[:space:]]*\{/ \
                    || line ~ /text[[:space:]]*:[[:space:]]*"(设置|关于|退出|主菜单|更多)"/)
                    has_menu_content = 1
                if (line ~ /id[[:space:]]*:[[:space:]]*mainMenuButton/ \
                    || line ~ /text[[:space:]]*:[[:space:]]*"(主菜单|更多)"/ \
                    || line ~ /icon\.(name|source)[[:space:]]*:[[:space:]]*".*(open-menu|menu|hamburger).*"/)
                    has_custom_trigger = 1

                depth += delta
                if (depth <= 0) {
                    if ((has_menu_content || has_custom_trigger) && !has_menu_property)
                        printf "%s: D.TitleBar path exposes an application main menu but does not attach it through TitleBar.menu\n", start
                    in_titlebar = 0
                }
            }
        }
    ' "$file"
}

detect_full_width_titlebar_sidebar_hits() {
    :
}

detect_titlebar_custom_main_menu_trigger_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_button() {
            in_button = 0
            button_depth = 0
            button_start = 0
            button_is_menu = 0
            button_opens_menu = 0
        }

        BEGIN {
            in_titlebar = 0
            titlebar_depth = 0
            reset_button()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                titlebar_depth = 0
                reset_button()
            }

            if (in_titlebar) {
                if (!in_button && line ~ /^[[:space:]]*((D\.)?(ToolButton|ActionButton|Button)|QQC\.Button)[[:space:]]*\{/) {
                    in_button = 1
                    button_depth = 0
                    button_start = NR
                    button_is_menu = 0
                    button_opens_menu = 0
                }

                if (in_button) {
                    if (button_depth == 1 && (line ~ /id[[:space:]]*:[[:space:]]*mainMenuButton/ \
                        || line ~ /text[[:space:]]*:[[:space:]]*"(主菜单|更多)"/ \
                        || line ~ /icon\.(name|source)[[:space:]]*:[[:space:]]*".*(open-menu|menu|hamburger).*"/))
                    {
                        button_is_menu = 1
                    }

                    if (line ~ /onClicked[[:space:]]*:[[:space:]].*\.(open|popup)\(/)
                        button_opens_menu = 1

                    button_depth += delta
                    if (button_depth <= 0) {
                        if (button_is_menu && button_opens_menu)
                            printf "%s: D.TitleBar-based window still draws a separate main-menu trigger and opens the menu manually\n", button_start
                        reset_button()
                    }
                }

                titlebar_depth += delta
                if (titlebar_depth <= 0) {
                    in_titlebar = 0
                    reset_button()
                }
            }
        }
    ' "$file"
}

detect_non_dtk_dialog_hits() {
    local file="$1"
    grep -nE '^[[:space:]]*(QQC\.)?Dialog[[:space:]]*\{' "$file" || true
}

detect_popup_style_dtk_dialog_hits() {
    local file="$1"
    grep -nE '^[[:space:]]*D\.Dialog[[:space:]]*\{' "$file" || true
}

detect_manual_dialog_action_row_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_row() {
            in_row = 0
            row_depth = 0
            row_start = 0
            row_button_count = 0
            row_inside_button_box = 0
        }

        BEGIN {
            in_dialog = 0
            dialog_depth = 0
            in_button_box = 0
            button_box_depth = 0
            reset_row()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_dialog && line ~ /^[[:space:]]*D\.(Dialog|DialogWindow)[[:space:]]*\{/) {
                in_dialog = 1
                dialog_depth = 0
                in_button_box = 0
                button_box_depth = 0
                reset_row()
            }

            if (in_dialog) {
                if (!in_button_box && line ~ /^[[:space:]]*D\.DialogButtonBox[[:space:]]*\{/) {
                    in_button_box = 1
                    button_box_depth = 0
                }

                if (!in_row && line ~ /^[[:space:]]*(Row|RowLayout|Flow)[[:space:]]*\{/) {
                    in_row = 1
                    row_depth = 0
                    row_start = NR
                    row_button_count = 0
                    row_inside_button_box = in_button_box
                }

                if (in_row && line ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton|ToolButton|RoundButton|DelayButton)|QQC2?\.Button|Button)[[:space:]]*\{/)
                    row_button_count++

                if (in_row) {
                    row_depth += delta
                    if (row_depth <= 0) {
                        if (row_button_count > 0 && !row_inside_button_box)
                            printf "%s: DTK dialog hand-builds a button row in its body; use D.DialogButtonBox as the dialog action owner instead\n", row_start
                        reset_row()
                    }
                }

                if (in_button_box) {
                    button_box_depth += delta
                    if (button_box_depth <= 0) {
                        in_button_box = 0
                        button_box_depth = 0
                    }
                }

                dialog_depth += delta
                if (dialog_depth <= 0) {
                    in_dialog = 0
                    in_button_box = 0
                    button_box_depth = 0
                    reset_row()
                }
            }
        }
    ' "$file"
}

detect_standard_dialog_footer_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function is_footer_start(s) {
            return s ~ /^[[:space:]]*(DialogActionFooter|D\.DialogButtonBox)[[:space:]]*\{/
        }

        function is_button_start(s) {
            return s ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton)|QQC2?\.Button|Button)[[:space:]]*\{/
        }

        function reset_footer() {
            in_footer = 0
            footer_depth = 0
            footer_start = 0
            footer_button_count = 0
            footer_fill_width_count = 0
            footer_preferred_width_count = 0
            footer_preferred_width_value = ""
            footer_preferred_width_mismatch = 0
            footer_margin_line = 0
        }

        function reset_button() {
            in_button = 0
            button_depth = 0
            button_fill_width = 0
            button_preferred_width = ""
        }

        BEGIN {
            in_dialog = 0
            dialog_depth = 0
            reset_footer()
            reset_button()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_dialog && line ~ /^[[:space:]]*D\.(Dialog|DialogWindow)[[:space:]]*\{/) {
                in_dialog = 1
                dialog_depth = 0
                reset_footer()
                reset_button()
            }

            if (in_dialog) {
                if (!in_footer && is_footer_start(line)) {
                    in_footer = 1
                    footer_depth = 0
                    footer_start = NR
                    footer_margin_line = 0
                }

                if (in_footer && !footer_margin_line && footer_depth == 1 &&
                    line ~ /^[[:space:]]*Layout\.(topMargin|bottomMargin)[[:space:]]*:[[:space:]]*([1-9][0-9]*|[0-9]*\.[0-9]*[1-9][0-9]*)[[:space:]]*$/) {
                    footer_margin_line = NR
                }

                if (in_footer && !in_button && is_button_start(line)) {
                    in_button = 1
                    button_depth = 0
                    button_fill_width = 0
                    button_preferred_width = ""
                }

                if (in_button) {
                    if (button_depth == 1 && line ~ /^[[:space:]]*(Layout\.fillWidth|fillWidth)[[:space:]]*:[[:space:]]*true([[:space:]]*(\/\/.*)?)?$/)
                        button_fill_width = 1

                    if (button_depth == 1 && line ~ /^[[:space:]]*Layout\.preferredWidth[[:space:]]*:/) {
                        value = line
                        sub(/.*Layout\.preferredWidth[[:space:]]*:[[:space:]]*/, "", value)
                        sub(/[[:space:]]*(\/\/.*)?$/, "", value)
                        button_preferred_width = value
                    }

                    button_depth += delta
                    if (button_depth <= 0) {
                        footer_button_count++
                        if (button_fill_width)
                            footer_fill_width_count++
                        if (button_preferred_width != "") {
                            footer_preferred_width_count++
                            if (footer_preferred_width_value == "")
                                footer_preferred_width_value = button_preferred_width
                            else if (footer_preferred_width_value != button_preferred_width)
                                footer_preferred_width_mismatch = 1
                        }
                        reset_button()
                    }
                }

                if (in_footer) {
                    footer_depth += delta
                    if (footer_depth <= 0) {
                        if (footer_button_count >= 2 && footer_fill_width_count < footer_button_count) {
                            printf "%s: DTK dialog footer with multiple actions must set Layout.fillWidth on every action button so the row uses the full footer width\n", footer_start
                        }
                        if (footer_button_count >= 2 && (footer_preferred_width_count < footer_button_count || footer_preferred_width_mismatch)) {
                            printf "%s: DTK dialog footer with multiple actions must give every action button the same Layout.preferredWidth so widths split evenly\n", footer_start
                        }
                        if (footer_margin_line > 0) {
                            printf "%s: DTK dialog footer must not keep page-style top or bottom margins around the action row\n", footer_margin_line
                        }
                        reset_footer()
                        reset_button()
                    }
                }

                dialog_depth += delta
                if (dialog_depth <= 0) {
                    in_dialog = 0
                    reset_footer()
                    reset_button()
                }
            }
        }
    ' "$file"
}

detect_vertical_action_stack_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function is_context_start(s) {
            return s ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_.]*Card|D\.(Dialog|DialogWindow)|(Settings\.)?SettingsDialog)[[:space:]]*\{/
        }

        function is_action_block_start(s) {
            return s ~ /^[[:space:]]*(Flow|Column|ColumnLayout)[[:space:]]*\{/
        }

        function is_button_decl(s) {
            return s ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/
        }

        function push_context(level) {
            context_top++
            context_level[context_top] = level
        }

        function pop_context() {
            delete context_level[context_top]
            context_top--
        }

        function push_action(kind, level, start_line) {
            action_top++
            action_kind[action_top] = kind
            action_level[action_top] = level
            action_start[action_top] = start_line
            action_button_count[action_top] = 0
            action_top_to_bottom[action_top] = 0
        }

        function pop_action(    kind, start_line, button_count, top_to_bottom) {
            kind = action_kind[action_top]
            start_line = action_start[action_top]
            button_count = action_button_count[action_top]
            top_to_bottom = action_top_to_bottom[action_top]

            if (kind == "Flow" && button_count > 1) {
                if (top_to_bottom) {
                    printf "%s: action buttons inside a normal card or dialog must stay horizontal-first; do not switch to Flow.TopToBottom by default\n", start_line
                } else {
                    printf "%s: normal card or dialog action rows must not use Flow for multiple buttons because wrapping can degrade into one button per line\n", start_line
                }
            } else if ((kind == "Column" || kind == "ColumnLayout") && button_count > 1) {
                printf "%s: multiple action buttons inside a normal card or dialog are stacked vertically; keep them on one horizontal row by default\n", start_line
            }

            delete action_kind[action_top]
            delete action_level[action_top]
            delete action_start[action_top]
            delete action_button_count[action_top]
            delete action_top_to_bottom[action_top]
            action_top--
        }

        BEGIN {
            nest = 0
            context_top = 0
            action_top = 0
        }

        {
            line = $0
            delta = brace_delta(line)
            next_nest = nest + delta

            if (context_top > 0) {
                for (i = 1; i <= action_top; i++) {
                    if (nest == action_level[i] && is_button_decl(line))
                        action_button_count[i]++
                    if (nest == action_level[i] && action_kind[i] == "Flow" && line ~ /flow[[:space:]]*:[[:space:]].*Flow\.TopToBottom/)
                        action_top_to_bottom[i] = 1
                }
            }

            if (is_context_start(line))
                push_context(next_nest)

            if (context_top > 0 && is_action_block_start(line)) {
                kind = "Column"
                if (line ~ /^[[:space:]]*Flow[[:space:]]*\{/)
                    kind = "Flow"
                else if (line ~ /^[[:space:]]*ColumnLayout[[:space:]]*\{/)
                    kind = "ColumnLayout"
                push_action(kind, next_nest, NR)
            }

            nest = next_nest

            while (action_top > 0 && nest < action_level[action_top])
                pop_action()

            while (context_top > 0 && nest < context_level[context_top])
                pop_context()
        }

        END {
            while (action_top > 0)
                pop_action()
        }
    ' "$file"
}

detect_mutually_exclusive_button_group_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function is_group_start(s) {
            return s ~ /^[[:space:]]*(D\.)?(ButtonBox|ButtonGroup|ControlGroup)[[:space:]]*\{/
        }

        function group_kind(line) {
            if (line ~ /^[[:space:]]*(D\.)?ButtonBox[[:space:]]*\{/)
                return "ButtonBox"
            if (line ~ /^[[:space:]]*(D\.)?ButtonGroup[[:space:]]*\{/)
                return "ButtonGroup"
            return "ControlGroup"
        }

        function is_container_start(s) {
            return s ~ /^[[:space:]]*(Flow|Row|RowLayout|Column|ColumnLayout)[[:space:]]*\{/
        }

        function is_button_start(s) {
            return s ~ /^[[:space:]]*((D\.)?(ToolButton|Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/
        }

        function container_kind(line) {
            if (line ~ /^[[:space:]]*Flow[[:space:]]*\{/)
                return "Flow"
            if (line ~ /^[[:space:]]*RowLayout[[:space:]]*\{/)
                return "RowLayout"
            if (line ~ /^[[:space:]]*Row[[:space:]]*\{/)
                return "Row"
            if (line ~ /^[[:space:]]*ColumnLayout[[:space:]]*\{/)
                return "ColumnLayout"
            return "Column"
        }

        function extract_compare_prop(line,   tmp, start, i, c, ch, prop) {
            tmp = line
            sub(/^[^:]*:[[:space:]]*/, "", tmp)
            if (match(tmp, /===?/)) {
                start = RSTART - 1
                while (start > 0 && substr(tmp, start, 1) ~ /[[:space:]]/)
                    start--
                if (start <= 0)
                    return ""
                i = start
                while (i > 0) {
                    ch = substr(tmp, i, 1)
                    if (ch ~ /[A-Za-z0-9_.]/)
                        i--
                    else
                        break
                }
                prop = substr(tmp, i + 1, start - i)
                if (prop ~ /^[A-Za-z_][A-Za-z0-9_.]*$/)
                    return prop
            }
            return ""
        }

        function extract_assign_prop(line,   tmp, start, i, ch, prop) {
            tmp = line
            gsub(/===/, "", tmp)
            gsub(/==/, "", tmp)
            if (match(tmp, /=[[:space:]]*[^=]/)) {
                start = RSTART - 1
                while (start > 0 && substr(tmp, start, 1) ~ /[[:space:]]/)
                    start--
                if (start <= 0)
                    return ""
                i = start
                while (i > 0) {
                    ch = substr(tmp, i, 1)
                    if (ch ~ /[A-Za-z0-9_.]/)
                        i--
                    else
                        break
                }
                prop = substr(tmp, i + 1, start - i)
                if (prop ~ /^[A-Za-z_][A-Za-z0-9_.]*$/)
                    return prop
            }
            return ""
        }

        function extract_identifier_value(line,   tmp) {
            tmp = line
            sub(/^[^:]*:[[:space:]]*/, "", tmp)
            sub(/[[:space:]]*\/\/.*$/, "", tmp)
            gsub(/[[:space:]]/, "", tmp)
            if (tmp ~ /^[A-Za-z_][A-Za-z0-9_.]*$/)
                return tmp
            return ""
        }

        function extract_numeric_literal(line,   tmp) {
            tmp = line
            sub(/^[^:]*:[[:space:]]*/, "", tmp)
            sub(/[[:space:]]*\/\/.*$/, "", tmp)
            if (match(tmp, /^-?[0-9]+(\.[0-9]+)?/))
                return substr(tmp, RSTART, RLENGTH) + 0
            return ""
        }

        function push_group(kind, level, start_line) {
            group_top++
            group_kind_stack[group_top] = kind
            group_level[group_top] = level
            group_start[group_top] = start_line
            group_spacing[group_top] = ""
        }

        function pop_group() {
            if (group_spacing[group_top] != "" && group_spacing[group_top] > 10) {
                printf "%s: mutually exclusive button groups must keep adjacent button spacing at 10px or less\n", group_start[group_top]
            }
            delete group_kind_stack[group_top]
            delete group_level[group_top]
            delete group_start[group_top]
            delete group_spacing[group_top]
            group_top--
        }

        function push_container(kind, level, start_line) {
            container_top++
            container_kind_stack[container_top] = kind
            container_level[container_top] = level
            container_start[container_top] = start_line
            container_spacing[container_top] = ""
        }

        function pop_container(   kind, start_line, key, parts, idx, count, best_count) {
            kind = container_kind_stack[container_top]
            start_line = container_start[container_top]
            best_count = 0

            for (key in container_prop_count) {
                split(key, parts, SUBSEP)
                idx = parts[1] + 0
                if (idx != container_top)
                    continue
                count = container_prop_count[key]
                if (count > best_count)
                    best_count = count
            }

            if (best_count >= 2) {
                if (container_spacing[container_top] != "" && container_spacing[container_top] > 10) {
                    printf "%s: mutually exclusive buttons must keep adjacent button spacing at 10px or less\n", start_line
                }
                if (kind == "Flow") {
                    printf "%s: mutually exclusive buttons must use a DTK grouped-button control and stay on one row; do not place them in Flow\n", start_line
                } else if (kind == "Column" || kind == "ColumnLayout") {
                    printf "%s: mutually exclusive buttons must use a DTK grouped-button control and remain on one horizontal row; do not stack them vertically\n", start_line
                } else {
                    printf "%s: mutually exclusive buttons are implemented as standalone buttons; prefer D.ButtonBox / D.ButtonGroup / D.ControlGroup\n", start_line
                }
            }

            for (key in container_prop_count) {
                split(key, parts, SUBSEP)
                idx = parts[1] + 0
                if (idx == container_top)
                    delete container_prop_count[key]
            }

            delete container_kind_stack[container_top]
            delete container_level[container_top]
            delete container_start[container_top]
            delete container_spacing[container_top]
            container_top--
        }

        function reset_button() {
            in_button = 0
            button_depth = 0
            button_container = 0
            button_checked_prop = ""
            button_assign_prop = ""
            button_group_ref = ""
            button_checkable = 0
        }

        BEGIN {
            nest = 0
            group_top = 0
            container_top = 0
            reset_button()
        }

        {
            line = $0
            delta = brace_delta(line)
            next_nest = nest + delta

            if (group_top == 0 && is_container_start(line))
                push_container(container_kind(line), next_nest, NR)

            if (is_group_start(line))
                push_group(group_kind(line), next_nest, NR)

            if (group_top > 0 && nest == group_level[group_top] && line ~ /^[[:space:]]*spacing[[:space:]]*:/) {
                spacing_value = extract_numeric_literal(line)
                if (spacing_value != "")
                    group_spacing[group_top] = spacing_value
            }

            if (group_top == 0 && container_top > 0 && nest == container_level[container_top] && line ~ /^[[:space:]]*spacing[[:space:]]*:/) {
                spacing_value = extract_numeric_literal(line)
                if (spacing_value != "")
                    container_spacing[container_top] = spacing_value
            }

            if (group_top == 0 && container_top > 0 && !in_button && is_button_start(line)) {
                in_button = 1
                button_depth = 0
                button_container = container_top
                button_checked_prop = ""
                button_assign_prop = ""
                button_group_ref = ""
                button_checkable = 0
            }

            if (in_button) {
                if (button_depth == 1 && line ~ /^[[:space:]]*checked[[:space:]]*:/)
                    button_checked_prop = extract_compare_prop(line)
                if (button_depth == 1 && line ~ /^[[:space:]]*checkable[[:space:]]*:[[:space:]]*true([[:space:]]*(\/\/.*)?$)/)
                    button_checkable = 1
                if (button_depth == 1 && line ~ /ButtonGroup\.group[[:space:]]*:/)
                    button_group_ref = extract_identifier_value(line)
                if (line ~ /onClicked[[:space:]]*:/ && button_assign_prop == "")
                    button_assign_prop = extract_assign_prop(line)

                button_depth += delta
                if (button_depth <= 0) {
                    prop = ""
                    if (button_group_ref != "")
                        prop = "__group__" button_group_ref
                    else {
                        prop = button_checked_prop
                        if (prop == "" && button_checkable)
                            prop = button_assign_prop
                    }
                    if (prop != "")
                        container_prop_count[button_container, prop]++
                    reset_button()
                }
            }

            nest = next_nest

            while (group_top > 0 && nest < group_level[group_top])
                pop_group()

            while (container_top > 0 && nest < container_level[container_top])
                pop_container()
        }

        END {
            while (container_top > 0)
                pop_container()
        }
    ' "$file"
}

detect_buttonbox_external_group_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_button_box = 0
            box_depth = 0
            in_button = 0
            button_depth = 0
            button_start = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_button_box && line ~ /^[[:space:]]*D\.ButtonBox[[:space:]]*\{/) {
                in_button_box = 1
                box_depth = 0
                in_button = 0
                button_depth = 0
                button_start = 0
            } else if (in_button_box && !in_button && line ~ /^[[:space:]]*((D\.)?(ToolButton|Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/) {
                in_button = 1
                button_depth = 0
                button_start = NR
            }

            if (in_button) {
                if (line ~ /ButtonGroup\.group[[:space:]]*:/) {
                    printf "%s: D.ButtonBox child buttons must use the box\\047s built-in group; do not bind them into a second external ButtonGroup\n", button_start
                }

                button_depth += delta
                if (button_depth <= 0) {
                    in_button = 0
                    button_depth = 0
                    button_start = 0
                }
            }

            if (in_button_box) {
                box_depth += delta
                if (box_depth <= 0) {
                    in_button_box = 0
                    box_depth = 0
                    in_button = 0
                    button_depth = 0
                    button_start = 0
                }
            }
        }
    ' "$file"
}

detect_custom_dialog_content_style_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_label() {
            in_label = 0
            label_depth = 0
            label_start = 0
            label_center = 0
            label_large = 0
            label_weight = 0
            label_custom_text_color = 0
        }

        BEGIN {
            in_dialog = 0
            dialog_depth = 0
            reset_label()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_dialog && line ~ /^[[:space:]]*D\.(Dialog|DialogWindow)[[:space:]]*\{/) {
                in_dialog = 1
                dialog_depth = 0
                reset_label()
            }

            if (in_dialog) {
                if (dialog_depth == 1 && line ~ /^[[:space:]]*(background|header|footer|contentItem|overlay)[[:space:]]*:/)
                    printf "%s: DTK dialog overrides structural dialog chrome instead of keeping the standard DTK body\n", NR

                if (dialog_depth >= 1 && line ~ /(SectionCard|MetricCard|StatusBadge|MetricValueLabel|CircularScore|PerformanceChart|PageHeader|AppItemIcon|SvgIcon)[[:space:]]*\{/)
                    printf "%s: DTK dialog embeds a page-style widget and no longer reads like a standard DTK dialog\n", NR

                if (!in_label && line ~ /^[[:space:]]*((D|QQC2|QQC)\.)?(Label|Text)[[:space:]]*\{/) {
                    in_label = 1
                    label_depth = 0
                    label_start = NR
                    label_center = 0
                    label_large = 0
                    label_weight = 0
                    label_custom_text_color = 0
                }

                if (in_label) {
                    if (label_depth == 1 && line ~ /^[[:space:]]*horizontalAlignment[[:space:]]*:[[:space:]]*Text\.Align(HCenter|Right)/)
                        label_center = 1
                    if (label_depth == 1 && (line ~ /^[[:space:]]*font\.pixelSize[[:space:]]*:[[:space:]]*Theme\.(sectionTitleSize|titleSize)/ \
                        || line ~ /^[[:space:]]*font\.pixelSize[[:space:]]*:[[:space:]]*1[7-9]([[:space:]]*(\/\/.*)?$)/ \
                        || line ~ /^[[:space:]]*font\.pixelSize[[:space:]]*:[[:space:]]*[2-9][0-9]([[:space:]]*(\/\/.*)?$)/))
                        label_large = 1
                    if (label_depth == 1 && line ~ /^[[:space:]]*font\.(weight|bold)[[:space:]]*:/)
                        label_weight = 1
                    if (label_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:[[:space:]]*Theme\.(textPrimary|textSecondary|textStrong|textMuted|inverseText|fgNormal|fgStrong|iconNormal|iconStrong|accentForeground)([^A-Za-z0-9_]|$)/)
                        label_custom_text_color = 1

                    label_depth += delta
                    if (label_depth <= 0) {
                        if (label_center)
                            printf "%s: DTK dialog body label is center/right aligned; keep standard DTK dialog text alignment\n", label_start
                        if (label_large)
                            printf "%s: DTK dialog body adds an oversized secondary heading instead of relying on the dialog title\n", label_start
                        if (label_weight && label_large)
                            printf "%s: DTK dialog body emphasizes a secondary heading with custom weight\n", label_start
                        if (label_custom_text_color)
                            printf "%s: DTK dialog body overrides normal text color with project Theme tokens\n", label_start
                        reset_label()
                    }
                }

                dialog_depth += delta
                if (dialog_depth <= 0) {
                    in_dialog = 0
                    reset_label()
                }
            }
        }
    ' "$file"
}

detect_dialog_multiple_action_rows_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function flush_dialog() {
            if (in_dialog && action_rows > 1)
                printf "%s: DTK dialog contains %d separate action rows; keep one standard action row\n", dialog_start, action_rows
            in_dialog = 0
            dialog_depth = 0
            dialog_start = 0
            action_rows = 0
            in_row = 0
            row_depth = 0
            row_button_count = 0
        }

        BEGIN {
            in_dialog = 0
            dialog_depth = 0
            dialog_start = 0
            action_rows = 0
            in_row = 0
            row_depth = 0
            row_button_count = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_dialog && line ~ /^[[:space:]]*D\.(Dialog|DialogWindow)[[:space:]]*\{/) {
                in_dialog = 1
                dialog_depth = 0
                dialog_start = NR
                action_rows = 0
            }

            if (in_dialog) {
                if (!in_row && line ~ /^[[:space:]]*RowLayout[[:space:]]*\{/) {
                    in_row = 1
                    row_depth = 0
                    row_button_count = 0
                }

                if (in_row) {
                    if (line ~ /^[[:space:]]*((D|QQC2|QQC)\.)?(Button|WarningButton|RecommandButton|RoundButton|ToolButton)[[:space:]]*\{/)
                        row_button_count++

                    row_depth += delta
                    if (row_depth <= 0) {
                        if (row_button_count > 0)
                            action_rows++
                        in_row = 0
                        row_depth = 0
                        row_button_count = 0
                    }
                }

                dialog_depth += delta
                if (dialog_depth <= 0)
                    flush_dialog()
            }
        }

        END {
            flush_dialog()
        }
    ' "$file"
}

detect_raw_icon_source_without_tint_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_object() {
            in_object = 0
            object_depth = 0
            icon_source_line = 0
            has_icon_color = 0
        }

        BEGIN {
            reset_object()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_object && line ~ /^[[:space:]]*((D|QQC2|QQC)\.)?(MenuItem|Button|ToolButton|ActionButton|RecommandButton|WarningButton|RoundButton)[[:space:]]*\{/) {
                in_object = 1
                object_depth = 0
                icon_source_line = 0
                has_icon_color = 0
            }

            if (in_object) {
                if (object_depth == 1 && line ~ /^[[:space:]]*icon\.source[[:space:]]*:/)
                    icon_source_line = NR
                if (object_depth == 1 && line ~ /^[[:space:]]*icon\.color[[:space:]]*:/)
                    has_icon_color = 1

                object_depth += delta
                if (object_depth <= 0) {
                    if (icon_source_line > 0 && !has_icon_color)
                        printf "%s: icon.source is used without icon.color; symbolic SVG icons must use theme-driven alpha tint\n", icon_source_line
                    reset_object()
                }
            }
        }
    ' "$file"
}

detect_floating_message_icon_payload_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_payload() {
            in_payload = 0
            payload_depth = 0
            payload_start = 0
            has_icon_name = 0
        }

        BEGIN {
            reset_payload()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_payload && line ~ /(property[[:space:]]+var[[:space:]]+toastPayload|toastPayload[[:space:]]*=)/ && line ~ /\{/) {
                in_payload = 1
                payload_depth = delta
                payload_start = NR
                has_icon_name = (line ~ /iconName[[:space:]]*:/)
                if (payload_depth <= 0) {
                    if (has_icon_name)
                        printf "%s: FloatingMessage toast payload still declares iconName; omit unstable custom icon payloads or add a narrow waiver\n", payload_start
                    reset_payload()
                }
                next
            }

            if (in_payload) {
                if (line ~ /iconName[[:space:]]*:/)
                    has_icon_name = 1

                payload_depth += delta
                if (payload_depth <= 0) {
                    if (has_icon_name)
                        printf "%s: FloatingMessage toast payload still declares iconName; omit unstable custom icon payloads or add a narrow waiver\n", payload_start
                    reset_payload()
                }
            }
        }
    ' "$file"
}

detect_direct_button_icon_source_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_object() {
            in_object = 0
            object_depth = 0
        }

        BEGIN {
            reset_object()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_object && line ~ /^[[:space:]]*((D|QQC2|QQC)\.)?(Button|ToolButton|IconButton|ActionButton|RecommandButton|WarningButton|RoundButton)[[:space:]]*\{/) {
                in_object = 1
                object_depth = 0
            }

            if (in_object) {
                if (object_depth == 1 \
                    && line ~ /^[[:space:]]*icon\.source[[:space:]]*:/ \
                    && line !~ /^[[:space:]]*icon\.source[[:space:]]*:[[:space:]]*""[[:space:]]*(\/\/.*)?$/)
                    printf "%s: DTK button-style control uses icon.source directly; bundled symbolic SVG icons must go through the audited alpha-tint content path\n", NR

                object_depth += delta
                if (object_depth <= 0)
                    reset_object()
            }
        }
    ' "$file"
}

detect_button_icon_box_size_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_object() {
            in_object = 0
            object_depth = 0
            object_start = 0
            is_symbolic_component = 0
            has_icon = 0
            icon_width_ok = 0
            icon_height_ok = 0
            uses_symbol_size = 0
            symbol_size_ok = 0
        }

        BEGIN {
            reset_object()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_object && line ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*)?((D|QQC2|QQC)\.)?(Button|ToolButton|IconButton|ActionButton|RecommandButton|WarningButton|RoundButton|SymbolicButton|SymbolicToolButton)[[:space:]]*\{/) {
                in_object = 1
                object_depth = 0
                object_start = NR
                is_symbolic_component = (line ~ /Symbolic(Button|ToolButton)[[:space:]]*\{/)
                has_icon = 0
                icon_width_ok = 0
                icon_height_ok = 0
                uses_symbol_size = 0
                symbol_size_ok = 0
            }

            if (in_object) {
                if (object_depth == 1 && line ~ /^[[:space:]]*icon\.(name|source)[[:space:]]*:/)
                    has_icon = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*symbolSource[[:space:]]*:/)
                    has_icon = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*(property[[:space:]]+int[[:space:]]+)?symbolSize[[:space:]]*:/)
                    uses_symbol_size = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*icon\.width[[:space:]]*:[[:space:]]*16([^0-9]|$)/)
                    icon_width_ok = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*icon\.height[[:space:]]*:[[:space:]]*16([^0-9]|$)/)
                    icon_height_ok = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*(property[[:space:]]+int[[:space:]]+)?symbolSize[[:space:]]*:[[:space:]]*16([^0-9]|$)/)
                    symbol_size_ok = 1

                object_depth += delta
                if (object_depth <= 0) {
                    if (has_icon) {
                        if (uses_symbol_size) {
                            if (!symbol_size_ok)
                                printf "%s: button-contained symbolic icons must use a 16px box matching pure icon buttons\n", object_start
                        } else if (!is_symbolic_component && (!icon_width_ok || !icon_height_ok)) {
                            printf "%s: button-contained symbolic icons must explicitly set a 16x16 icon box matching pure icon buttons\n", object_start
                        }
                    }
                    reset_object()
                }
            }
        }
    ' "$file"
}

detect_window_scene_preview_border_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_background = 0
            background_depth = 0
            background_start = 0
            exact_border = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_background && line ~ /^[[:space:]]*background[[:space:]]*:[[:space:]]*Rectangle[[:space:]]*\{/) {
                in_background = 1
                background_depth = delta
                background_start = NR
                exact_border = (line ~ /border\.width[[:space:]]*:[[:space:]]*1([^0-9.]|$)/)
                next
            }

            if (in_background) {
                if (line ~ /^[[:space:]]*border\.width[[:space:]]*:[[:space:]]*1([[:space:]]*(\/\/.*)?$)/)
                    exact_border = 1

                background_depth += delta
                if (background_depth <= 0) {
                    if (!exact_border)
                        printf "%s: structural thumbnail background should keep an explicit fixed 1px border\n", background_start
                    in_background = 0
                    background_depth = 0
                    background_start = 0
                    exact_border = 0
                }
            }
        }
    ' "$file"
}

detect_card_internal_list_edge_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function starts_card(s,   token) {
            token = s
            sub(/^[[:space:]]*/, "", token)
            sub(/^delegate[[:space:]]*:[[:space:]]*/, "", token)
            sub(/[[:space:]]*\{.*/, "", token)
            return token ~ /(^|\.)(GlassCard|HeroCard|MetricCard|[A-Za-z_][A-Za-z0-9_]*Card)$/
        }

        function starts_repeat(s) {
            return s ~ /^[[:space:]]*(Repeater|ListView|GridView|PathView)[[:space:]]*\{/ \
                || s ~ /^[[:space:]]*delegate[[:space:]]*:[[:space:]].*\{/
        }

        function numeric_value(s,   value) {
            value = s
            sub(/.*:[[:space:]]*/, "", value)
            sub(/[[:space:]]*(\/\/.*)?$/, "", value)
            gsub(/[^0-9.]/, "", value)
            return value + 0
        }

        function reset_row() {
            in_row = 0
            row_depth = 0
            row_start = 0
            row_full_width = 0
            row_has_inset = 0
            row_has_height = 0
            row_height = 0
        }

        BEGIN {
            card_stack = 0
            repeat_stack = 0
            reset_row()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (starts_card(line)) {
                card_stack += 1
                card_depth[card_stack] = 0
            }

            if (card_stack > 0 && starts_repeat(line)) {
                repeat_stack += 1
                repeat_depth[repeat_stack] = 0
            }

            if (!in_row && card_stack > 0 && repeat_stack > 0 && line ~ /^[[:space:]]*(delegate[[:space:]]*:[[:space:]]*)?Rectangle[[:space:]]*\{/) {
                in_row = 1
                row_depth = 0
                row_start = NR
                row_full_width = 0
                row_has_inset = 0
                row_has_height = 0
                row_height = 0
            }

            if (in_row) {
                if (row_depth == 1) {
                    if (line ~ /^[[:space:]]*width[[:space:]]*:/) {
                        if (line ~ /Theme\.cardListInset/)
                            row_has_inset = 1
                        if (line ~ /-[[:space:]]*[0-9A-Za-z_.(]/ && line !~ /:[[:space:]]*(parent\.width|ListView\.view\.width|listColumn\.laneWidth|tableColumn\.laneWidth)[[:space:]]*$/)
                            row_has_inset = 1
                        if (line ~ /:[[:space:]]*(parent\.width|ListView\.view\.width|listColumn\.laneWidth|tableColumn\.laneWidth)([[:space:]]*(\/\/.*)?$)/)
                            row_full_width = 1
                    }

                    if (line ~ /^[[:space:]]*height[[:space:]]*:/) {
                        row_has_height = 1
                        row_height = numeric_value(line)
                    }
                }

                row_depth += delta
                if (row_depth <= 0) {
                    if (row_full_width && !row_has_inset && row_has_height && row_height >= 32 && row_height <= 120)
                        printf "%s: repeated row surface inside a card spans the full card content lane; reserve a second inner inset instead of running edge-to-edge\n", row_start
                    reset_row()
                }
            }

            if (repeat_stack > 0) {
                repeat_depth[repeat_stack] += delta
                while (repeat_stack > 0 && repeat_depth[repeat_stack] <= 0) {
                    delete repeat_depth[repeat_stack]
                    repeat_stack -= 1
                }
            }

            if (card_stack > 0) {
                card_depth[card_stack] += delta
                while (card_stack > 0 && card_depth[card_stack] <= 0) {
                    delete card_depth[card_stack]
                    card_stack -= 1
                }
            }
        }
    ' "$file"
}

detect_list_row_content_host_marker_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_row() {
            in_row = 0
            row_depth = 0
            row_start = 0
            row_has_surface = 0
            row_has_content_host = 0
        }

        BEGIN {
            reset_row()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*(delegate[[:space:]]*:[[:space:]]*)?(Rectangle|Item|Control|Pane|Frame)[[:space:]]*\{/) {
                in_row = 1
                row_depth = 0
                row_start = NR
                row_has_surface = 0
                row_has_content_host = 0
            }

            if (in_row) {
                if (line ~ /visualAuditListRowSurface[[:space:]]*:[[:space:]]*true/)
                    row_has_surface = 1
                if (line ~ /visualAuditContentNode[[:space:]]*:[[:space:]]*true/)
                    row_has_content_host = 1

                row_depth += delta
                if (row_depth <= 0) {
                    if (row_has_surface && !row_has_content_host)
                        printf "%s: repeated list-row surface is missing a visualAuditContentNode host for runtime lane auditing\n", row_start
                    reset_row()
                }
            }
        }
    ' "$file"
}

detect_card_background_border_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    case "$base" in
        *Card*.qml|SectionCard.qml|MetricCard.qml)
            ;;
        *)
            if ! grep -qE '^[[:space:]]*(SectionCard|MetricCard)[[:space:]]*\{' "$file"; then
                return 0
            fi
            ;;
    esac

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function starts_card_object(s) {
            return s ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*Card[[:space:]]*\{/
        }

        function reset_card() {
            in_card = 0
            card_depth = 0
        }

        function reset_background() {
            in_background = 0
            background_depth = 0
            background_start = 0
            saw_border = 0
            exact_border = 0
            scaled_border = 0
        }

        BEGIN {
            card_file = (FILENAME ~ /(^|\/)[^\/]*Card[^\/]*\.qml$/)
            reset_card()
            reset_background()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_card && starts_card_object(line)) {
                in_card = 1
                card_depth = 0
            }

            if (!in_background) {
                if (((in_card && card_depth == 1) || (!in_card && card_file)) \
                    && line ~ /^[[:space:]]*background[[:space:]]*:[[:space:]]*Rectangle[[:space:]]*\{/)
                {
                    in_background = 1
                    background_depth = delta
                    background_start = NR
                    if (line ~ /border\.width[[:space:]]*:/) {
                        saw_border = 1
                        if (line ~ /border\.width[[:space:]]*:[[:space:]]*1(\.0+)?([[:space:]]*(\/\/.*)?$)/)
                            exact_border = 1
                        else
                            scaled_border = 1
                    }
                    next
                }
            }

            if (in_background) {
                if (line ~ /^[[:space:]]*border\.width[[:space:]]*:/) {
                    saw_border = 1
                    if (line ~ /^[[:space:]]*border\.width[[:space:]]*:[[:space:]]*1(\.0+)?([[:space:]]*(\/\/.*)?$)/)
                        exact_border = 1
                    else
                        scaled_border = 1
                }

                background_depth += delta
                if (background_depth <= 0) {
                    if (!saw_border || !exact_border || scaled_border) {
                        printf "%s: card background should keep an explicit fixed 1px border with no UI-scale math\n", background_start
                    }
                    reset_background()
                }
            }

            if (in_card) {
                card_depth += delta
                if (card_depth <= 0)
                    reset_card()
            }
        }
    ' "$file"
}

detect_antialiased_card_shell_stroke_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    case "$base" in
        *Card*.qml|SectionCard.qml|MetricCard.qml)
            ;;
        *)
            return 0
            ;;
    esac

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_root = 0
            depth = 0
            start = 0
            shell_marker = 0
            border_one = 0
            antialias = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_root && line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/) {
                in_root = 1
                depth = 0
                start = NR
            }

            if (in_root) {
                if (line ~ /visualAuditCardShell[[:space:]]*:[[:space:]]*true/)
                    shell_marker = 1
                if (line ~ /^[[:space:]]*border\.width[[:space:]]*:[[:space:]]*1(\.0+)?([[:space:]]*(\/\/.*)?$)/)
                    border_one = 1
                if (line ~ /^[[:space:]]*antialiasing[[:space:]]*:[[:space:]]*true([[:space:]]*(\/\/.*)?$)/)
                    antialias = 1

                depth += delta
                if (depth <= 0) {
                    if (shell_marker && border_one && antialias)
                        printf "%s: card shell renders its primary 1px stroke through an antialiased Rectangle.border; use a dedicated 1px stroke ring or layer instead\n", start
                    exit
                }
            }
        }
    ' "$file"
}

detect_nontruthful_live_list_icon_hits() {
    local file="$1"
    local base
    base="$(basename "$file")"

    case "$base" in
        *File*.qml|*App*.qml|*Program*.qml|*Software*.qml)
            return 0
            ;;
    esac

    if ! grep -qE 'SettingRow|SettingsOptionRow|TaskRow|ListItem|Sidebar|Navigation|Nav|ListView|Repeater|delegate[[:space:]]*:' "$file"; then
        return 0
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_row = 0
            row_depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*(SettingRow|SettingsOptionRow|TaskRow|ListItem|SidebarItem|NavItem|NavigationItem)[[:space:]]*\{/) {
                in_row = 1
                row_depth = 0
            }

            if (in_row) {
                if (line ~ /^[[:space:]]*iconName[[:space:]]*:[[:space:]]*([^"].*|".+")/)
                    printf "%s: non-file/non-app truthful lists should prefer downloaded or bundled SVG icons, not iconName/live object icons\n", NR
                if (line ~ /^[[:space:]]*(iconSource|source)[[:space:]]*:[[:space:]].*(image:\/\/|appIcon|fileIcon|mimeIcon|desktop(App|File)|QFileIconProvider|iconProvider)/)
                    printf "%s: non-file/non-app truthful lists should prefer downloaded or bundled SVG icons, not live object icon providers\n", NR

                row_depth += delta
                if (row_depth <= 0)
                    in_row = 0
            }
        }
    ' "$file"
}

detect_window_scene_preview_strong_ink_hits() {
    local file="$1"
    grep -nE '^[[:space:]]*color[[:space:]]*:[[:space:]]*(Theme\.(textStrong|textSecondary|fgStrong|fgNormal)|"#([Ff]{3}|[Ff]{6}|[0]{3}|[0]{6})")' "$file" || true
}

detect_page_loader_hard_cut_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_loader() {
            in_loader = 0
            loader_depth = 0
            loader_start = 0
            has_source_component = 0
            returns_page_component = 0
            has_opacity_behavior = 0
            has_axis_behavior = 0
        }

        BEGIN {
            reset_loader()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_loader && line ~ /^[[:space:]]*Loader[[:space:]]*\{/) {
                in_loader = 1
                loader_depth = 0
                loader_start = NR
                has_source_component = 0
                returns_page_component = 0
                has_opacity_behavior = 0
                has_axis_behavior = 0
            }

            if (in_loader) {
                if (loader_depth == 1 && line ~ /^[[:space:]]*sourceComponent[[:space:]]*:/)
                    has_source_component = 1
                if (line ~ /return[[:space:]]+[A-Za-z0-9_]*Page([[:space:]]|;|$)/)
                    returns_page_component = 1
                if (loader_depth == 1 && line ~ /^[[:space:]]*Behavior on opacity[[:space:]]*\{/)
                    has_opacity_behavior = 1
                if (loader_depth == 1 && line ~ /^[[:space:]]*Behavior on (x|y)[[:space:]]*\{/)
                    has_axis_behavior = 1

                loader_depth += delta
                if (loader_depth <= 0) {
                    if (has_source_component && returns_page_component && (!has_opacity_behavior || !has_axis_behavior))
                        printf "%s: page-switch Loader should animate with opacity plus a short positional transition instead of hard cutting between pages\n", loader_start
                    reset_loader()
                }
            }
        }
    ' "$file"
}

detect_hover_feedback_hard_cut_hits() {
    local file="$1"
    if ! grep -qE 'HoverHandler|containsMouse' "$file"; then
        return
    fi

    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_object() {
            in_object = 0
            object_depth = 0
            object_start = 0
            has_hover_color = 0
            has_color_behavior = 0
        }

        BEGIN {
            reset_object()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_object && line ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*[[:space:]]*:[[:space:]]*)?(Rectangle|Item|Pane|Frame)[[:space:]]*\{/) {
                in_object = 1
                object_depth = 0
                object_start = NR
                has_hover_color = 0
                has_color_behavior = 0
            }

            if (in_object) {
                if (object_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:.*(hovered|containsMouse)/)
                    has_hover_color = 1
                if (object_depth == 1 && line ~ /^[[:space:]]*Behavior on color[[:space:]]*\{/)
                    has_color_behavior = 1

                object_depth += delta
                if (object_depth <= 0) {
                    if (has_hover_color && !has_color_behavior)
                        printf "%s: hover-driven surface color changes should animate instead of hard cutting\n", object_start
                    reset_object()
                }
            }
        }
    ' "$file"
}

detect_behavior_duration_token_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function reset_behavior() {
            in_behavior = 0
            behavior_depth = 0
            behavior_start = 0
            property_name = ""
            uses_theme_token = 0
            uses_literal_duration = 0
        }

        BEGIN {
            reset_behavior()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_behavior && line ~ /^[[:space:]]*Behavior on [A-Za-z0-9_.]+[[:space:]]*\{/) {
                in_behavior = 1
                behavior_depth = 0
                behavior_start = NR
                property_name = line
                sub(/^[[:space:]]*Behavior on[[:space:]]*/, "", property_name)
                sub(/[[:space:]]*\{.*/, "", property_name)
                uses_theme_token = 0
                uses_literal_duration = 0
            }

            if (in_behavior) {
                if (line ~ /^[[:space:]]*duration[[:space:]]*:[[:space:]]*Theme\.anim[A-Za-z0-9_]*/)
                    uses_theme_token = 1
                else if (line ~ /^[[:space:]]*duration[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/)
                    uses_literal_duration = 1

                behavior_depth += delta
                if (behavior_depth <= 0) {
                    if (property_name ~ /^(color|opacity|x|y|width|height|backgroundColor|borderColor|contentOffset|contentOpacity)$/ \
                        && uses_literal_duration && !uses_theme_token)
                        printf "%s: shell or feedback Behavior on %s should use Theme animation tokens instead of a raw duration literal\n", behavior_start, property_name
                    reset_behavior()
                }
            }
        }
    ' "$file"
}

detect_manual_card_pair_equalization_hits() {
    local file="$1"
    grep -nE 'Theme\.equalizedCardPairHeight[[:space:]]*\(' "$file" || true
}

detect_window_scene_preview_subdued_hits() {
    local file="$1"
    awk '
        function flush_preview() {
            if (in_preview && !has_subdued && !has_waiver)
                printf "%s: WindowScenePreview should explicitly set subdued: true when used as an auto-generated structural thumbnail\n", start_line
            in_preview = 0
            preview_depth = 0
            start_line = 0
            has_subdued = 0
            has_waiver = 0
        }

        {
            line = $0

            if (!in_preview && line ~ /^[[:space:]]*WindowScenePreview[[:space:]]*\{/) {
                in_preview = 1
                preview_depth = 0
                start_line = NR
                has_subdued = 0
                has_waiver = 0
            }

            if (in_preview) {
                if (line ~ /subdued[[:space:]]*:[[:space:]]*true([^A-Za-z0-9_]|$)/)
                    has_subdued = 1
                if (line ~ /uos-design:[[:space:]]*allow-strong-card-thumbnail/)
                    has_waiver = 1

                opens = gsub(/\{/, "{", line)
                closes = gsub(/\}/, "}", line)
                preview_depth += opens - closes

                if (preview_depth <= 0)
                    flush_preview()
            }
        }

        END {
            flush_preview()
        }
    ' "$file"
}

audit_self_check_detectors() {
    local probe_file=""
    local detector=""
    local stdout_file=""
    local stderr_file=""
    local status=0

    probe_file="$(mktemp "${TMPDIR:-/tmp}/uos-design-audit-selfcheck-XXXXXX.qml")"
    cat >"$probe_file" <<'EOF'
import QtQuick

Item {
}
EOF

    while IFS= read -r detector; do
        [[ -n "$detector" ]] || continue
        stdout_file="$(mktemp "${TMPDIR:-/tmp}/uos-design-audit-selfcheck-stdout-XXXXXX")"
        stderr_file="$(mktemp "${TMPDIR:-/tmp}/uos-design-audit-selfcheck-stderr-XXXXXX")"
        status=0

        if ! "$detector" "$probe_file" "Button" >"$stdout_file" 2>"$stderr_file"; then
            status=$?
        fi

        if (( status != 0 )) || [[ -s "$stderr_file" ]]; then
            rm -f "$probe_file" "$stdout_file" "$stderr_file"
            printf 'audit detector self-check failed in %s\n' "$detector" >&2
            if [[ -s "$stderr_file" ]]; then
                cat "$stderr_file" >&2
            elif [[ -s "$stdout_file" ]]; then
                cat "$stdout_file" >&2
            fi
            exit 70
        fi

        rm -f "$stdout_file" "$stderr_file"
    done < <(declare -F | awk '{print $3}' | grep -E '^detect_.*_hits$' | sort)

    rm -f "$probe_file"
}

dtk_available=0
for candidate in \
    /usr/lib/x86_64-linux-gnu/qt6/qml/org/deepin/dtk \
    /usr/lib64/qt6/qml/org/deepin/dtk \
    /usr/lib/qt6/qml/org/deepin/dtk \
    /usr/lib/qt/qml/org/deepin/dtk \
    /usr/local/lib/qt6/qml/org/deepin/dtk
do
    if [[ -d "$candidate" ]]; then
        dtk_available=1
        dtk_qmldir="$candidate/qmldir"
        if [[ -f "$candidate/settings/qmldir" ]]; then
            dtk_settings_qmldir="$candidate/settings/qmldir"
        fi
        break
    fi
done

audit_self_check_detectors

if (( dtk_available )); then
    if [[ -z "$(grep_repo '^[[:space:]]*import[[:space:]]+org\.deepin\.dtk' --include='*.qml')" ]]; then
        log_fail "dtk-import-missing" "DTK is installed locally but no 'import org.deepin.dtk' was found in project QML."
    fi

    if [[ -z "$(grep_repo 'Dtk6|DtkDeclarative|deepin[._-]?dtk|DTK' --include='CMakeLists.txt' --include='*.cmake' --include='*.pro' --include='*.pri')" ]]; then
        log_fail "dtk-build-missing" "DTK is installed locally but no DTK build integration was found in CMake/qmake files."
    fi
fi

circular_score_fixed_typography=0
if [[ -n "$(grep_repo 'font\.pixelSize[[:space:]]*:[[:space:]]*[4-9][0-9]' --include='*CircularScore*.qml')" ]]; then
    circular_score_fixed_typography=1
fi

while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    log_fail "non-dtk-style" "$line"
done < <(grep_repo 'QQuickStyle::setStyle\(.*(Basic|Fusion|Material|Imagine|Universal|FluentWinUI3)' --include='*.cpp' --include='*.cc' --include='*.cxx' --include='*.h' --include='*.hpp')

while IFS= read -r -d '' file; do
    rel="${file#$ROOT/}"

    if ! grep -q 'uos-design: allow-icon-rasterization' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "icon-rasterization" "$rel:$hit"
        done < <(grep -nE '\.pixmap\(|save\(.*["'\'']PNG["'\'']' "$file" || true)
    fi
done < <(list_source_files)

while IFS= read -r -d '' file; do
    rel="${file#$ROOT/}"

    if ! grep -q 'uos-design: allow-frameless' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "frameless-window" "$rel:$hit"
        done < <(grep -nE 'Qt\.FramelessWindowHint' "$file" || true)
    fi

    if ! grep -q 'uos-design: allow-large-window-default' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "large-window-default" "$rel:$hit"
        done < <(detect_large_window_size_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-compact-settings-dialog' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "compact-settings-dialog" "$rel:$hit"
        done < <(detect_small_settings_dialog_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "standard-dtk-surface-system-titlebar" "$rel:$hit"
    done < <(detect_standard_dtk_surface_system_titlebar_hits "$file")

    if (( dtk_available )) && dtk_settings_has_export SettingsDialog && ! grep -q 'uos-design: allow-settings-dialog-without-icon' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "settings-dialog-missing-icon" "$rel:$hit"
        done < <(detect_settings_dialog_missing_icon_hits "$file")
    fi

    if (( dtk_available )) && dtk_settings_has_export CheckBox && ! grep -q 'uos-design: allow-settings-checkbox-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "settings-checkbox-fallback" "$rel:$hit"
        done < <(detect_settings_checkbox_fallback_hits "$file")
    fi

    if (( dtk_available )) && dtk_settings_has_export ComboBox && ! grep -q 'uos-design: allow-settings-combobox-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "settings-combobox-fallback" "$rel:$hit"
        done < <(detect_settings_combobox_fallback_hits "$file")
    fi

    if (( dtk_available )) && dtk_settings_has_export LineEdit && ! grep -q 'uos-design: allow-settings-lineedit-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "settings-lineedit-fallback" "$rel:$hit"
        done < <(detect_settings_lineedit_fallback_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-custom-settings-reset-entry' "$file" \
        && grep -qE '^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{' "$file"
    then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "custom-settings-reset-entry" "$rel:$hit: restore-default actions in multi-group settings should use the DTK-owned footer path instead of a normal settings row"
        done < <(grep -nE '^[[:space:]]*(key|name)[[:space:]]*:[[:space:]]*["'\'']([^"'\'']*)(restoreDefaults|resetDefaults|Restore Defaults|恢复默认)' "$file" || true)
    fi

    if ! grep -q 'uos-design: allow-custom-settings-row-metrics' "$file" \
        && grep -qE '^[[:space:]]*((Settings\.)?SettingsDialog)[[:space:]]*\{' "$file"
    then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "custom-settings-row-metrics" "$rel:$hit"
        done < <(detect_settings_option_delegate_theme_hits "$file")

        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "custom-settings-row-metrics" "$rel:$hit: multi-group settings should not route through project-specific SettingRow / SettingsOptionRow styling"
        done < <(grep -nE '(^|[^A-Za-z0-9_])(SettingRow|SettingsOptionRow)[[:space:]]*\{' "$file" || true)
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "non-dtk-dialog" "$rel:$hit"
    done < <(detect_non_dtk_dialog_hits "$file")

    if (( dtk_available )) && dtk_has_export DialogWindow && ! grep -q 'uos-design: allow-popup-style-dialog' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "popup-style-dialog" "$rel:$hit"
        done < <(detect_popup_style_dtk_dialog_hits "$file")
    fi

    if (( dtk_available )) && dtk_has_export DialogWindow && ! grep -q 'uos-design: allow-manual-dialog-action-row' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "manual-dialog-action-row" "$rel:$hit"
        done < <(detect_manual_dialog_action_row_hits "$file")
    fi

    if (( dtk_available )) && dtk_has_export DialogWindow && ! grep -q 'uos-design: allow-nonstandard-dialog-footer' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "dialog-standard-footer" "$rel:$hit"
        done < <(detect_standard_dialog_footer_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-multi-action-dialog-rows' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "dialog-multi-action-rows" "$rel:$hit"
        done < <(detect_dialog_multiple_action_rows_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-vertical-action-stack' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "vertical-action-stack" "$rel:$hit"
        done < <(detect_vertical_action_stack_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-custom-dialog-content-style' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "custom-dialog-content-style" "$rel:$hit"
        done < <(detect_custom_dialog_content_style_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "dialog-overlay" "$rel:$hit"
    done < <(detect_dialog_overlay_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "main-window-dtk-header" "$rel:$hit"
    done < <(detect_required_main_window_header_hits "$file")

    if (( dtk_available )) && dtk_has_export WindowButtonGroup && ! grep -q 'uos-design: allow-custom-window-buttons' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "custom-window-buttons" "$rel:$hit"
        done < <(detect_custom_window_button_hits "$file")
    fi

    if (( dtk_available )) && dtk_has_export WindowButtonGroup && ! grep -q 'uos-design: allow-offset-window-button-group' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "window-button-group-placement" "$rel:$hit"
        done < <(detect_window_button_group_placement_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "titlebar-control-safe-area" "$rel:$hit"
    done < <(detect_titlebar_safe_area_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "titlebar-centered-content" "$rel:$hit"
    done < <(detect_centered_titlebar_content_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "header-icon-size" "$rel:$hit"
    done < <(detect_header_button_icon_size_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "titlebar-clipped-ancestor" "$rel:$hit"
    done < <(detect_titlebar_clipped_ancestor_hits "$file")

    if ! grep -q 'uos-design: allow-customized-window-flags' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "customized-window-flags" "$rel:$hit"
        done < <(detect_risky_titlebar_flag_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "transparent-titlebar-background" "$rel:$hit"
    done < <(detect_transparent_titlebar_background_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "titleband-underlay-gap" "$rel:$hit"
    done < <(detect_titleband_underlay_gap_hits "$file")

    if ! grep -q 'uos-design: allow-transparent-main-window' "$file"; then
        if [[ "$(file_has_root_application_window "$file")" == "yes" ]] \
            && grep -qE '^[[:space:]]*color[[:space:]]*:[[:space:]]*["'\'']transparent["'\'']' "$file" \
            && ! grep -qE "$surface_token_pattern" "$file"
        then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "transparent-main-window" "$rel:$hit (transparent top-level window without an explicit theme-backed base surface)"
            done < <(grep -nE '^[[:space:]]*color[[:space:]]*:[[:space:]]*["'\'']transparent["'\'']' "$file" || true)
        fi
    fi

    if ! grep -q 'uos-design: allow-full-window-base-under-sidebar-blur' "$file"; then
        if [[ "$(file_has_root_application_window "$file")" == "yes" ]] \
            && grep -qE '^[[:space:]]*color[[:space:]]*:[[:space:]]*["'\'']transparent["'\'']' "$file" \
            && grep -qE 'AppSidebar|sidebarWidth|sidebarHidden|sidebarHost|onCollapseRequested' "$file"
        then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "sidebar-blur-covered-by-base-surface" "$rel:$hit (scope theme-backed base surfaces to the right content panel; do not place a full-window base underneath the blurred sidebar)"
            done < <(detect_sidebar_blur_covered_by_base_surface_hits "$file")
        fi
    fi

    if ! grep -q 'uos-design: allow-full-window-blur' "$file"; then
        if [[ "$(file_has_root_application_window "$file")" == "yes" ]] \
            && grep -qE 'AppSidebar|sidebarWidth|sidebarHidden|sidebarHost|onCollapseRequested' "$file"
        then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "full-window-blur-sidebar-app" "$rel:$hit"
            done < <(detect_full_window_blur_hits "$file")
        fi
    fi

    if [[ "$(file_has_root_application_window "$file")" == "yes" ]] \
        && grep -qE 'AppSidebar|sidebarWidth|sidebarHidden|sidebarHost|onCollapseRequested' "$file"
    then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "sidebar-gap" "$rel:$hit (keep sidebar/content spacing at 0 and place the divider on the sidebar edge instead of anchoring content after a spacer item)"
        done < <(detect_sidebar_gap_hits "$file")

        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "top-operational-banner" "$rel:$hit"
        done < <(detect_top_operational_banner_hits "$file")

        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "sidebar-width-squeeze" "$rel:$hit (collapse/expand should read as translate-out / translate-in, not width squeeze)"
        done < <(detect_sidebar_width_squeeze_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "page-loader-hard-cut" "$rel:$hit"
    done < <(detect_page_loader_hard_cut_hits "$file")

    case "$rel" in
        *Sidebar*.qml)
            if [[ "$(file_has_root_item "$file")" == "yes" ]] \
                && grep -q 'ListView' "$file" \
                && ! grep -q 'StyledBehindWindowBlur' "$file" \
                && [[ "$(file_has_fill_parent_rectangle "$file")" != "yes" ]]
            then
                log_fail "sidebar-panel-surface-missing" "$rel: sidebar component renders navigation content but never establishes an explicit sidebar panel surface"
            fi

            if grep -q 'ListView' "$file" && [[ "$(file_has_sidebar_edge_divider "$file")" != "yes" ]]; then
                log_fail "sidebar-edge-divider-missing" "$rel: persistent sidebar lacks a 1px divider anchored to the sidebar right edge"
            fi

            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "sidebar-single-group-header" "$rel:$hit"
            done < <(detect_single_group_sidebar_header_hits "$file")

            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "sidebar-group-spacing" "$rel:$hit"
            done < <(detect_sidebar_group_spacing_hits "$file")

            if grep -qE 'currentPage|pageSelected|navigationGroups' "$file" && grep -q 'ListView' "$file"; then
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "sidebar-nav-icon-treatment" "$rel:$hit"
                done < <(detect_sidebar_nav_icon_treatment_hits "$file")
            fi

            if ! grep -q 'uos-design: allow-centered-sidebar-list-content' "$file" \
                && grep -qE 'Repeater|ListView' "$file"
            then
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "sidebar-centered-list-content" "$rel:$hit"
                done < <(detect_centered_sidebar_list_content_hits "$file")
            fi

            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "sidebar-row-interaction" "$rel:$hit"
            done < <(detect_sidebar_noninteractive_row_hits "$file")

            if [[ "$(basename "$file")" == "SidebarMessageCard.qml" ]] \
                || { grep -q 'actionTriggered' "$file" && grep -q 'actionText' "$file"; }
            then
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "sidebar-operational-button-width" "$rel:$hit"
                done < <(detect_sidebar_operational_button_width_hits "$file")
            fi
            ;;
    esac

    if ! grep -q 'uos-design: allow-popup-window' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "popup-window" "$rel:$hit"
        done < <(grep -nE 'Popup\.Window' "$file" || true)
    fi

    if [[ "$(basename "$file")" != "Theme.qml" ]] && ! grep -q 'uos-design: allow-literal-color' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "hardcoded-color" "$rel:$hit"
        done < <(grep -nE '#[0-9A-Fa-f]{3,8}\b' "$file" || true)
    fi

    if ! grep -q 'uos-design: allow-textMuted-icon' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "text-muted-icon" "$rel:$hit"
        done < <(grep -nE 'tint[[:space:]]*:.*Theme\.textMuted' "$file" || true)
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "hover-feedback-hard-cut" "$rel:$hit (hover-driven surface color changes should animate with Theme.animFast instead of hard cutting)"
    done < <(detect_hover_feedback_hard_cut_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "behavior-duration-token" "$rel:$hit"
    done < <(detect_behavior_duration_token_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "manual-blur-overlay" "$rel:$hit"
    done < <(detect_manual_blur_overlay_hits "$file")

    if ! grep -q 'uos-design: allow-app-side-window-decoration-tuning' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "app-side-window-decoration-tuning" "$rel:$hit"
        done < <(grep -nE 'D\.DWindow\.(windowRadius|borderWidth|borderColor|shadowRadius|shadowOffset|shadowColor)[[:space:]]*:' "$file" || true)
    fi

    if ! grep -q 'uos-design: allow-anchored-item-implicit-height' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "anchored-item-implicit-height" "$rel:$hit"
        done < <(detect_anchored_item_implicit_height_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "self-binding" "$rel:$hit"
    done < <(detect_self_binding_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "large-title-weight" "$rel:$hit"
    done < <(detect_large_title_weight_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "page-header-icon" "$rel:$hit"
    done < <(detect_page_header_icon_hits "$file")

    if [[ "$(basename "$file")" != "MetricValueLabel.qml" ]]; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "large-unit-label" "$rel:$hit"
        done < <(detect_large_unit_label_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-shadowed-delegate-role' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "shadowed-delegate-role" "$rel:$hit"
        done < <(detect_shadowed_delegate_role_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-list-without-leading-icon' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "multiline-list-missing-icon" "$rel:$hit"
        done < <(detect_multiline_setting_row_missing_icon_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-icon-size" "$rel:$hit"
    done < <(detect_multiline_setting_row_icon_size_hits "$file")

    if ! grep -q 'uos-design: allow-multiline-list-icon-center' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "multiline-list-icon-alignment" "$rel:$hit"
        done < <(detect_multiline_row_top_alignment_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-row-aware-card-outside-responsive-grid' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "row-aware-card-grid-host" "$rel:$hit"
        done < <(detect_row_aware_card_without_responsive_grid_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-raw-card-band' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "raw-card-band" "$rel:$hit"
        done < <(detect_raw_card_band_hits "$file")
    fi

    if (( circular_score_fixed_typography )) && [[ "$(basename "$file")" != "CircularScore.qml" ]]; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "small-circular-score-usage" "$rel:$hit"
        done < <(detect_small_circular_score_usage_hits "$file")
    fi

    if [[ "$(basename "$file")" == "ContentPage.qml" ]] \
        && [[ "$(file_has_root_item "$file")" == "yes" ]] \
        && ! grep -qE "$surface_token_pattern" "$file"
    then
        log_fail "content-page-surface-missing" "$rel: page skeleton does not consume any documented theme background token"
    fi

    if looks_like_fake_table "$file"; then
        log_fail "fake-table-column-plan" "$rel: table-like screen appears to use separate header widths and row widths without a shared column plan"
    fi

    if ! grep -q 'uos-design: allow-freeform-trailing-control-row' "$file"; then
        if grep -qE 'Repeater|delegate[[:space:]]*:' "$file" \
            && grep -qE '(^|[[:space:]])(AppSwitch|D\.Switch|Switch|D\.ComboBox|ComboBox)([[:space:]]|\{)' "$file" \
            && ! grep -qE 'SettingRow|SettingsOptionRow|controlSlot|trailingSlot|trailingControl|rightControl|controlColumn|actionSlot' "$file"
        then
            log_fail "freeform-trailing-control-row" "$rel: repeated rows with trailing controls should use a dedicated right-side control slot or shared control column"
        fi
    fi

    if ! grep -q 'uos-design: allow-oversized-card' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "oversized-card" "$rel:$hit"
        done < <(detect_oversized_card_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-fixed-card-shell-size' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "fixed-card-shell-size" "$rel:$hit"
        done < <(detect_fixed_card_shell_size_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "fixed-hero-card-shell" "$rel:$hit"
    done < <(detect_fixed_score_hero_card_hits "$file")

    if ! grep -q 'uos-design: allow-card-edge-focal-content' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "card-focal-content-edge" "$rel:$hit"
        done < <(detect_card_focal_content_edge_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-live-content-inset" "$rel:$hit"
    done < <(detect_card_live_content_inset_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-tight-padding" "$rel:$hit"
    done < <(detect_tight_card_padding_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-shell-border" "$rel:$hit"
    done < <(detect_card_background_border_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-shell-border" "$rel:$hit"
    done < <(detect_card_shell_stroke_contract_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-antialiased-shell-stroke" "$rel:$hit"
    done < <(detect_antialiased_card_shell_stroke_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "focal-wrapper-mismatch" "$rel:$hit"
    done < <(detect_focal_wrapper_mismatch_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "fill-anchored-card-layout" "$rel:$hit"
    done < <(detect_fill_anchored_card_layout_hits "$file")

    if ! grep -q 'uos-design: allow-wide-button' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "wide-button" "$rel:$hit"
        done < <(detect_wide_button_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-wrapped-mutually-exclusive-group' "$file"; then
        if (( dtk_available )) && { dtk_has_export ButtonBox || dtk_has_export ButtonGroup || dtk_has_export ControlGroup; }; then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "mutually-exclusive-button-group" "$rel:$hit"
            done < <(detect_mutually_exclusive_button_group_hits "$file")
        fi
    fi

    if (( dtk_available )) && dtk_has_export ButtonBox; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "buttonbox-external-group" "$rel:$hit"
        done < <(detect_buttonbox_external_group_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-horizontal-list-scroll' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "horizontal-list-scroll" "$rel:$hit"
        done < <(detect_horizontal_scroll_risk_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "horizontal-content-cutoff" "$rel:$hit"
    done < <(detect_dynamic_text_cutoff_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "region-content-overflow" "$rel:$hit"
    done < <(detect_unclipped_viewport_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "region-content-overflow" "$rel:$hit"
    done < <(detect_container_overflow_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "horizontal-scrollbar-thickness" "$rel:$hit"
    done < <(detect_horizontal_scrollbar_thickness_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "textless-progress-thickness" "$rel:$hit"
    done < <(detect_textless_progress_thickness_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "duplicate-progress-mode" "$rel:$hit"
    done < <(detect_duplicate_progress_mode_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "legacy-page-list-row" "$rel:$hit"
    done < <(detect_legacy_page_list_row_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "variable-list-card-shell" "$rel:$hit"
    done < <(detect_variable_object_list_card_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-height-cap" "$rel:$hit"
    done < <(detect_list_height_cap_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "dense-cluster-zero-spacing" "$rel:$hit"
    done < <(detect_dense_cluster_zero_spacing_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "text-button-overlap" "$rel:$hit"
    done < <(detect_text_button_overlap_hits "$file")

    if ! grep -q 'uos-design: allow-layered-live-content' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "layered-live-content" "$rel:$hit"
        done < <(detect_direct_content_stack_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-custom-in-app-notification' "$file"; then
        case "$rel" in
            *Toast*.qml)
                if ! grep -qE '(^|[[:space:]])D\.FloatingMessage([[:space:]]|\{)' "$file"; then
                    log_fail "custom-in-app-notification" "$rel: expected DTK FloatingMessage for in-app notifications"
                fi
                ;;
        esac
    fi

    if ! grep -q 'uos-design: allow-floating-message-icon-payload' "$file" \
        && grep -qE '(^|[[:space:]])D\.FloatingMessage([[:space:]]|\{)' "$file"
    then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "floating-message-icon-payload" "$rel:$hit"
        done < <(detect_floating_message_icon_payload_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-direct-floating-message' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "direct-floating-message" "$rel:$hit: instantiate transient notifications via D.DTK.sendMessage(...) instead of direct D.FloatingMessage objects"
        done < <(grep -nE '^[[:space:]]*D\.FloatingMessage[[:space:]]*\{' "$file" || true)
    fi

    if ! grep -q 'uos-design: allow-direct-button-icon-source' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "direct-button-icon-source" "$rel:$hit"
        done < <(detect_direct_button_icon_source_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-button-icon-box-size' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "button-icon-box-size" "$rel:$hit"
        done < <(detect_button_icon_box_size_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-untinted-icon-source' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "untinted-icon-source" "$rel:$hit"
        done < <(detect_raw_icon_source_without_tint_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-dtk-template-override' "$file"; then
        if [[ "$(file_has_root_dtk_template_control "$file")" == "yes" ]]; then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "dtk-template-override" "$rel:$hit"
            done < <(grep -nE '^[[:space:]]*(background|contentItem|indicator|handle|popup|delegate)[[:space:]]*:' "$file" || true)
        fi
    fi

    if (( dtk_available )) && dtk_has_export Button && ! grep -q 'uos-design: allow-plain-button-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-button-fallback" "$rel:$hit: use D.Button or another DTK button variant when Button is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" Button)
    fi

    if (( dtk_available )) && dtk_has_export TextField && ! grep -q 'uos-design: allow-plain-textfield-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-textfield-fallback" "$rel:$hit: use D.TextField when TextField is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" TextField)
    fi

    if (( dtk_available )) && dtk_has_export ComboBox && ! grep -q 'uos-design: allow-plain-combobox-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-combobox-fallback" "$rel:$hit: use D.ComboBox when ComboBox is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" ComboBox)
    fi

    if (( dtk_available )) && dtk_has_export Switch && ! grep -q 'uos-design: allow-plain-switch-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-switch-fallback" "$rel:$hit: use D.Switch when Switch is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" Switch)
    fi

    if (( dtk_available )) && dtk_has_export CheckBox && ! grep -q 'uos-design: allow-plain-checkbox-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-checkbox-fallback" "$rel:$hit: use D.CheckBox when CheckBox is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" CheckBox)
    fi

    if (( dtk_available )) && dtk_has_export Menu && ! grep -q 'uos-design: allow-plain-menu-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-menu-fallback" "$rel:$hit: use D.Menu when Menu is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" Menu)
    fi

    if (( dtk_available )) && dtk_has_export ProgressBar && ! grep -q 'uos-design: allow-plain-progressbar-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-progressbar-fallback" "$rel:$hit: use D.ProgressBar when ProgressBar is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" ProgressBar)
    fi

    if (( dtk_available )) && dtk_has_export ScrollBar && ! grep -q 'uos-design: allow-plain-scrollbar-fallback' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "plain-scrollbar-fallback" "$rel:$hit: use D.ScrollBar when ScrollBar is exported locally"
        done < <(detect_plain_dtk_control_fallback_hits "$file" ScrollBar)
    fi

    if ! grep -q 'uos-design: allow-derived-nav-color' "$file"; then
        case "$rel" in
            *Sidebar*.qml|*Nav*.qml|*Navigation*.qml|*Tab*.qml)
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "derived-nav-color" "$rel:$hit"
                done < <(grep -nE 'Theme\.(mix|withAlpha)\(' "$file" || true)
                ;;
        esac
    fi

    if ! grep -q 'uos-design: allow-sidebar-active-border' "$file"; then
        case "$rel" in
            *Sidebar*.qml|*Nav*.qml|*Navigation*.qml)
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "sidebar-active-border" "$rel:$hit"
                done < <(detect_sidebar_selected_border_hits "$file")
                ;;
        esac
    fi

    if ! grep -q 'uos-design: allow-custom-main-menu-button' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "titlebar-custom-main-menu-trigger" "$rel:$hit (when D.TitleBar is used, let TitleBar.menu generate and own the main-menu button; do not self-draw a trigger)"
        done < <(detect_titlebar_custom_main_menu_trigger_hits "$file")

        if grep -qE '(^|[[:space:]])(AppButton|Button|QQC\.Button|D\.ToolButton|D\.ActionButton)([[:space:]]|\{)' "$file" \
            && grep -qE 'iconName[[:space:]]*:[[:space:]]*"menu"|text[[:space:]]*:[[:space:]]*"更多"|text[[:space:]]*:[[:space:]]*"主菜单"|id[[:space:]]*:[[:space:]]*mainMenuButton' "$file" \
            && grep -qE 'onClicked[[:space:]]*:[[:space:]].*\.(open|popup)\(' "$file"
        then
            log_fail "custom-main-menu-button" "$rel: suspected custom application main-menu trigger; use DTK menu button or add waiver"
        fi
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "main-menu-without-titlebar" "$rel:$hit"
    done < <(detect_main_menu_without_titlebar_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "titlebar-menu-attachment" "$rel:$hit"
    done < <(detect_titlebar_menu_attachment_hits "$file")

    if ! grep -q 'uos-design: allow-manual-main-menu-position' "$file"; then
        if grep -qE '(^|[[:space:]])D\.Menu([[:space:]]|\{)|(^|[[:space:]])Menu([[:space:]]|\{)' "$file" \
            && grep -qE 'iconName[[:space:]]*:[[:space:]]*"menu"|text[[:space:]]*:[[:space:]]*"更多"' "$file" \
            && grep -qE '^[[:space:]]*x[[:space:]]*:' "$file" \
            && grep -qE '^[[:space:]]*y[[:space:]]*:' "$file"
        then
            log_fail "manual-main-menu-position" "$rel: suspected manual main-menu popup coordinates; follow DTK placement or add waiver"
        fi
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "custom-main-menu-icon" "$rel:$hit"
    done < <(detect_custom_main_menu_icon_hits "$file")

    if ! grep -q 'uos-design: allow-custom-about-dialog' "$file"; then
        case "$rel" in
            *AboutDialog*.qml)
                if ! grep -qE '(^|[[:space:]])D\.AboutDialog([[:space:]]|\{)' "$file"; then
                    log_fail "custom-about-dialog" "$rel: expected DTK AboutDialog for About surfaces"
                fi
                ;;
        esac
    fi

    if ! grep -q 'uos-design: allow-detailed-gauge-center-text' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "detailed-gauge-center-text" "$rel:$hit"
        done < <(detect_detailed_gauge_center_text_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "search-placeholder-inactive" "$rel:$hit"
    done < <(detect_search_placeholder_inactive_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "search-filter-ratio" "$rel:$hit"
    done < <(detect_search_filter_ratio_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "compact-list-text" "$rel:$hit"
    done < <(detect_compact_list_text_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-lane-centering" "$rel:$hit"
    done < <(detect_list_lane_centering_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "scroll-surface-inset" "$rel:$hit"
    done < <(detect_root_scroll_surface_inset_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "card-list-secondary-inset" "$rel:$hit"
    done < <(detect_card_internal_list_edge_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-row-content-host-missing" "$rel:$hit"
    done < <(detect_list_row_content_host_marker_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "placeholder-list-icon" "$rel:$hit"
    done < <(detect_placeholder_list_icon_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "gradient-card-whitespace" "$rel:$hit"
    done < <(detect_gradient_card_whitespace_hits "$file")

    if ! grep -q 'uos-design: allow-strong-card-thumbnail' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "card-structural-thumbnail-contrast" "$rel:$hit"
        done < <(detect_window_scene_preview_subdued_hits "$file")
    fi

    case "$rel" in
        qml/Theme.qml|qml/components/EqualizedCardPairBand.qml)
            ;;
        *)
            if ! grep -q 'uos-design: allow-manual-card-pair-equalization' "$file"; then
                while IFS= read -r hit; do
                    [[ -z "$hit" ]] && continue
                    log_fail "manual-card-pair-equalization" "$rel:$hit"
                done < <(detect_manual_card_pair_equalization_hits "$file")
            fi
            ;;
    esac

    if [[ "$(basename "$file")" == "WindowScenePreview.qml" ]] && ! grep -q 'uos-design: allow-thumbnail-without-border' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "thumbnail-fixed-border" "$rel:$hit"
        done < <(detect_window_scene_preview_border_hits "$file")
    fi

    if [[ "$(basename "$file")" == "WindowScenePreview.qml" ]] && ! grep -q 'uos-design: allow-strong-typography-thumbnail' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "thumbnail-strong-ink" "$rel:$hit"
        done < <(detect_window_scene_preview_strong_ink_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "status-duplication" "$rel:$hit"
    done < <(detect_status_duplication_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "option-row-icon" "$rel:$hit"
    done < <(detect_option_row_icon_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-icon-background" "$rel:$hit"
    done < <(detect_list_leading_icon_background_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "list-live-icon" "$rel:$hit"
    done < <(detect_nontruthful_live_list_icon_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "shared-functional-row-icon" "$rel:$hit"
    done < <(detect_repeated_functional_row_icon_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "shared-functional-model-icon" "$rel:$hit"
    done < <(detect_shared_functional_model_icon_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "chart-missing-axes" "$rel:$hit"
    done < <(detect_chart_missing_axes_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "chart-missing-animation" "$rel:$hit"
    done < <(detect_chart_missing_animation_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "chart-curve-style" "$rel:$hit"
    done < <(detect_chart_curve_style_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "progress-foreground-shadow" "$rel:$hit"
    done < <(detect_progress_shadow_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "ring-progress-style" "$rel:$hit"
    done < <(detect_ring_progress_style_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "unified-toolbar-height" "$rel:$hit"
    done < <(detect_unified_toolbar_height_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "unified-toolbar-divider" "$rel:$hit"
    done < <(detect_unified_toolbar_divider_hits "$file")

    if ! grep -q 'uos-design: allow-nonstandard-sidebar-toggle-icon' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "nonstandard-sidebar-toggle-icon" "$rel:$hit (use the control-center-style dedicated sidebar-toggle glyph/button, not a generic chevron or arrow)"
        done < <(detect_nonstandard_sidebar_toggle_icon_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-moving-logo-slot' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "moving-logo-slot" "$rel:$hit (keep the top-left logo in one stable window-relative slot; do not place it in the animated sidebar or toggle its slot across sidebar states)"
        done < <(detect_moving_logo_slot_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "sidebar-header-overlay" "$rel:$hit (do not draw a separate sidebar-width blur slab in the titlebar; let the sidebar surface continue under the DTK header)"
    done < <(detect_sidebar_header_overlay_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "persistent-sidebar-header-surface" "$rel:$hit (carry the left sidebar surface and right content base up under the DTK header controls; do not insert a separate full-width titleband surface)"
    done < <(detect_persistent_sidebar_header_surface_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "live-header-sampling-contract" "$rel:$hit"
    done < <(detect_live_header_sampling_contract_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "scroll-header-glass-audit-prep" "$rel:$hit"
    done < <(detect_scroll_header_glass_audit_prep_hits "$file")

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "sidebar-duplicate-branding" "$rel:$hit (keep one app logo slot in the DTK header; remove duplicate logo/title/description branding above sidebar navigation)"
    done < <(detect_sidebar_duplicate_branding_hits "$file")

    if ! grep -q 'uos-design: allow-toolbar-page-title' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "toolbar-page-title" "$rel:$hit (toolbar top bands must not show page titles by default; move page titles into the page content header unless explicitly requested)"
        done < <(detect_toolbar_page_title_hits "$file")
    fi

    if grep -qE '(^|[[:space:]])D\.Menu([[:space:]]|\{)|(^|[[:space:]])Menu([[:space:]]|\{)' "$file" \
        && grep -qE '关于|About|退出|Exit|Quit|设置|Settings|applicationMenu|mainMenu' "$file"
    then
        main_menu_candidates+=("$file")
    fi

    if [[ "$(basename "$file")" != *SettingsDialog.qml ]] && ! grep -q 'uos-design: allow-secondary-settings-entry' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            settings_button_candidates+=("$rel:$hit")
        done < <(detect_secondary_settings_entry_hits "$file")
    fi
done < <(list_qml_files)

app_store_file="$(find "$ROOT" \
    \( -path "$ROOT/.git" \
    -o -path "$ROOT/.idea" \
    -o -path "$ROOT/.vscode" \
    -o -path "$ROOT/.cache" \
    -o -path "$ROOT/.codex" \
    -o -path "$ROOT/build" \
    -o -path "$ROOT/cmake-build-debug" \
    -o -path "$ROOT/cmake-build-release" \
    -o -path "$ROOT/dist" \
    -o -path "$ROOT/node_modules" \) -prune \
    -o -type f -name 'AppStore.qml' -print -quit)"

if [[ -n "$app_store_file" ]]; then
    app_store_rel="${app_store_file#$ROOT/}"
    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "navigation-only-sidebar-card" "$app_store_rel:$hit"
    done < <(detect_navigation_only_sidebar_card_hits "$app_store_file")
fi

operational_notice_hits="$(grep_repo '解锁|付费|订阅|会员|权益|服务升级|premium|subscribe|unlock|paywall|会员服务' --include='*.qml' || true)"
if [[ -n "$operational_notice_hits" ]]; then
    sidebar_operational_dock_hits="$(grep_repo 'anchors\.bottom|Layout\.alignment[[:space:]]*:.*Qt\.AlignBottom|bottomMargin[[:space:]]*:[[:space:]]*10' --include='*Sidebar*.qml' || true)"
    if [[ -z "$sidebar_operational_dock_hits" ]]; then
        log_fail "sidebar-operational-cards-missing" "Operational unlock/pay/service notices exist in project QML but no sidebar-bottom card docking pattern was detected."
    fi
fi

theme_file="$(find "$ROOT" \
    \( -path "$ROOT/.git" \
    -o -path "$ROOT/.idea" \
    -o -path "$ROOT/.vscode" \
    -o -path "$ROOT/.cache" \
    -o -path "$ROOT/.codex" \
    -o -path "$ROOT/build" \
    -o -path "$ROOT/cmake-build-debug" \
    -o -path "$ROOT/cmake-build-release" \
    -o -path "$ROOT/dist" \
    -o -path "$ROOT/node_modules" \) -prune \
    -o -type f -name 'Theme.qml' -print -quit)"

if [[ -n "$theme_file" ]] \
    && grep -qE 'readonly property color (bg|bgPanel|bgToolbar|panelBg|titlebarBg)[[:space:]]*:' "$theme_file"
then
    theme_usage_hits="$(grep_repo 'Theme\.(bg|bgPanel|bgToolbar|panelBg|titlebarBg)([^A-Za-z0-9_]|$)' --include='*.qml' | grep -v '/Theme.qml:' || true)"
    if [[ -z "$theme_usage_hits" ]]; then
        log_fail "theme-surface-token-unused" "Theme.qml defines background surface tokens but no live QML surface consumes Theme.bg/bgPanel/bgToolbar/panelBg/titlebarBg."
    fi
fi

if [[ -n "$theme_file" ]] && ! grep -q 'uos-design: allow-theme-baseline-deviation' "$theme_file"; then
    system_accent_line="$(theme_property_line "$theme_file" 'systemAccent')"
    if [[ -z "$system_accent_line" || "$system_accent_line" != *'D.DTK.palette.highlight'* ]]; then
        log_fail "theme-system-accent" "Theme.qml: systemAccent must be sourced from D.DTK.palette.highlight."
    fi

    if [[ -z "$(theme_property_line "$theme_file" 'fgNormal')" ]]; then
        log_fail "theme-fgNormal-missing" "Theme.qml: expected fgNormal foreground baseline token."
    fi

    if [[ -z "$(theme_property_line "$theme_file" 'fgStrong')" ]]; then
        log_fail "theme-fgStrong-missing" "Theme.qml: expected fgStrong foreground baseline token."
    fi

    text_primary_line="$(theme_property_line "$theme_file" 'textPrimary')"
    if [[ -z "$text_primary_line" || "$text_primary_line" != *'fgNormal'* ]]; then
        log_fail "theme-textPrimary-baseline" "Theme.qml: textPrimary should resolve from fgNormal."
    fi

    text_strong_line="$(theme_property_line "$theme_file" 'textStrong')"
    if [[ -z "$text_strong_line" || "$text_strong_line" != *'fgStrong'* ]]; then
        log_fail "theme-textStrong-baseline" "Theme.qml: textStrong should resolve from fgStrong."
    fi

    icon_normal_line="$(theme_property_line "$theme_file" 'iconNormal')"
    if [[ -z "$icon_normal_line" || ( "$icon_normal_line" != *'fgNormal'* && "$icon_normal_line" != *'textPrimary'* ) ]]; then
        log_fail "theme-iconNormal-baseline" "Theme.qml: iconNormal should resolve from fgNormal or textPrimary."
    fi

    icon_strong_line="$(theme_property_line "$theme_file" 'iconStrong')"
    if [[ -z "$icon_strong_line" || ( "$icon_strong_line" != *'fgStrong'* && "$icon_strong_line" != *'textStrong'* ) ]]; then
        log_fail "theme-iconStrong-baseline" "Theme.qml: iconStrong should resolve from fgStrong or textStrong."
    fi

    bg_line="$(theme_property_line "$theme_file" 'bg')"
    if [[ -z "$bg_line" || "$bg_line" != *'#181818'* || "$bg_line" != *'#F8F8F8'* ]]; then
        log_fail "theme-bg-baseline" "Theme.qml: bg should stay on the documented #181818 / #F8F8F8 neutral baseline unless waived."
    fi

    sidebar_blend_line="$(theme_property_line "$theme_file" 'sidebarBlurBlend')"
    if [[ -z "$sidebar_blend_line" ]]; then
        log_fail "theme-sidebar-blend-missing" "Theme.qml: expected sidebarBlurBlend token for persistent-left-sidebar audits."
    else
        mapfile -t blur_hexes < <(printf '%s\n' "$sidebar_blend_line" | grep -oE '#[0-9A-Fa-f]{6,8}\b' || true)
        if (( ${#blur_hexes[@]} >= 2 )); then
            if ! hex_is_neutral_dark "${blur_hexes[0]}" || ! hex_alpha_is_sidebar_blend "${blur_hexes[0]}" \
                || ! hex_is_neutral_light "${blur_hexes[1]}" || ! hex_alpha_is_sidebar_blend "${blur_hexes[1]}"
            then
                log_fail "theme-sidebar-blend-baseline" "Theme.qml: sidebarBlurBlend must stay near neutral #CC101010 / #CCFFFFFF style glass, not an opaque or chromatic tint."
            fi
        elif ! printf '%s\n' "$sidebar_blend_line" | grep -qE 'Qt\.rgba\([[:space:]]*(16/255|0\.0627)[[:space:]]*,[[:space:]]*(16/255|0\.0627)[[:space:]]*,[[:space:]]*(16/255|0\.0627)[[:space:]]*,[[:space:]]*0\.8\)|Qt\.rgba\([[:space:]]*1[[:space:]]*,[[:space:]]*1[[:space:]]*,[[:space:]]*1[[:space:]]*,[[:space:]]*0\.8\)'; then
            log_fail "theme-sidebar-blend-baseline" "Theme.qml: sidebarBlurBlend must use the documented neutral ~0.80 blur tint baseline or an equivalent exact expression."
        fi
    fi

    sidebar_fallback_line="$(theme_property_line "$theme_file" 'sidebarBlurFallback')"
    if [[ -z "$sidebar_fallback_line" ]]; then
        log_fail "theme-sidebar-fallback-missing" "Theme.qml: expected sidebarBlurFallback token for persistent-left-sidebar audits."
    else
        mapfile -t fallback_hexes < <(printf '%s\n' "$sidebar_fallback_line" | grep -oE '#[0-9A-Fa-f]{6,8}\b' || true)
        if (( ${#fallback_hexes[@]} >= 2 )); then
            if ! hex_is_neutral_dark "${fallback_hexes[0]}" || ! hex_is_neutral_light "${fallback_hexes[1]}"; then
                log_fail "theme-sidebar-fallback-baseline" "Theme.qml: sidebarBlurFallback must stay near neutral #101010 / #FFFFFF style fallback tones."
            fi
        elif ! printf '%s\n' "$sidebar_fallback_line" | grep -qE '#101010|Qt\.rgba\([[:space:]]*(16/255|0\.0627)[[:space:]]*,[[:space:]]*(16/255|0\.0627)[[:space:]]*,[[:space:]]*(16/255|0\.0627)'; then
            log_fail "theme-sidebar-fallback-baseline" "Theme.qml: sidebarBlurFallback must use a documented neutral near-black / near-white fallback."
        fi
    fi
fi

if [[ -n "$(grep_repo '(^|[[:space:]])D\.(ProgressBar|Switch|CheckBox|ComboBox)([[:space:]]|\{)' --include='*.qml')" ]] \
    && [[ -n "$(grep_repo 'Theme\.(accentBackground|accentLight|surfaceHover|surfaceActive|navItemSelectedBg|cardBg)' --include='*.qml')" ]] \
    && [[ -z "$(grep_repo 'palette[[:space:]]*:|D\.Palette|accentColor|highlight|colorScheme' --include='*.qml')" ]]
then
    log_fail "dtk-palette-routing-missing" "Project uses raw DTK progress/switch/checkbox/combo-box controls alongside a custom theme layer, but no explicit DTK palette routing was found."
fi

for file in "${main_menu_candidates[@]}"; do
    rel="${file#$ROOT/}"

    if ! grep -qE '跟随系统|浅色|深色|(^|[^A-Za-z])(System|Light|Dark)([^A-Za-z]|$)|themeMenu|ThemeMenu|themeMode|Theme\.mode|setThemeMode' "$file"; then
        log_fail "main-menu-theme-switch" "$rel: suspected application main menu without System/Light/Dark theme switching"
    fi
done

if (( ${#main_menu_candidates[@]} > 0 )); then
    for hit in "${settings_button_candidates[@]}"; do
        log_fail "secondary-settings-entry" "$hit"
    done
fi

pick_default_visual_audit_window_size_manifest() {
    local candidate
    for candidate in \
        "$ROOT/scripts/uos_visual_audit_window_sizes.txt" \
        "$ROOT/config/uos_visual_audit_window_sizes.txt" \
        "$ROOT/.codex/uos_visual_audit_window_sizes.txt" \
        "$ROOT/uos_visual_audit_window_sizes.txt"
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
}

normalize_visual_audit_window_size_spec() {
    local spec
    spec="$(printf '%s' "${1-}" | tr -d '[:space:]')"
    if [[ "$spec" =~ ^[0-9]+x[0-9]+$ ]]; then
        printf '%s\n' "$spec"
        return 0
    fi
    return 1
}

load_visual_audit_window_size_manifest() {
    local manifest="$1"
    awk '
        {
            line = $0
            sub(/[[:space:]]*#.*/, "", line)
            count = split(line, parts, /,/)
            for (i = 1; i <= count; ++i) {
                part = parts[i]
                gsub(/^[[:space:]]+|[[:space:]]+$/, "", part)
                if (part != "")
                    print part
            }
        }
    ' "$manifest"
}

append_visual_audit_window_size_unique() {
    local value="$1"
    shift
    [[ -n "$value" ]] || return 0

    local existing
    for existing in "$@"; do
        if [[ "$existing" == "$value" ]]; then
            return 0
        fi
    done

    return 1
}

repo_needs_visual_audit_window_size_coverage() {
    local file
    while IFS= read -r file; do
        if awk '
            function brace_delta(s,   tmp, opens, closes) {
                tmp = s
                opens = gsub(/\{/, "{", tmp)
                closes = gsub(/\}/, "}", tmp)
                return opens - closes
            }

            function numeric_value(line, key,   text) {
                text = line
                sub(".*" key "[[:space:]]*:[[:space:]]*", "", text)
                if (match(text, /^[0-9]+/)) {
                    return substr(text, RSTART, RLENGTH) + 0
                }
                return -1
            }

            BEGIN {
                in_root = 0
                depth = 0
                width = -1
                height = -1
                minimum_width = -1
                minimum_height = -1
            }

            {
                line = $0
                delta = brace_delta(line)

                if (!in_root && line ~ /^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*\.)?(ApplicationWindow|Window)[[:space:]]*\{/) {
                    in_root = 1
                    depth = 0
                    width = -1
                    height = -1
                    minimum_width = -1
                    minimum_height = -1
                }

                if (in_root) {
                    if (depth == 1) {
                        if (line ~ /^[[:space:]]*width[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/)
                            width = numeric_value(line, "width")
                        else if (line ~ /^[[:space:]]*height[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/)
                            height = numeric_value(line, "height")
                        else if (line ~ /^[[:space:]]*minimumWidth[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/)
                            minimum_width = numeric_value(line, "minimumWidth")
                        else if (line ~ /^[[:space:]]*minimumHeight[[:space:]]*:[[:space:]]*[0-9]+([[:space:]]*(\/\/.*)?$)/)
                            minimum_height = numeric_value(line, "minimumHeight")
                    }

                    depth += delta
                    if (depth <= 0) {
                        if ((width > 0 && minimum_width > 0 && width - minimum_width >= 80) || (height > 0 && minimum_height > 0 && height - minimum_height >= 60)) {
                            print "yes"
                            exit 0
                        }
                        in_root = 0
                    }
                }
            }
        ' "$file" | grep -q '^yes$'; then
            return 0
        fi
    done < <(find "$ROOT" -type f -name '*.qml' \
        ! -path "$ROOT/build/*" \
        ! -path "$ROOT/build-codex/*" \
        ! -path "$ROOT/.git/*" \
        | sort)

    return 1
}

visual_audit_window_size_manifest="$(pick_default_visual_audit_window_size_manifest)"
visual_audit_window_size_specs=()
if [[ -n "${UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZES:-}" ]]; then
    IFS=',' read -r -a raw_visual_audit_window_size_specs <<<"$UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZES"
    for spec in "${raw_visual_audit_window_size_specs[@]}"; do
        normalized_spec="$(normalize_visual_audit_window_size_spec "$spec" || true)"
        [[ -n "$normalized_spec" ]] || continue
        if ! append_visual_audit_window_size_unique "$normalized_spec" "${visual_audit_window_size_specs[@]}"; then
            visual_audit_window_size_specs+=("$normalized_spec")
        fi
    done
elif [[ -n "$visual_audit_window_size_manifest" ]]; then
    mapfile -t manifest_visual_audit_window_size_specs < <(load_visual_audit_window_size_manifest "$visual_audit_window_size_manifest")
    for spec in "${manifest_visual_audit_window_size_specs[@]}"; do
        normalized_spec="$(normalize_visual_audit_window_size_spec "$spec" || true)"
        [[ -n "$normalized_spec" ]] || continue
        if ! append_visual_audit_window_size_unique "$normalized_spec" "${visual_audit_window_size_specs[@]}"; then
            visual_audit_window_size_specs+=("$normalized_spec")
        fi
    done
fi

if [[ -n "$(grep_repo 'UOS_DESIGN_VISUAL_AUDIT' --include='*.cpp' --include='*.cc' --include='*.cxx' --include='*.h' --include='*.hpp')" ]] \
    && repo_needs_visual_audit_window_size_coverage \
    && (( ${#visual_audit_window_size_specs[@]} == 0 ))
then
    log_fail "runtime-window-size-coverage-missing" "Repo appears resizable between its default and minimum window sizes but no repo-local visual-audit window-size manifest or UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZES was supplied."
fi

visual_audit_binary_name="$(detect_cmake_project_binary_name)"
visual_audit_executable="$(detect_visual_audit_executable "$visual_audit_binary_name")"
if [[ -n "$visual_audit_executable" ]] \
    && [[ -n "$(grep_repo 'UOS_DESIGN_VISUAL_AUDIT' --include='*.cpp' --include='*.cc' --include='*.cxx' --include='*.h' --include='*.hpp')" ]]
then
    run_visual_audit_capture() {
        local scene_key="${1-}"
        local window_size="${2-}"
        local -a env_args=(UOS_DESIGN_VISUAL_AUDIT=1)

        if [[ -n "$scene_key" ]]; then
            env_args+=(UOS_DESIGN_VISUAL_AUDIT_SCENE_KEY="$scene_key")
        fi
        if [[ -n "$window_size" ]]; then
            env_args+=(UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZE="$window_size")
        fi

        if command -v timeout >/dev/null 2>&1; then
            timeout 30s env "${env_args[@]}" "$visual_audit_executable" 2>&1 || true
        else
            env "${env_args[@]}" "$visual_audit_executable" 2>&1 || true
        fi
    }

    visual_audit_output="$(run_visual_audit_capture)"

    default_visual_audit_scene_keys="controls-lab,dialog-lab,typography-content,grouped-sidebar,flat-sidebar,detail-content,data-content,empty-state"
    if [[ ${UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS+x} ]]; then
        visual_audit_scene_spec="$UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS"
    else
        visual_audit_scene_spec="$default_visual_audit_scene_keys"
    fi

    if [[ -n "$visual_audit_scene_spec" ]]; then
        IFS=',' read -r -a visual_audit_scene_keys <<<"$visual_audit_scene_spec"
        for scene_key in "${visual_audit_scene_keys[@]}"; do
            scene_key="$(printf '%s' "$scene_key" | tr -d '[:space:]')"
            [[ -n "$scene_key" ]] || continue
            visual_audit_output+=$'\n'
            visual_audit_output+="$(run_visual_audit_capture "$scene_key")"
        done
    fi

    if (( ${#visual_audit_window_size_specs[@]} > 0 )); then
        for window_size in "${visual_audit_window_size_specs[@]}"; do
            visual_audit_output+=$'\n'
            visual_audit_output+="$(run_visual_audit_capture "" "$window_size")"
            if [[ -n "$visual_audit_scene_spec" ]]; then
                for scene_key in "${visual_audit_scene_keys[@]}"; do
                    scene_key="$(printf '%s' "$scene_key" | tr -d '[:space:]')"
                    [[ -n "$scene_key" ]] || continue
                    visual_audit_output+=$'\n'
                    visual_audit_output+="$(run_visual_audit_capture "$scene_key" "$window_size")"
                done
            fi
        done
    fi

    while IFS= read -r line; do
        [[ "$line" == VISUAL_AUDIT_FAIL\ \[* ]] || continue
        code="${line#VISUAL_AUDIT_FAIL [}"
        code="${code%%]*}"
        detail="${line#*] }"
        log_fail "$code" "$detail"
    done <<<"$visual_audit_output"
fi

if (( findings )); then
    printf 'UOS design audit failed with %d finding(s).\n' "$findings" >&2
    exit 1
fi

echo "UOS design audit passed: no findings."
