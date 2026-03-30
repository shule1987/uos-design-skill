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
  --dynamic-command CMD      Extra dynamic validation command. Repeatable.
  --jobs N                   Build parallelism. Default: detected CPU count or 4.
  --platform NAME            Runtime platform for hook/smoke. Default: offscreen.
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
    find "$REPO_ROOT" -maxdepth 2 -type f \
        \( -path "$REPO_ROOT/qml/*" -o -path "$REPO_ROOT/src/*" -o -name 'CMakeLists.txt' \) \
        | sort
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

run_audit() {
    note "Static audit: $AUDIT_SCRIPT $REPO_ROOT"
    if bash "$AUDIT_SCRIPT" "$REPO_ROOT"; then
        pass "Static audit"
        return 0
    fi
    fail "Static audit"
    return 1
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

    note "Runtime visual audit hook"
    local step_output=""
    local step_status=0
    run_visual_capture "" step_output step_status "${command[@]}"
    output+="$step_output"
    output+=$'\n'
    ran_any=1
    if (( step_status != 0 && step_status != 124 )); then
        saw_bad_status=1
    fi

    local key
    for key in "${SCENE_KEYS[@]}"; do
        [[ -n "$key" ]] || continue
        run_visual_capture "$key" step_output step_status "${command[@]}"
        output+="$step_output"
        output+=$'\n'
        ran_any=1
        if (( step_status != 0 && step_status != 124 )); then
            saw_bad_status=1
        fi
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

    pass "Runtime visual audit hook"
    return 0
}

run_visual_capture() {
    local scene_key="$1"
    local __output_var="$2"
    local __status_var="$3"
    shift 3

    local tmp
    tmp="$(mktemp)"
    local status=0

    if command -v timeout >/dev/null 2>&1; then
        if [[ -n "$scene_key" ]]; then
            timeout "${VISUAL_TIMEOUT}s" env UOS_DESIGN_VISUAL_AUDIT=1 UOS_DESIGN_VISUAL_AUDIT_SCENE_KEY="$scene_key" "$@" >"$tmp" 2>&1 || status=$?
        else
            timeout "${VISUAL_TIMEOUT}s" env UOS_DESIGN_VISUAL_AUDIT=1 "$@" >"$tmp" 2>&1 || status=$?
        fi
    else
        if [[ -n "$scene_key" ]]; then
            env UOS_DESIGN_VISUAL_AUDIT=1 UOS_DESIGN_VISUAL_AUDIT_SCENE_KEY="$scene_key" "$@" >"$tmp" 2>&1 || status=$?
        else
            env UOS_DESIGN_VISUAL_AUDIT=1 "$@" >"$tmp" 2>&1 || status=$?
        fi
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
PLATFORM="offscreen"
SMOKE_TIMEOUT=15
VISUAL_TIMEOUT=30
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

if [[ "$BUILD_DIR" != /* ]]; then
    BUILD_DIR="$REPO_ROOT/$BUILD_DIR"
fi
if [[ "$AUDIT_SCRIPT" != /* ]]; then
    AUDIT_SCRIPT="$REPO_ROOT/$AUDIT_SCRIPT"
fi
if [[ -n "$EXECUTABLE_PATH" && "$EXECUTABLE_PATH" != /* ]]; then
    EXECUTABLE_PATH="$REPO_ROOT/$EXECUTABLE_PATH"
fi

if [[ ! -f "$AUDIT_SCRIPT" ]]; then
    printf 'Audit script not found: %s\n' "$AUDIT_SCRIPT" >&2
    exit 64
fi

if [[ ${#SCENE_KEYS[@]} -eq 0 && -n "${UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS:-}" ]]; then
    IFS=',' read -r -a SCENE_KEYS <<<"${UOS_DESIGN_VISUAL_AUDIT_SCENE_KEYS}"
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
