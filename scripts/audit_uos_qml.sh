#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<'EOF'
Usage: audit_uos_qml.sh [repo-root]

Heuristic audit for UOS/Deepin QML desktop projects.
It reports blocking findings for:
- missing DTK imports/build hooks when DTK is installed locally
- misuse of locally exported DTK controls such as rebuilding window buttons despite local WindowButtonGroup
- WindowButtonGroup clusters offset away from the actual top-right edge
- forced non-DTK global styles
- frameless top-level windows without waivers
- transparent top-level windows without an explicit theme-backed base surface
- full-window opaque base surfaces placed underneath blurred persistent sidebars
- Popup.Window usage without waivers
- full-width D.TitleBar in persistent-left-sidebar applications
- sidebar components that never establish an explicit sidebar panel surface
- full-window blur in persistent-left-sidebar applications without waivers
- page skeletons that never consume theme background tokens
- theme background tokens defined but never used by live surfaces
- duplicate self-drawn tint overlays above DTK/system blur surfaces without waivers
- reusable container implicitHeight contracts derived from anchored plain Item wrappers
- self-referential property bindings inside delegates or row primitives
- fake table screens with separate header/row width plans
- DTK controls left on default palette while the project uses a separate custom theme layer
- application main menus missing `System` / `Light` / `Dark` theme switching
- repeated trailing-control rows that do not expose a dedicated right-side control slot
- shadowed delegate role names that can blank or corrupt repeated rows
- multi-line list rows that omit the required leading icon or use a nonstandard icon size
- standalone in-content settings buttons when the app already exposes a main menu
- oversized card shells with obviously large fixed heights
- action buttons with uncapped or oversized widths
- explicit horizontal-scrolling list/table patterns in primary desktop surfaces
- dense icon/text/button clusters with explicit zero spacing
- selected sidebar items that add a border or outline
- persistent-sidebar collapse toggles that use generic chevrons or arrows
- moving or duplicated top-left logo slots across sidebar expand/collapse
- unified-toolbar page titles that were not explicitly requested
- detailed center text inside rings, gauges, or chart-center overlays
- oversized default desktop window shells
- undersized DTK settings dialogs
- theme baselines that drift away from the documented neutral DTK/UOS palette
- sidebar blur tint values that are too opaque or too chromatic to read as control-center-like glass
- circular score widgets with fixed large typography consumed below their safe size
- app-side top-level window decoration tuning for radius, border, or shadow
- hex color literals outside Theme.qml without waivers
- interactive icon tint using Theme.textMuted without waivers
- DTK controls with replaced structural templates without waivers
- custom in-app notifications without waivers
- rasterized functional-icon pipelines without waivers
- inline derived navigation colors in sidebar/nav files without waivers
- custom main-menu triggers without waivers
- manual main-menu popup coordinates without waivers
- custom About dialogs without waivers
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
        --exclude-dir=cmake-build-debug \
        --exclude-dir=cmake-build-release \
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
        -o -path "$ROOT/cmake-build-debug" \
        -o -path "$ROOT/cmake-build-release" \
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
        -o -path "$ROOT/cmake-build-debug" \
        -o -path "$ROOT/cmake-build-release" \
        -o -path "$ROOT/dist" \
        -o -path "$ROOT/node_modules" \) -prune \
        -o -type f \( -name '*.cpp' -o -name '*.cc' -o -name '*.cxx' -o -name '*.h' -o -name '*.hpp' \) -print0
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
            in_blur = 0
            blur_depth = 0
            watch_after_blur = 0
            in_rect = 0
            rect_depth = 0
            rect_fill_parent = 0
            rect_color = ""
            rect_color_line = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_blur && line ~ /StyledBehindWindowBlur[[:space:]]*\{/) {
                in_blur = 1
                blur_depth = delta
                watch_after_blur = 48
                next
            }

            if (in_blur) {
                blur_depth += delta
                if (blur_depth <= 0) {
                    in_blur = 0
                }
                watch_after_blur = 48
                next
            }

            if (watch_after_blur > 0) {
                if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                    in_rect = 1
                    rect_depth = delta
                    rect_fill_parent = 0
                    rect_color = ""
                    rect_color_line = 0
                    next
                }

                if (in_rect) {
                    if (rect_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                        rect_fill_parent = 1
                    }
                    if (rect_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:/) {
                        rect_color = line
                        rect_color_line = NR
                    }

                    rect_depth += delta
                    if (rect_depth <= 0) {
                        if (rect_fill_parent && rect_color_line > 0 && rect_color !~ /transparent/) {
                            print rect_color_line ":" rect_color
                        }
                        in_rect = 0
                    }
                    next
                }

                watch_after_blur--
            }
        }
    ' "$file"
}

detect_sidebar_blur_covered_by_base_surface_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            nest = 0
            in_rect = 0
            rect_depth = 0
            rect_parent_nest = 0
            rect_fill_parent = 0
            rect_color_line = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                in_rect = 1
                rect_depth = delta
                rect_parent_nest = nest
                rect_fill_parent = 0
                rect_color_line = 0
                nest += delta
                next
            }

            if (in_rect) {
                if (rect_depth == 1 && line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                    rect_fill_parent = 1
                }
                if (rect_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:[[:space:]]*Theme\.(bg|bgPanel|bgToolbar|surface|panelBg|titlebarBg)([^A-Za-z0-9_]|$)/) {
                    rect_color_line = NR
                    rect_color_text = line
                }

                rect_depth += delta
                nest += delta
                if (rect_depth <= 0) {
                    if (rect_parent_nest <= 2 && rect_fill_parent && rect_color_line > 0) {
                        print rect_color_line ":" rect_color_text
                    }
                    in_rect = 0
                }
                next
            }

            nest += delta
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
            if ($0 ~ /^[[:space:]]*D\.(Switch|CheckBox|ComboBox|Button|TextField|Menu|Dialog|ProgressBar)[[:space:]]*\{/) {
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
            if ($0 ~ /^[[:space:]]*((D\.)?ApplicationWindow|Window)[[:space:]]*\{/) {
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

detect_full_window_blur_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_blur = 0
            blur_depth = 0
            blur_start = 0
            blur_fill_parent = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_blur && line ~ /StyledBehindWindowBlur[[:space:]]*\{/) {
                in_blur = 1
                blur_depth = 0
                blur_start = NR
                blur_fill_parent = 0
            }

            if (in_blur) {
                if (line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                    blur_fill_parent = 1
                }

                blur_depth += delta
                if (blur_depth <= 0) {
                    if (blur_fill_parent) {
                        print blur_start ": StyledBehindWindowBlur fills parent"
                    }
                    in_blur = 0
                }
            }
        }
    ' "$file"
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
                    if (has_multiline && leading_width > 0 && leading_width != 24 && leading_width != 32) {
                        printf "%s: multi-line SettingRow uses leadingWidth %d; expected 24 or 32 icon baseline\n", start, leading_width
                    }
                    in_row = 0
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
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_button && line ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/) {
                in_button = 1
                depth = 0
                start = NR
                has_fill = 0
                has_max = 0
                wide_width = -1
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
                    if (wide_width > 0) {
                        printf "%s: button width %d exceeds the capped-width baseline\n", start, wide_width
                    }
                    if (has_fill && !has_max) {
                        printf "%s: fill-width button lacks maximumWidth or Layout.maximumWidth\n", start
                    }
                    in_button = 0
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

detect_sidebar_selected_border_hits() {
    local file="$1"
    grep -nE 'border\.(color|width)[[:space:]]*:[[:space:]].*(current(Index)?|selected|checked|active)' "$file" || true
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

detect_nonstandard_sidebar_toggle_icon_hits() {
    local file="$1"
    if grep -qE 'collapseRequested|toggleSidebar|sidebarHidden|setSidebarWidth' "$file"; then
        grep -nE 'icon\.source[[:space:]]*:[[:space:]]*".*(chevron-(left|right)|arrow-(left|right)|go-(previous|next)|caret-(left|right)|angle-(left|right)).*"' "$file" || true
    fi
}

detect_moving_logo_slot_hits() {
    local file="$1"
    {
        case "$(basename "$file")" in
            *Sidebar*.qml)
                grep -nE 'AppLogo[[:space:]]*\{' "$file" || true
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
                in_logo = 0
                depth = 0
            }

            {
                line = $0
                delta = brace_delta(line)

                if (!in_logo && line ~ /^[[:space:]]*AppLogo[[:space:]]*\{/) {
                    in_logo = 1
                    depth = 0
                }

                if (in_logo) {
                    if (line ~ /(visible|opacity|x|width|Layout\.preferredWidth|anchors\.leftMargin|anchors\.horizontalCenterOffset)[[:space:]]*:.*sidebar(Hidden|Width)/) {
                        print NR ":" line
                    }
                    depth += delta
                    if (depth <= 0)
                        in_logo = 0
                }
            }
        ' "$file"
    } | awk '!seen[$0]++'
}

detect_toolbar_page_title_hits() {
    local file="$1"
    if grep -qE 'D\.WindowButtonGroup|D\.ThemeMenu|ThemeMenu|WindowButtonGroup' "$file"; then
        grep -nE 'text[[:space:]]*:[[:space:]]*(currentItem\.title|currentPageTitle|pageTitle|headerTitle|currentTitle|AppStore\.[A-Za-z0-9_]*title|AppStore\.navigationItems.*title)' "$file" || true
    fi
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
            if grep -qE '^[[:space:]]*D\.TitleBar[[:space:]]*\{' "$file"; then
                log_fail "full-width-titlebar-sidebar-app" "$rel: persistent-left-sidebar apps must use full-window left-right split instead of a full-width D.TitleBar"
            fi
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "full-window-blur-sidebar-app" "$rel:$hit"
            done < <(detect_full_window_blur_hits "$file")
        fi
    fi

    case "$rel" in
        *Sidebar*.qml)
            if [[ "$(file_has_root_item "$file")" == "yes" ]] \
                && grep -q 'ListView' "$file" \
                && ! grep -q 'StyledBehindWindowBlur' "$file" \
                && [[ "$(file_has_fill_parent_rectangle "$file")" != "yes" ]]
            then
                log_fail "sidebar-panel-surface-missing" "$rel: sidebar component renders navigation content but never establishes an explicit sidebar panel surface"
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

    if ! grep -q 'uos-design: allow-manual-blur-overlay' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "manual-blur-overlay" "$rel:$hit"
        done < <(detect_manual_blur_overlay_hits "$file")
    fi

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

    if ! grep -q 'uos-design: allow-nonstandard-list-icon-size' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "multiline-list-icon-size" "$rel:$hit"
        done < <(detect_multiline_setting_row_icon_size_hits "$file")
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
            && grep -qE '(^|[[:space:]])(AppSwitch|D\.Switch|Switch|D\.CheckBox|CheckBox|D\.ComboBox|ComboBox)([[:space:]]|\{)' "$file" \
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

    if ! grep -q 'uos-design: allow-wide-button' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "wide-button" "$rel:$hit"
        done < <(detect_wide_button_hits "$file")
    fi

    if ! grep -q 'uos-design: allow-horizontal-list-scroll' "$file"; then
        while IFS= read -r hit; do
            [[ -z "$hit" ]] && continue
            log_fail "horizontal-list-scroll" "$rel:$hit"
        done < <(detect_horizontal_scroll_risk_hits "$file")
    fi

    while IFS= read -r hit; do
        [[ -z "$hit" ]] && continue
        log_fail "dense-cluster-zero-spacing" "$rel:$hit"
    done < <(detect_dense_cluster_zero_spacing_hits "$file")

    if ! grep -q 'uos-design: allow-custom-in-app-notification' "$file"; then
        case "$rel" in
            *Toast*.qml)
                if ! grep -qE '(^|[[:space:]])D\.FloatingMessage([[:space:]]|\{)' "$file"; then
                    log_fail "custom-in-app-notification" "$rel: expected DTK FloatingMessage for in-app notifications"
                fi
                ;;
        esac
    fi

    if ! grep -q 'uos-design: allow-dtk-template-override' "$file"; then
        if [[ "$(file_has_root_dtk_template_control "$file")" == "yes" ]]; then
            while IFS= read -r hit; do
                [[ -z "$hit" ]] && continue
                log_fail "dtk-template-override" "$rel:$hit"
            done < <(grep -nE '^[[:space:]]*(background|contentItem|indicator|handle|popup|delegate)[[:space:]]*:' "$file" || true)
        fi
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
        if grep -qE '(^|[[:space:]])(AppButton|Button|QQC\.Button)([[:space:]]|\{)' "$file" \
            && grep -qE 'iconName[[:space:]]*:[[:space:]]*"menu"|text[[:space:]]*:[[:space:]]*"更多"|text[[:space:]]*:[[:space:]]*"主菜单"|id[[:space:]]*:[[:space:]]*mainMenuButton' "$file" \
            && grep -qE 'onClicked[[:space:]]*:[[:space:]].*\.(open|popup)\(' "$file"
        then
            log_fail "custom-main-menu-button" "$rel: suspected custom application main-menu trigger; use DTK menu button or add waiver"
        fi
    fi

    if ! grep -q 'uos-design: allow-manual-main-menu-position' "$file"; then
        if grep -qE '(^|[[:space:]])D\.Menu([[:space:]]|\{)|(^|[[:space:]])Menu([[:space:]]|\{)' "$file" \
            && grep -qE 'iconName[[:space:]]*:[[:space:]]*"menu"|text[[:space:]]*:[[:space:]]*"更多"' "$file" \
            && grep -qE '^[[:space:]]*x[[:space:]]*:' "$file" \
            && grep -qE '^[[:space:]]*y[[:space:]]*:' "$file"
        then
            log_fail "manual-main-menu-position" "$rel: suspected manual main-menu popup coordinates; follow DTK placement or add waiver"
        fi
    fi

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

if (( findings )); then
    printf 'UOS design audit failed with %d finding(s).\n' "$findings" >&2
    exit 1
fi

echo "UOS design audit passed: no findings."
