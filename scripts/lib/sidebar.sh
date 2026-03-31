# shellcheck shell=bash

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
            nest = 0
            in_blur = 0
            blur_depth = 0
            blur_start = 0
            blur_parent_nest = 0
            blur_fill_parent = 0
            blur_control = ""
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_blur && line ~ /StyledBehindWindowBlur[[:space:]]*\{/) {
                in_blur = 1
                blur_depth = 0
                blur_start = NR
                blur_parent_nest = nest
                blur_fill_parent = 0
                blur_control = ""
            }

            if (in_blur) {
                if (line ~ /anchors\.fill[[:space:]]*:[[:space:]]*parent/) {
                    blur_fill_parent = 1
                }
                if (blur_depth == 1 && line ~ /^[[:space:]]*control[[:space:]]*:/) {
                    blur_control = line
                }

                blur_depth += delta
                nest += delta
                if (blur_depth <= 0) {
                    if (blur_fill_parent && blur_parent_nest <= 2 && blur_control !~ /sidebar|headerSidebarSurface|leftPanel|sidebarSurface/i) {
                        print blur_start ": StyledBehindWindowBlur fills parent"
                    }
                    in_blur = 0
                }
                next
            }

            nest += delta
        }
    ' "$file"
}

detect_sidebar_selected_border_hits() {
    local file="$1"
    grep -nE 'border\.(color|width)[[:space:]]*:[[:space:]].*(current(Index)?|selected|checked|active)' "$file" || true
}

detect_sidebar_nav_icon_treatment_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function extract_selected_theme_token(s,   token) {
            token = s
            if (token !~ /\?[[:space:]]*Theme\.[A-Za-z0-9_]+/)
                return ""
            sub(/.*\?[[:space:]]*Theme\./, "", token)
            sub(/[^A-Za-z0-9_].*/, "", token)
            return token
        }

        function reset_rect() {
            in_rect = 0
            rect_depth = 0
            rect_has_svg = 0
            rect_color = ""
            rect_color_line = 0
        }

        function reset_nav() {
            in_nav = 0
            nav_depth = 0
            nav_start = 0
            icon_selected = ""
            label_selected = ""
            in_icon = 0
            icon_depth = 0
            in_label = 0
            label_depth = 0
            reset_rect()
        }

        BEGIN {
            reset_nav()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_nav && line ~ /delegate[[:space:]]*:[[:space:]]*Rectangle[[:space:]]*\{/) {
                in_nav = 1
                nav_depth = 0
                nav_start = NR
                icon_selected = ""
                label_selected = ""
                in_icon = 0
                icon_depth = 0
                in_label = 0
                label_depth = 0
                reset_rect()
            }

            if (in_nav) {
                if (!in_rect && nav_depth >= 1 && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                    in_rect = 1
                    rect_depth = 0
                    rect_has_svg = 0
                    rect_color = ""
                    rect_color_line = 0
                }

                if (in_rect) {
                    if (line ~ /SvgIcon[[:space:]]*\{/)
                        rect_has_svg = 1
                    if (rect_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:/) {
                        rect_color = line
                        rect_color_line = NR
                    }

                    rect_depth += delta
                    if (rect_depth <= 0) {
                        if (rect_has_svg && rect_color_line > 0 && rect_color !~ /transparent/)
                            printf "%s: sidebar navigation item icon must not draw its own background tile\n", rect_color_line
                        reset_rect()
                    }
                }

                if (!in_icon && line ~ /^[[:space:]]*SvgIcon[[:space:]]*\{/) {
                    in_icon = 1
                    icon_depth = 0
                }

                if (in_icon) {
                    if (icon_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:/ && icon_selected == "")
                        icon_selected = extract_selected_theme_token(line)

                    icon_depth += delta
                    if (icon_depth <= 0) {
                        in_icon = 0
                        icon_depth = 0
                    }
                }

                if (!in_label && line ~ /^[[:space:]]*D\.Label[[:space:]]*\{/) {
                    in_label = 1
                    label_depth = 0
                }

                if (in_label) {
                    if (label_depth == 1 && line ~ /^[[:space:]]*color[[:space:]]*:/ && label_selected == "")
                        label_selected = extract_selected_theme_token(line)

                    label_depth += delta
                    if (label_depth <= 0) {
                        in_label = 0
                        label_depth = 0
                    }
                }

                nav_depth += delta
                if (nav_depth <= 0) {
                    if (icon_selected != "" && label_selected != "" && icon_selected != label_selected)
                        printf "%s: selected sidebar icon color must match selected sidebar text color\n", nav_start
                    reset_nav()
                }
            }
        }
    ' "$file"
}

detect_centered_sidebar_list_content_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_text = 0
            text_depth = 0
            text_start = 0
            in_cluster = 0
            cluster_depth = 0
            cluster_start = 0
            cluster_has_text = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_text && line ~ /^[[:space:]]*(Text|D\.Label)[[:space:]]*\{/) {
                in_text = 1
                text_depth = 0
                text_start = NR
            }

            if (in_text) {
                if (text_depth == 1) {
                    if (line ~ /^[[:space:]]*horizontalAlignment[[:space:]]*:[[:space:]]*Text\.Align(HCenter|Center)/)
                        printf "%s: sidebar list text must stay left-aligned instead of center-aligned\n", text_start
                    if (line ~ /^[[:space:]]*anchors\.horizontalCenter[[:space:]]*:/)
                        printf "%s: sidebar list text must stay on the left content lane instead of centering itself\n", text_start
                    if (line ~ /^[[:space:]]*Layout\.alignment[[:space:]]*:.*(Qt\.)?Align(HCenter|Center)/)
                        printf "%s: sidebar list text must not use centered layout alignment\n", text_start
                }

                text_depth += delta
                if (text_depth <= 0) {
                    in_text = 0
                    text_depth = 0
                }
            }

            if (!in_cluster && line ~ /^[[:space:]]*(Row|RowLayout|Column|ColumnLayout)[[:space:]]*\{/) {
                in_cluster = 1
                cluster_depth = 0
                cluster_start = NR
                cluster_has_text = 0
            }

            if (in_cluster) {
                if (line ~ /^[[:space:]]*(Text|D\.Label)[[:space:]]*\{/)
                    cluster_has_text = 1

                if (cluster_depth == 1 && cluster_has_text) {
                    if (line ~ /^[[:space:]]*(anchors\.horizontalCenter|horizontalCenterOffset)[[:space:]]*:/)
                        printf "%s: sidebar list icon-text cluster must stay left-aligned inside the centered row background\n", cluster_start
                    if (line ~ /^[[:space:]]*Layout\.alignment[[:space:]]*:.*(Qt\.)?Align(HCenter|Center)/)
                        printf "%s: sidebar list icon-text cluster must not use centered layout alignment\n", cluster_start
                }

                cluster_depth += delta
                if (cluster_depth <= 0) {
                    in_cluster = 0
                    cluster_depth = 0
                    cluster_has_text = 0
                }
            }
        }
    ' "$file"
}

detect_sidebar_noninteractive_row_hits() {
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
            has_sidebar_row_name = 0
            has_interaction = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_block && line ~ /^[[:space:]]*(Rectangle|Item|Control|Pane|Frame|AbstractButton|Button|D\.[A-Za-z0-9_]+)[[:space:]]*\{/) {
                in_block = 1
                depth = 0
                start = NR
                has_sidebar_row_name = 0
                has_interaction = 0
            }

            if (in_block) {
                if (line ~ /objectName[[:space:]]*:[[:space:]]*.*sidebarRow/)
                    has_sidebar_row_name = 1

                if (line ~ /^[[:space:]]*(MouseArea|TapHandler)[[:space:]]*\{/ \
                    || line ~ /[[:space:]]onClicked[[:space:]]*:/ \
                    || line ~ /[[:space:]]onTapped[[:space:]]*:/ \
                    || line ~ /^[[:space:]]*(ItemDelegate|D\.ItemDelegate|D\.Button|D\.ToolButton|Button|AbstractButton)[[:space:]]*\{/) {
                    has_interaction = 1
                }

                depth += delta
                if (depth <= 0) {
                    if (has_sidebar_row_name && !has_interaction)
                        printf "%s: sidebar navigation row lacks a real click/tap target\n", start
                    in_block = 0
                    depth = 0
                }
            }
        }
    ' "$file"
}

detect_sidebar_operational_button_width_hits() {
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
            has_width = 0
            has_max = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_button && line ~ /^[[:space:]]*((D\.)?(Button|RecommandButton|WarningButton)|QQC\.Button|Button)[[:space:]]*\{/) {
                in_button = 1
                depth = 0
                start = NR
                has_fill = 0
                has_width = 0
                has_max = 0
            }

            if (in_button) {
                if (depth == 1 && line ~ /^[[:space:]]*Layout\.fillWidth[[:space:]]*:[[:space:]]*true/)
                    has_fill = 1
                if (depth == 1 && line ~ /^[[:space:]]*width[[:space:]]*:[[:space:]].*(parent|root|contentColumn|contentLayout)\.width/)
                    has_width = 1
                if (depth == 1 && line ~ /^[[:space:]]*(Layout\.maximumWidth|maximumWidth)[[:space:]]*:/)
                    has_max = 1

                depth += delta
                if (depth <= 0) {
                    if (!has_fill && !has_width) {
                        printf "%s: sidebar operational-card button should maximize the usable card width\n", start
                    } else if (has_fill && !has_max) {
                        printf "%s: fill-width sidebar operational-card button should declare a maximum width equal to the usable card width\n", start
                    }
                    in_button = 0
                }
            }
        }
    ' "$file"
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
    if ! grep -qE 'StyledBehindWindowBlur|sidebarWidth|sidebarShell|sidebarHost|onCollapseRequested' "$file"; then
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
            in_titlebar = 0
            titlebar_depth = 0
            in_label = 0
            label_depth = 0
            label_start = 0
            label_has_text = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /^[[:space:]]*(header[[:space:]]*:[[:space:]]*)?D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                titlebar_depth = 0
            }

            if (in_titlebar) {
                if (!in_label && line ~ /^[[:space:]]*(QQC2\.Label|D\.Label|Label|Text)[[:space:]]*\{/) {
                    in_label = 1
                    label_depth = 0
                    label_start = NR
                    label_has_text = 0
                }

                if (in_label) {
                    if (label_depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:/)
                        label_has_text = 1

                    label_depth += delta
                    if (label_depth <= 0) {
                        if (label_has_text)
                            printf "%s: DTK header contains a text label in a control-center-style persistent-sidebar window\n", label_start
                        in_label = 0
                    }
                }

                titlebar_depth += delta
                if (titlebar_depth <= 0)
                    in_titlebar = 0
            }
        }
    ' "$file"
}

detect_persistent_sidebar_header_surface_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE 'StyledBehindWindowBlur|sidebarWidth|sidebarShell|sidebarHost|onCollapseRequested' "$file"; then
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
            in_titlebar = 0
            titlebar_depth = 0
            titlebar_start = 0
            has_titlebar_blur = 0
            has_content_surface = 0
            has_full_band_surface = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /^[[:space:]]*(header[[:space:]]*:[[:space:]]*)?D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                titlebar_depth = 0
                titlebar_start = NR
                has_titlebar_blur = 0
                has_content_surface = 0
                has_full_band_surface = 0
            }

            if (in_titlebar) {
                if (line ~ /StyledBehindWindowBlur[[:space:]]*\{/)
                    has_titlebar_blur = 1
                if (line ~ /color[[:space:]]*:[[:space:]]*Theme\.(bg|panelBg|bgPanel)([^A-Za-z0-9_]|$)/)
                    has_content_surface = 1
                if (line ~ /color[[:space:]]*:[[:space:]]*Theme\.(bgToolbar|titlebarBg)([^A-Za-z0-9_]|$)/)
                    has_full_band_surface = 1

                titlebar_depth += delta
                if (titlebar_depth <= 0) {
                    if (has_full_band_surface || !has_content_surface || !has_titlebar_blur)
                        printf "%s: persistent-sidebar DTK header must keep the left sidebar surface and right content base visually continuous up to the top edge\n", titlebar_start
                    in_titlebar = 0
                }
            }
        }
    ' "$file"
}

detect_sidebar_header_overlay_hits() {
    local file="$1"
    if [[ "$(file_has_root_application_window "$file")" != "yes" ]]; then
        return
    fi

    if ! grep -qE 'StyledBehindWindowBlur|sidebarWidth|sidebarShell|sidebarHost|onCollapseRequested' "$file"; then
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
            in_titlebar = 0
            titlebar_depth = 0
            titlebar_start = 0
            has_titlebar_blur = 0
            has_sidebar_width_surface = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_titlebar && line ~ /^[[:space:]]*(header[[:space:]]*:[[:space:]]*)?D\.TitleBar[[:space:]]*\{/) {
                in_titlebar = 1
                titlebar_depth = 0
                titlebar_start = NR
                has_titlebar_blur = 0
                has_sidebar_width_surface = 0
            }

            if (in_titlebar) {
                if (line ~ /StyledBehindWindowBlur[[:space:]]*\{/)
                    has_titlebar_blur = 1
                if (line ~ /(width|implicitWidth|Layout\.preferredWidth)[[:space:]]*:[[:space:]]*.*sidebarWidth([^A-Za-z0-9_]|$)/)
                    has_sidebar_width_surface = 1

                titlebar_depth += delta
                if (titlebar_depth <= 0) {
                    if (has_titlebar_blur && has_sidebar_width_surface)
                        printf "%s: titlebar draws a separate sidebar-width blur slab instead of letting the sidebar surface continue under the header\n", titlebar_start
                    in_titlebar = 0
                }
            }
        }
    ' "$file"
}

detect_sidebar_duplicate_branding_hits() {
    local file="$1"
    if ! grep -qE 'StyledBehindWindowBlur|sidebarWidth|sidebarShell|sidebarHost|onCollapseRequested' "$file"; then
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
            search_seen = 0
            in_label = 0
            label_depth = 0
            has_logo = 0
            logo_line = 0
            label_text_count = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!search_seen && line ~ /(D\.)?SearchEdit[[:space:]]*\{/) {
                search_seen = 1
            }

            if (!search_seen) {
                if (!has_logo && line ~ /(logo-mark\.svg|AppLogo[[:space:]]*\{|icon\.name[[:space:]]*:[[:space:]]*["'\''][A-Za-z0-9_.-]+["'\''])/) {
                    has_logo = 1
                    logo_line = NR
                }

                if (!in_label && line ~ /^[[:space:]]*(QQC2\.Label|D\.Label|Label|Text)[[:space:]]*\{/) {
                    in_label = 1
                    label_depth = 0
                }

                if (in_label) {
                    if (label_depth == 1 && line ~ /^[[:space:]]*text[[:space:]]*:/)
                        label_text_count++

                    label_depth += delta
                    if (label_depth <= 0)
                        in_label = 0
                }
            }
        }

        END {
            if (search_seen && has_logo && label_text_count >= 2)
                printf "%s: sidebar duplicates application branding above navigation instead of keeping one logo slot in the DTK header\n", logo_line
        }
    ' "$file"
}

detect_sidebar_gap_hits() {
    local file="$1"
    grep -nE 'anchors\.left[[:space:]]*:[[:space:]]*(sidebarResizeHandle|sidebarSplitter|splitter|divider|separator)[A-Za-z0-9_]*\.right' "$file" || true
}

file_has_sidebar_edge_divider() {
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
            depth = 0
            has_right = 0
            has_width = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_rect && line ~ /^[[:space:]]*Rectangle[[:space:]]*\{/) {
                in_rect = 1
                depth = 0
                has_right = 0
                has_width = 0
            }

            if (in_rect) {
                if (depth == 1 && line ~ /anchors\.right[[:space:]]*:[[:space:]]*parent\.right/)
                    has_right = 1
                if (depth == 1 && line ~ /^[[:space:]]*width[[:space:]]*:[[:space:]]*1([[:space:]]*(\/\/.*)?$)/)
                    has_width = 1

                depth += delta
                if (depth <= 0) {
                    if (has_right && has_width) {
                        print "yes"
                        exit
                    }
                    in_rect = 0
                }
            }
        }
    ' "$file"
}

detect_single_group_sidebar_header_hits() {
    local file="$1"
    if grep -q 'ListView' "$file" \
        && ! grep -qE 'navigationGroups|groupModel|section\.delegate|section\.property|groupTitle|groupHeader|groupSpacing' "$file"
    then
        grep -nE 'text[[:space:]]*:[[:space:]]*"(应用导航|导航|分组|常用|全部)"' "$file" || true
    fi
}

detect_sidebar_group_spacing_hits() {
    local file="$1"
    if grep -qE 'navigationGroups|groupModel|section\.delegate|groupTitle|groupHeader|groupSpacing' "$file" \
        && ! grep -qE 'spacing[[:space:]]*:[[:space:]].*(20|Theme\.spacingL)([^A-Za-z0-9_]|$)' "$file"
    then
        printf '1: multi-group sidebar is missing the required 20px inter-group spacing\n'
    fi
}

detect_navigation_only_sidebar_card_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        BEGIN {
            in_cards = 0
            cards_depth = 0
            current_key = ""
            in_handler = 0
            handler_depth = 0
            branch_key = ""
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_cards && line ~ /readonly[[:space:]]+property[[:space:]]+var[[:space:]]+sidebarOperationCards[[:space:]]*:[[:space:]]*\{/) {
                in_cards = 1
                cards_depth = 0
                current_key = ""
            }

            if (in_cards) {
                if (line ~ /key[[:space:]]*:[[:space:]]*"[^"]+"/) {
                    current_key = line
                    sub(/.*key[[:space:]]*:[[:space:]]*"/, "", current_key)
                    sub(/".*/, "", current_key)
                }
                if (current_key != "" && line ~ /actionText[[:space:]]*:[[:space:]]*"(查看|打开|前往|进入|跳转)/) {
                    nav_card[current_key] = NR
                }

                cards_depth += delta
                if (cards_depth <= 0) {
                    in_cards = 0
                    current_key = ""
                }
            }

            if (!in_handler && line ~ /function[[:space:]]+handleSidebarOperationCard[[:space:]]*\(/) {
                in_handler = 1
                handler_depth = 0
                branch_key = ""
            }

            if (in_handler) {
                if (line ~ /cardKey[[:space:]]*===?[[:space:]]*"[^"]+"/) {
                    branch_key = line
                    sub(/.*cardKey[[:space:]]*===?[[:space:]]*"/, "", branch_key)
                    sub(/".*/, "", branch_key)
                }

                if (branch_key != "" && line ~ /navigate[[:space:]]*\(/)
                    branch_has_navigate[branch_key] = 1
                if (branch_key != "" && line ~ /(ensureAdmin|adminDialogRequested|Qt\.openUrlExternally|begin[A-Z]|start[A-Z]|confirm[A-Z]|complete[A-Z]|grant[A-Z]|purchase|subscribe|unlock|pay)/)
                    branch_has_non_nav_action[branch_key] = 1

                handler_depth += delta
                if (handler_depth <= 0) {
                    in_handler = 0
                    branch_key = ""
                }
            }
        }

        END {
            for (key in nav_card) {
                if (branch_has_navigate[key] && !branch_has_non_nav_action[key]) {
                    printf "%s: sidebar operational card '%s' only routes to an in-app page and should be removed by default\n", nav_card[key], key
                }
            }
        }
    ' "$file"
}

detect_sidebar_width_squeeze_hits() {
    local file="$1"
    if grep -qE 'AppSidebar|sidebarWidth|sidebarHidden|onCollapseRequested' "$file"; then
        if grep -q 'Behavior on width' "$file"; then
            grep -n 'Behavior on width' "$file" || true
        fi
    fi
}
