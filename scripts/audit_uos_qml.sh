#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<'EOF'
Usage: audit_uos_qml.sh [repo-root]

Heuristic audit for UOS/Deepin QML desktop projects.
It reports blocking findings for:
- missing DTK imports/build hooks when DTK is installed locally
- forced non-DTK global styles
- frameless top-level windows without waivers
- Popup.Window usage without waivers
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

    if ! grep -q 'uos-design: allow-custom-main-menu-button' "$file"; then
        if grep -q 'AppButton' "$file" \
            && grep -qE 'iconName[[:space:]]*:[[:space:]]*"menu"|text[[:space:]]*:[[:space:]]*"更多"' "$file" \
            && grep -qE 'onClicked[[:space:]]*:[[:space:]].*\.open\(' "$file"
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
done < <(list_qml_files)

if (( findings )); then
    printf 'UOS design audit failed with %d finding(s).\n' "$findings" >&2
    exit 1
fi

echo "UOS design audit passed: no findings."
