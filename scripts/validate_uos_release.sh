#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
    cat <<'EOF'
Usage: validate_uos_release.sh [options] [repo-root]

Release gate for UOS/Deepin desktop projects.
It unifies:
- review source discovery
- build/configure
- static UOS QML audit
- runtime visual audit hook execution when available
- ctest execution when tests exist
- headless executable smoke validation
- optional extra dynamic validation commands

Options:
  --repo-root PATH           Repository root. Positional repo-root also works.
  --build-dir PATH           Build directory. Default: auto-detect build-codex/build.
  --audit-script PATH        Override audit_uos_qml.sh path.
  --executable PATH          Override executable path for runtime validation.
  --acceptance-file PATH     Add PRD/spec/acceptance document. Repeatable.
  --review-file PATH         Add extra review input file. Repeatable.
  --scene-key KEY            Extra UOS_DESIGN_VISUAL_AUDIT scene key. Repeatable.
  --scene-manifest PATH      Repo-local visual-audit scene manifest. Default: auto-detect standard locations.
  --window-size WxH          Extra UOS_DESIGN_VISUAL_AUDIT window size. Repeatable.
  --window-size-manifest PATH
                            Repo-local visual-audit window-size manifest. Default: auto-detect standard locations.
  --dynamic-command CMD      Extra dynamic validation command. Repeatable.
  --jobs N                   Build parallelism. Default: detected CPU count or 4.
  --platform NAME            Runtime platform for hook/smoke. Default: auto-detect live display, else offscreen.
  --smoke-timeout SEC        Timeout for hook/smoke runs. Default: 15.
  --visual-timeout SEC       Timeout for visual audit runs. Default: 30.
  --skip-configure           Skip cmake configure.
  --skip-build               Skip cmake build.
  --skip-ctest              Skip ctest even if tests exist.
  --skip-smoke              Skip executable smoke validation.
  --skip-visual-audit       Skip UOS_DESIGN_VISUAL_AUDIT hook execution.
  --allow-no-acceptance     Do not fail when no PRD/spec/acceptance source is found.
  -h, --help                Show this help.

Examples:
  validate_uos_release.sh /path/to/repo
  validate_uos_release.sh --build-dir build-codex --dynamic-command 'qmlscene smoke.qml' .
  validate_uos_release.sh --scene-key main --scene-key settings --repo-root .
  validate_uos_release.sh --scene-manifest scripts/uos_visual_audit_scenes.txt --repo-root .
  validate_uos_release.sh --window-size 1040x720 --repo-root .
  validate_uos_release.sh --window-size-manifest scripts/uos_visual_audit_window_sizes.txt --repo-root .
EOF
}

note() {
    printf 'INFO %s\n' "$*"
}

pass() {
    printf 'PASS %s\n' "$*"
}

warn() {
    printf 'WARN %s\n' "$*"
}

fail() {
    printf 'FAIL %s\n' "$*"
    FAILURES=$((FAILURES + 1))
}

pick_default_build_dir() {
    if [[ -d "$REPO_ROOT/build-codex" ]]; then
        printf '%s\n' "$REPO_ROOT/build-codex"
        return
    fi
    if [[ -d "$REPO_ROOT/build" ]]; then
        printf '%s\n' "$REPO_ROOT/build"
        return
    fi
    printf '%s\n' "$REPO_ROOT/build-codex"
}

pick_default_audit_script() {
    if [[ -f "$REPO_ROOT/scripts/audit_uos_qml.sh" ]]; then
        printf '%s\n' "$REPO_ROOT/scripts/audit_uos_qml.sh"
        return
    fi
    printf '%s\n' "$SCRIPT_DIR/audit_uos_qml.sh"
}

detect_jobs() {
    local detected
    detected="$(getconf _NPROCESSORS_ONLN 2>/dev/null || true)"
    if [[ "$detected" =~ ^[0-9]+$ ]] && (( detected > 0 )); then
        printf '%s\n' "$detected"
    else
        printf '4\n'
    fi
}

pick_default_platform() {
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        printf 'wayland\n'
        return
    fi
    if [[ -n "${DISPLAY:-}" ]]; then
        printf 'xcb\n'
        return
    fi
    printf 'offscreen\n'
}

pick_default_scene_manifest() {
    local candidate
    for candidate in \
        "$REPO_ROOT/scripts/uos_visual_audit_scenes.txt" \
        "$REPO_ROOT/config/uos_visual_audit_scenes.txt" \
        "$REPO_ROOT/.codex/uos_visual_audit_scenes.txt" \
        "$REPO_ROOT/uos_visual_audit_scenes.txt"
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
}

pick_default_window_size_manifest() {
    local candidate
    for candidate in \
        "$REPO_ROOT/scripts/uos_visual_audit_window_sizes.txt" \
        "$REPO_ROOT/config/uos_visual_audit_window_sizes.txt" \
        "$REPO_ROOT/.codex/uos_visual_audit_window_sizes.txt" \
        "$REPO_ROOT/uos_visual_audit_window_sizes.txt"
    do
        if [[ -f "$candidate" ]]; then
            printf '%s\n' "$candidate"
            return
        fi
    done
}

append_unique() {
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

load_scene_manifest_keys() {
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

normalize_window_size_spec() {
    local spec
    spec="$(printf '%s' "${1-}" | tr -d '[:space:]')"
    if [[ "$spec" =~ ^[0-9]+x[0-9]+$ ]]; then
        printf '%s\n' "$spec"
        return 0
    fi
    return 1
}

load_window_size_manifest_specs() {
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

auto_detect_acceptance_sources() {
    find "$REPO_ROOT" -maxdepth 3 -type f \
        \( -iname '*prd*.md' \
        -o -iname '*spec*.md' \
        -o -iname '*acceptance*.md' \
        -o -iname '*requirements*.md' \
        -o -iname '*需求*.md' \
        -o -iname '*验收*.md' \) \
        | sort
}

collect_review_scope() {
    if command -v git >/dev/null 2>&1 && git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git -C "$REPO_ROOT" status --short 2>/dev/null || true
        return
    fi
    find "$REPO_ROOT" -type f \
        \( -path "$REPO_ROOT/qml/*" \
        -o -path "$REPO_ROOT/src/*" \
        -o -path "$REPO_ROOT/docs/*" \
        -o -path "$REPO_ROOT/scripts/*" \
        -o -name 'CMakeLists.txt' \) \
        ! -path '*/build/*' \
        ! -path '*/build-codex/*' \
        ! -path '*/.git/*' \
        | sort
}

repo_needs_extra_scene_coverage() {
    local count
    count="$(find "$REPO_ROOT" -type f \
        \( -path "$REPO_ROOT/src/qml/pages/*" -o -path "$REPO_ROOT/qml/pages/*" -o -path "$REPO_ROOT/ui/pages/*" \) \
        ! -path '*/build/*' ! -path '*/build-codex/*' 2>/dev/null \
        | wc -l | tr -d ' ')"

    if [[ "$count" =~ ^[0-9]+$ ]] && (( count > 1 )); then
        return 0
    fi

    grep -RIl 'prepareVisualAuditSection' \
        "$REPO_ROOT" \
        --include='*.qml' --include='*.cpp' --include='*.cc' --include='*.cxx' --include='*.h' --include='*.hpp' 2>/dev/null \
        | grep -q .
}

repo_needs_extra_window_size_coverage() {
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
    done < <(find "$REPO_ROOT" -type f -name '*.qml' \
        ! -path '*/build/*' \
        ! -path '*/build-codex/*' \
        ! -path '*/.git/*' \
        | sort)

    return 1
}

detect_executable_targets() {
    local cmake_file="$REPO_ROOT/CMakeLists.txt"
    [[ -f "$cmake_file" ]] || return 0

    local pending=0
    local line=""
    local cleaned=""
    while IFS= read -r line; do
        cleaned="${line%%#*}"
        if (( pending )); then
            cleaned="${cleaned#"${cleaned%%[![:space:]]*}"}"
            if [[ -n "$cleaned" && "$cleaned" != ")" && "$cleaned" != "{" ]]; then
                printf '%s\n' "${cleaned%%[[:space:])]*}"
                pending=0
                continue
            fi
        fi

        if [[ "$cleaned" =~ ^[[:space:]]*(qt_add_executable|add_executable)[[:space:]]*\(([A-Za-z0-9_.+-]+) ]]; then
            printf '%s\n' "${BASH_REMATCH[2]}"
            pending=0
            continue
        fi

        if [[ "$cleaned" =~ ^[[:space:]]*(qt_add_executable|add_executable)[[:space:]]*\([[:space:]]*$ ]]; then
            pending=1
        fi
    done < "$cmake_file"
}

detect_executable_path() {
    local target
    while IFS= read -r target; do
        [[ -n "$target" ]] || continue
        if [[ -x "$BUILD_DIR/$target" ]]; then
            printf '%s\n' "$BUILD_DIR/$target"
            return 0
        fi
        local found
        found="$(find "$BUILD_DIR" -maxdepth 4 -type f -name "$target" -perm -111 ! -path '*/CMakeFiles/*' | head -n 1)"
        if [[ -n "$found" ]]; then
            printf '%s\n' "$found"
            return 0
        fi
    done < <(detect_executable_targets)

    find "$BUILD_DIR" -maxdepth 3 -type f -perm -111 \
        ! -path '*/CMakeFiles/*' \
        ! -name 'cmake' \
        ! -name 'ctest' \
        | head -n 1
}

repo_has_visual_audit_hook() {
    grep -RIl 'UOS_DESIGN_VISUAL_AUDIT' \
        "$REPO_ROOT" \
        --include='*.cpp' \
        --include='*.cc' \
        --include='*.cxx' \
        --include='*.h' \
        --include='*.hpp' 2>/dev/null \
        | grep -q .
}

repo_requires_live_compositor_validation() {
    grep -RIl 'StyledBehindWindowBlur|D\.DWindow\.enabled|WindowButtonGroup|TitleBar' \
        "$REPO_ROOT" \
        --include='*.qml' \
        --include='*.cpp' \
        --include='*.cc' \
        --include='*.cxx' \
        --include='*.h' \
        --include='*.hpp' 2>/dev/null \
        | grep -q .
}

run_audit() {
    note "Static audit: $AUDIT_SCRIPT $REPO_ROOT"
    local stdout_file=""
    local stderr_file=""
    local status=0
    local had_stderr=0

    stdout_file="$(mktemp "${TMPDIR:-/tmp}/uos-design-audit-stdout-XXXXXX")"
    stderr_file="$(mktemp "${TMPDIR:-/tmp}/uos-design-audit-stderr-XXXXXX")"

    if ! bash "$AUDIT_SCRIPT" "$REPO_ROOT" >"$stdout_file" 2>"$stderr_file"; then
        status=$?
    fi

    [[ -s "$stdout_file" ]] && cat "$stdout_file"
    if [[ -s "$stderr_file" ]]; then
        had_stderr=1
        cat "$stderr_file" >&2
    fi

    if (( status != 0 )); then
        rm -f "$stdout_file" "$stderr_file"
        fail "Static audit"
        return 1
    fi

    if (( had_stderr )); then
        rm -f "$stdout_file" "$stderr_file"
        fail "Static audit"
        return 1
    fi

    rm -f "$stdout_file" "$stderr_file"
    pass "Static audit"
    return 0
}

run_ctest_if_present() {
    if (( SKIP_CTEST )); then
        warn "ctest skipped by flag"
        return 0
    fi
    if ! command -v ctest >/dev/null 2>&1; then
        warn "ctest not installed"
        return 0
    fi

    local inventory
    inventory="$(ctest --test-dir "$BUILD_DIR" -N 2>&1 || true)"
    if ! grep -q 'Total Tests:' <<<"$inventory"; then
        warn "No ctest metadata found"
        return 0
    fi
    if grep -q 'Total Tests: 0' <<<"$inventory"; then
        warn "No ctest tests discovered"
        return 0
    fi

    note "ctest --test-dir $BUILD_DIR --output-on-failure"
    if ctest --test-dir "$BUILD_DIR" --output-on-failure; then
        pass "ctest"
        return 0
    fi
    fail "ctest"
    return 1
}

run_visual_audit_hook() {
    if (( SKIP_VISUAL_AUDIT )); then
        warn "Visual audit hook skipped by flag"
        return 0
    fi
    if ! repo_has_visual_audit_hook; then
        warn "No UOS_DESIGN_VISUAL_AUDIT hook detected"
        return 0
    fi
    if [[ -z "$EXECUTABLE_PATH" ]]; then
        fail "Visual audit hook requires an executable path"
        return 1
    fi

    local -a command=("$EXECUTABLE_PATH")
    if [[ -n "$PLATFORM" ]]; then
        command+=(-platform "$PLATFORM")
    fi

    local output=""
    local ran_any=0
    local saw_bad_status=0
    local -a size_specs=("")
    if [[ -z "$VISUAL_DUMP_DIR" ]]; then
        VISUAL_DUMP_DIR="$BUILD_DIR/visual-audit-shots-$(date +%Y%m%d-%H%M%S)"
    fi

    local size_spec
    for size_spec in "${WINDOW_SIZE_SPECS[@]}"; do
        [[ -n "$size_spec" ]] || continue
        size_specs+=("$size_spec")
    done

    note "Runtime visual audit hook"
    note "Visual audit screenshots: $VISUAL_DUMP_DIR"
    local step_output=""
    local step_status=0
    local key
    for size_spec in "${size_specs[@]}"; do
        run_visual_capture "" "$size_spec" step_output step_status "${command[@]}"
        output+="$step_output"
        output+=$'\n'
        ran_any=1
        if (( step_status != 0 && step_status != 124 )); then
            saw_bad_status=1
        fi

        for key in "${SCENE_KEYS[@]}"; do
            [[ -n "$key" ]] || continue
            run_visual_capture "$key" "$size_spec" step_output step_status "${command[@]}"
            output+="$step_output"
            output+=$'\n'
            ran_any=1
            if (( step_status != 0 && step_status != 124 )); then
                saw_bad_status=1
            fi
        done
    done

    if (( ! ran_any )); then
        warn "Visual audit hook not executed"
        return 0
    fi

    local visual_failures=0
    local line
    while IFS= read -r line; do
        [[ "$line" == VISUAL_AUDIT_FAIL\ \[* ]] || continue
        printf '%s\n' "$line"
        visual_failures=$((visual_failures + 1))
    done <<<"$output"

    if (( visual_failures > 0 )); then
        fail "Runtime visual audit hook"
        return 1
    fi

    if (( saw_bad_status )); then
        printf '%s\n' "$output"
        fail "Runtime visual audit hook"
        return 1
    fi

    if [[ ! -d "$VISUAL_DUMP_DIR" ]]; then
        fail "Runtime visual audit screenshots"
        return 1
    fi

    if ! find "$VISUAL_DUMP_DIR" -maxdepth 1 -type f -name '*.png' | grep -q .; then
        fail "Runtime visual audit screenshots"
        return 1
    fi

    local coverage_failures=0
    local scene_name=""
    local pattern=""
    for size_spec in "${size_specs[@]}"; do
        scene_name="default"
        if [[ -n "$size_spec" ]]; then
            pattern="${scene_name}-${size_spec}-*.png"
        else
            pattern="${scene_name}-*.png"
        fi
        if ! find "$VISUAL_DUMP_DIR" -maxdepth 1 -type f -name "$pattern" | grep -q .; then
            printf 'Missing visual-audit screenshot for scene=%s size=%s in %s\n' "$scene_name" "${size_spec:-default}" "$VISUAL_DUMP_DIR" >&2
            coverage_failures=$((coverage_failures + 1))
        fi

        for key in "${SCENE_KEYS[@]}"; do
            [[ -n "$key" ]] || continue
            scene_name="$key"
            if [[ -n "$size_spec" ]]; then
                pattern="${scene_name}-${size_spec}-*.png"
            else
                pattern="${scene_name}-*.png"
            fi
            if ! find "$VISUAL_DUMP_DIR" -maxdepth 1 -type f -name "$pattern" | grep -q .; then
                printf 'Missing visual-audit screenshot for scene=%s size=%s in %s\n' "$scene_name" "${size_spec:-default}" "$VISUAL_DUMP_DIR" >&2
                coverage_failures=$((coverage_failures + 1))
            fi
        done
    done

    if (( coverage_failures > 0 )); then
        fail "Runtime visual audit screenshots"
        return 1
    fi

    pass "Runtime visual audit hook"
    return 0
}

run_visual_capture() {
    local scene_key="$1"
    local window_size="$2"
    local __output_var="$3"
    local __status_var="$4"
    shift 4

    local tmp
    tmp="$(mktemp)"
    local status=0
    local -a env_args=(UOS_DESIGN_VISUAL_AUDIT=1)
    if [[ -n "$VISUAL_DUMP_DIR" ]]; then
        env_args+=(UOS_DESIGN_VISUAL_AUDIT_DUMP_DIR="$VISUAL_DUMP_DIR")
    fi

    if [[ -n "$scene_key" ]]; then
        env_args+=(UOS_DESIGN_VISUAL_AUDIT_SCENE_KEY="$scene_key")
    fi
    if [[ -n "$window_size" ]]; then
        env_args+=(UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZE="$window_size")
    fi

    if command -v timeout >/dev/null 2>&1; then
        timeout "${VISUAL_TIMEOUT}s" env "${env_args[@]}" "$@" >"$tmp" 2>&1 || status=$?
    else
        env "${env_args[@]}" "$@" >"$tmp" 2>&1 || status=$?
    fi

    local captured
    captured="$(cat "$tmp")"
    rm -f "$tmp"

    printf -v "$__output_var" '%s' "$captured"
    printf -v "$__status_var" '%s' "$status"
}

run_extra_dynamic_commands() {
    local command
    local index=0
    for command in "${DYNAMIC_COMMANDS[@]}"; do
        index=$((index + 1))
        note "Dynamic command #$index: $command"
        if (cd "$REPO_ROOT" && bash -lc "$command"); then
            pass "Dynamic command #$index"
        else
            fail "Dynamic command #$index"
        fi
    done
}

run_smoke() {
    if (( SKIP_SMOKE )); then
        warn "Smoke run skipped by flag"
        return 0
    fi
    if [[ -z "$EXECUTABLE_PATH" ]]; then
        fail "Smoke run requires an executable path"
        return 1
    fi

    local -a command=("$EXECUTABLE_PATH")
    if [[ -n "$PLATFORM" ]]; then
        command+=(-platform "$PLATFORM")
    fi

    note "Smoke run: timeout ${SMOKE_TIMEOUT}s ${command[*]}"
    local status=0
    local tmp
    tmp="$(mktemp)"
    if timeout "$SMOKE_TIMEOUT"s "${command[@]}" >"$tmp" 2>&1; then
        status=0
    else
        status=$?
    fi

    if (( status == 0 || status == 124 )); then
        if [[ -n "${VALIDATE_UOS_RELEASE_VERBOSE:-}" ]]; then
            cat "$tmp"
        fi
        rm -f "$tmp"
        pass "Smoke run"
        return 0
    fi

    cat "$tmp"
    rm -f "$tmp"
    fail "Smoke run"
    return 1
}

REPO_ROOT="$PWD"
BUILD_DIR=""
AUDIT_SCRIPT=""
EXECUTABLE_PATH=""
SCENE_MANIFEST=""
WINDOW_SIZE_MANIFEST=""
PLATFORM=""
SMOKE_TIMEOUT=15
VISUAL_TIMEOUT=30
VISUAL_DUMP_DIR="${UOS_DESIGN_VISUAL_AUDIT_DUMP_DIR:-}"
SKIP_CONFIGURE=0
SKIP_BUILD=0
SKIP_CTEST=0
SKIP_SMOKE=0
SKIP_VISUAL_AUDIT=0
ALLOW_NO_ACCEPTANCE=0
FAILURES=0
JOBS=""
POSITIONAL_ROOT=""
ACCEPTANCE_SOURCES=()
REVIEW_SOURCES=()
SCENE_KEYS=()
WINDOW_SIZE_SPECS=()
DYNAMIC_COMMANDS=()

while (($# > 0)); do
    case "$1" in
        --repo-root)
            REPO_ROOT="$2"
            shift 2
            ;;
        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        --audit-script)
            AUDIT_SCRIPT="$2"
            shift 2
            ;;
        --executable)
            EXECUTABLE_PATH="$2"
            shift 2
            ;;
        --acceptance-file)
            ACCEPTANCE_SOURCES+=("$2")
            shift 2
            ;;
        --review-file)
            REVIEW_SOURCES+=("$2")
            shift 2
            ;;
        --scene-key)
            SCENE_KEYS+=("$2")
            shift 2
            ;;
        --scene-manifest)
            SCENE_MANIFEST="$2"
            shift 2
            ;;
        --window-size)
            WINDOW_SIZE_SPECS+=("$2")
            shift 2
            ;;
        --window-size-manifest)
            WINDOW_SIZE_MANIFEST="$2"
            shift 2
            ;;
        --dynamic-command)
            DYNAMIC_COMMANDS+=("$2")
            shift 2
            ;;
        --jobs)
            JOBS="$2"
            shift 2
            ;;
        --platform)
            PLATFORM="$2"
            shift 2
            ;;
        --smoke-timeout)
            SMOKE_TIMEOUT="$2"
            shift 2
            ;;
        --visual-timeout)
            VISUAL_TIMEOUT="$2"
            shift 2
            ;;
        --skip-configure)
            SKIP_CONFIGURE=1
            shift
            ;;
        --skip-build)
            SKIP_BUILD=1
            shift
            ;;
        --skip-ctest)
            SKIP_CTEST=1
            shift
            ;;
        --skip-smoke)
            SKIP_SMOKE=1
            shift
            ;;
        --skip-visual-audit)
            SKIP_VISUAL_AUDIT=1
            shift
            ;;
        --allow-no-acceptance)
            ALLOW_NO_ACCEPTANCE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        -*)
            printf 'Unknown option: %s\n' "$1" >&2
            usage >&2
            exit 64
            ;;
        *)
            POSITIONAL_ROOT="$1"
            shift
            ;;
    esac
done

if [[ -n "$POSITIONAL_ROOT" ]]; then
    REPO_ROOT="$POSITIONAL_ROOT"
fi

if [[ ! -d "$REPO_ROOT" ]]; then
    printf 'Repository root does not exist: %s\n' "$REPO_ROOT" >&2
    exit 64
fi

REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
BUILD_DIR="${BUILD_DIR:-$(pick_default_build_dir)}"
AUDIT_SCRIPT="${AUDIT_SCRIPT:-$(pick_default_audit_script)}"
JOBS="${JOBS:-$(detect_jobs)}"
PLATFORM="${PLATFORM:-$(pick_default_platform)}"

if [[ "$BUILD_DIR" != /* ]]; then
    BUILD_DIR="$REPO_ROOT/$BUILD_DIR"
fi
if [[ "$AUDIT_SCRIPT" != /* ]]; then
    AUDIT_SCRIPT="$REPO_ROOT/$AUDIT_SCRIPT"
fi
if [[ -n "$EXECUTABLE_PATH" && "$EXECUTABLE_PATH" != /* ]]; then
    EXECUTABLE_PATH="$REPO_ROOT/$EXECUTABLE_PATH"
fi
if [[ -n "$SCENE_MANIFEST" && "$SCENE_MANIFEST" != /* ]]; then
    SCENE_MANIFEST="$REPO_ROOT/$SCENE_MANIFEST"
fi
if [[ -n "$WINDOW_SIZE_MANIFEST" && "$WINDOW_SIZE_MANIFEST" != /* ]]; then
    WINDOW_SIZE_MANIFEST="$REPO_ROOT/$WINDOW_SIZE_MANIFEST"
fi

if [[ ! -f "$AUDIT_SCRIPT" ]]; then
    printf 'Audit script not found: %s\n' "$AUDIT_SCRIPT" >&2
    exit 64
fi

if [[ -z "$SCENE_MANIFEST" ]]; then
    SCENE_MANIFEST="$(pick_default_scene_manifest)"
fi
if [[ -z "$WINDOW_SIZE_MANIFEST" ]]; then
    WINDOW_SIZE_MANIFEST="$(pick_default_window_size_manifest)"
fi

if [[ -n "$SCENE_MANIFEST" && ! -f "$SCENE_MANIFEST" ]]; then
    printf 'Scene manifest not found: %s\n' "$SCENE_MANIFEST" >&2
    exit 64
fi
if [[ -n "$WINDOW_SIZE_MANIFEST" && ! -f "$WINDOW_SIZE_MANIFEST" ]]; then
    printf 'Window-size manifest not found: %s\n' "$WINDOW_SIZE_MANIFEST" >&2
    exit 64
fi

if [[ -n "${UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS:-}" ]]; then
    IFS=',' read -r -a ENV_SCENE_KEYS <<<"${UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS}"
    for key in "${ENV_SCENE_KEYS[@]}"; do
        if ! append_unique "$key" "${SCENE_KEYS[@]}"; then
            SCENE_KEYS+=("$key")
        fi
    done
fi
if [[ -n "${UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZES:-}" ]]; then
    IFS=',' read -r -a ENV_WINDOW_SIZE_SPECS <<<"${UOS_DESIGN_VISUAL_AUDIT_WINDOW_SIZES}"
    for spec in "${ENV_WINDOW_SIZE_SPECS[@]}"; do
        normalized_spec="$(normalize_window_size_spec "$spec" || true)"
        [[ -n "$normalized_spec" ]] || continue
        if ! append_unique "$normalized_spec" "${WINDOW_SIZE_SPECS[@]}"; then
            WINDOW_SIZE_SPECS+=("$normalized_spec")
        fi
    done
fi

if [[ -n "$SCENE_MANIFEST" ]]; then
    mapfile -t MANIFEST_SCENE_KEYS < <(load_scene_manifest_keys "$SCENE_MANIFEST")
    for key in "${MANIFEST_SCENE_KEYS[@]}"; do
        if ! append_unique "$key" "${SCENE_KEYS[@]}"; then
            SCENE_KEYS+=("$key")
        fi
    done
fi
if [[ -n "$WINDOW_SIZE_MANIFEST" ]]; then
    mapfile -t MANIFEST_WINDOW_SIZE_SPECS < <(load_window_size_manifest_specs "$WINDOW_SIZE_MANIFEST")
    for spec in "${MANIFEST_WINDOW_SIZE_SPECS[@]}"; do
        normalized_spec="$(normalize_window_size_spec "$spec" || true)"
        [[ -n "$normalized_spec" ]] || continue
        if ! append_unique "$normalized_spec" "${WINDOW_SIZE_SPECS[@]}"; then
            WINDOW_SIZE_SPECS+=("$normalized_spec")
        fi
    done
fi

if (( ${#WINDOW_SIZE_SPECS[@]} > 0 )); then
    NORMALIZED_WINDOW_SIZE_SPECS=()
    for spec in "${WINDOW_SIZE_SPECS[@]}"; do
        normalized_spec="$(normalize_window_size_spec "$spec" || true)"
        if [[ -z "$normalized_spec" ]]; then
            printf 'Invalid window-size spec: %s\n' "$spec" >&2
            exit 64
        fi
        if ! append_unique "$normalized_spec" "${NORMALIZED_WINDOW_SIZE_SPECS[@]}"; then
            NORMALIZED_WINDOW_SIZE_SPECS+=("$normalized_spec")
        fi
    done
    WINDOW_SIZE_SPECS=("${NORMALIZED_WINDOW_SIZE_SPECS[@]}")
fi

if repo_has_visual_audit_hook && repo_needs_extra_scene_coverage && (( ${#SCENE_KEYS[@]} == 0 )); then
    fail "Runtime visual audit scene coverage missing: repo appears to ship multiple pages or deeper sections but no repo-local scene manifest or extra scene keys were supplied"
fi
if repo_has_visual_audit_hook && repo_needs_extra_window_size_coverage && (( ${#WINDOW_SIZE_SPECS[@]} == 0 )); then
    fail "Runtime visual audit window-size coverage missing: repo appears resizable between its default and minimum window sizes but no repo-local size manifest or extra --window-size values were supplied"
fi

mapfile -t AUTO_ACCEPTANCE_SOURCES < <(auto_detect_acceptance_sources)
for path in "${AUTO_ACCEPTANCE_SOURCES[@]}"; do
    ACCEPTANCE_SOURCES+=("$path")
done

if (( ${#ACCEPTANCE_SOURCES[@]} == 0 && ! ALLOW_NO_ACCEPTANCE )); then
    fail "No PRD/spec/acceptance source provided or auto-detected"
fi

note "Repository root: $REPO_ROOT"
note "Build directory: $BUILD_DIR"
note "Audit script: $AUDIT_SCRIPT"
note "Platform: ${PLATFORM:-<none>}"
note "Jobs: $JOBS"
if [[ -n "$SCENE_MANIFEST" ]]; then
    note "Scene manifest: $SCENE_MANIFEST"
fi
if (( ${#SCENE_KEYS[@]} > 0 )); then
    note "Visual audit scenes:"
    printf '  %s\n' "${SCENE_KEYS[@]}"
fi
if [[ -n "$WINDOW_SIZE_MANIFEST" ]]; then
    note "Window-size manifest: $WINDOW_SIZE_MANIFEST"
fi
if (( ${#WINDOW_SIZE_SPECS[@]} > 0 )); then
    note "Visual audit window sizes:"
    printf '  %s\n' "${WINDOW_SIZE_SPECS[@]}"
fi

if repo_requires_live_compositor_validation; then
    if [[ "$PLATFORM" == "offscreen" ]]; then
        if [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]]; then
            fail "Platform offscreen cannot sign off compositor-dependent UOS visuals when a live display is available; rerun with xcb/wayland or omit --platform"
        else
            warn "Platform offscreen cannot validate compositor-dependent visuals such as sidebar/header continuity or blur layering"
        fi
    fi
fi

if (( ${#ACCEPTANCE_SOURCES[@]} > 0 )); then
    note "Acceptance sources:"
    printf '  %s\n' "${ACCEPTANCE_SOURCES[@]}"
else
    warn "Acceptance sources: none"
fi

if (( ${#REVIEW_SOURCES[@]} > 0 )); then
    note "Additional review inputs:"
    printf '  %s\n' "${REVIEW_SOURCES[@]}"
fi

note "Review scope snapshot:"
collect_review_scope | sed 's/^/  /'

if (( ! SKIP_BUILD )); then
    if [[ ! -f "$REPO_ROOT/CMakeLists.txt" ]]; then
        fail "CMakeLists.txt not found for build step"
    else
        if (( ! SKIP_CONFIGURE )); then
            note "cmake -S $REPO_ROOT -B $BUILD_DIR"
            if cmake -S "$REPO_ROOT" -B "$BUILD_DIR"; then
                pass "Configure"
            else
                fail "Configure"
            fi
        else
            warn "Configure skipped by flag"
        fi

        note "cmake --build $BUILD_DIR -j$JOBS"
        if cmake --build "$BUILD_DIR" -j"$JOBS"; then
            pass "Build"
        else
            fail "Build"
        fi
    fi
else
    warn "Build skipped by flag"
fi

run_audit || true

if [[ -z "$EXECUTABLE_PATH" && -d "$BUILD_DIR" ]]; then
    EXECUTABLE_PATH="$(detect_executable_path || true)"
fi

if [[ -n "$EXECUTABLE_PATH" ]]; then
    note "Executable: $EXECUTABLE_PATH"
else
    warn "Executable not auto-detected"
fi

run_visual_audit_hook || true
run_ctest_if_present || true
run_extra_dynamic_commands || true
run_smoke || true

if (( FAILURES > 0 )); then
    printf '\nRelease validation failed with %d blocking issue(s).\n' "$FAILURES" >&2
    exit 1
fi

printf '\nRelease validation passed.\n'
