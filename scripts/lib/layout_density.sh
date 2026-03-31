# shellcheck shell=bash

detect_row_aware_card_without_responsive_grid_hits() {
    local file="$1"
    awk '
        function brace_delta(s,   tmp, opens, closes) {
            tmp = s
            opens = gsub(/\{/, "{", tmp)
            closes = gsub(/\}/, "}", tmp)
            return opens - closes
        }

        function push_type(type_name, start_line, active_depth) {
            stack_size += 1
            stack_type[stack_size] = type_name
            stack_line[stack_size] = start_line
            stack_depth[stack_size] = active_depth
        }

        function pop_type() {
            if (stack_size > 0) {
                delete stack_type[stack_size]
                delete stack_line[stack_size]
                delete stack_depth[stack_size]
                stack_size -= 1
            }
        }

        function has_responsive_host(   i) {
            for (i = stack_size; i >= 1; --i) {
                if (stack_type[i] == "ResponsiveCardGrid")
                    return 1
            }
            return 0
        }

        BEGIN {
            stack_size = 0
            total_depth = 0
        }

        {
            line = $0
            delta = brace_delta(line)

            if (line ~ /^[[:space:]]*[A-Za-z_][A-Za-z0-9_.]*[[:space:]]*\{/) {
                type_name = line
                sub(/^[[:space:]]*/, "", type_name)
                sub(/[[:space:]]*\{.*/, "", type_name)
                if ((type_name == "MetricTile" || type_name == "StateSceneCard" || type_name == "ComponentGalleryCard") && !has_responsive_host())
                    printf "%s: %s is mounted outside ResponsiveCardGrid, so row-aware equalization is bypassed\n", NR, type_name
                push_type(type_name, NR, total_depth + 1)
            }

            total_depth += delta
            while (stack_size > 0 && total_depth < stack_depth[stack_size])
                pop_type()
        }
    ' "$file"
}

detect_raw_card_band_hits() {
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
            direct_card_count = 0
            repeater_card_count = 0
            in_repeater = 0
            repeater_depth = 0
            repeater_has_card_delegate = 0
        }

        BEGIN {
            reset_row()
        }

        {
            line = $0
            delta = brace_delta(line)

            if (!in_row && line ~ /^[[:space:]]*(Row|RowLayout)[[:space:]]*\{/) {
                in_row = 1
                row_depth = 0
                row_start = NR
                direct_card_count = 0
                repeater_card_count = 0
                in_repeater = 0
                repeater_depth = 0
                repeater_has_card_delegate = 0
            }

            if (in_row) {
                if (row_depth == 1 && line ~ /^[[:space:]]*(MetricCard|GlassCard|HeroCard|StateSceneCard|MetricTile|ComponentGalleryCard)[[:space:]]*\{/)
                    direct_card_count += 1

                if (!in_repeater && row_depth == 1 && line ~ /^[[:space:]]*Repeater[[:space:]]*\{/) {
                    in_repeater = 1
                    repeater_depth = 0
                    repeater_has_card_delegate = 0
                }

                if (in_repeater) {
                    if (line ~ /delegate[[:space:]]*:[[:space:]]*(MetricCard|GlassCard|HeroCard|StateSceneCard|MetricTile|ComponentGalleryCard)[[:space:]]*\{/)
                        repeater_has_card_delegate = 1

                    repeater_depth += delta
                    if (repeater_depth <= 0) {
                        if (repeater_has_card_delegate)
                            repeater_card_count += 1
                        in_repeater = 0
                    }
                }

                row_depth += delta
                if (row_depth <= 0) {
                    if (direct_card_count + repeater_card_count >= 2)
                        printf "%s: page-level card rows must use EqualizedBand so near-height equalization stays structural instead of incidental\n", row_start
                    reset_row()
                }
            }
        }
    ' "$file"
}

detect_card_shell_stroke_contract_hits() {
    local file="$1"
    if ! grep -qE 'visualAuditCardShell[[:space:]]*:[[:space:]]*true' "$file"; then
        return
    fi

    if grep -qE '^[[:space:]]*border\.width[[:space:]]*:[[:space:]]*1(\.0+)?([[:space:]]*(\/\/.*)?$)' "$file"; then
        return
    fi

    if grep -qE 'anchors\.margins[[:space:]]*:[[:space:]]*1(\.0+)?([[:space:]]*(\/\/.*)?$)' "$file" \
        && grep -qE '^[[:space:]]*color[[:space:]]*:[[:space:]]*(root\.)?borderColor([[:space:]]*(\/\/.*)?$)' "$file"
    then
        return
    fi

    printf '1: card shell must expose a dedicated fixed 1px stroke ring or an exact 1px border contract\n'
}
