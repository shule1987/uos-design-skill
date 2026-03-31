#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: install_repo_guardrails.sh <repo-root> [--app-name NAME] [--qml-uri URI] [--force]

Installs a baseline set of repo-local UOS guardrail files for future projects:
  - AGENTS.md
  - scripts/uos_guard_build.sh
  - scripts/new_uos_page.sh
  - scripts/uos_visual_audit_scenes.txt
  - scripts/uos_visual_audit_window_sizes.txt
  - cmake/uos-guardrails.cmake
EOF
}

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 64
fi

ROOT=""
APP_NAME=""
QML_URI=""
FORCE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            exit 0
            ;;
        --app-name)
            APP_NAME="${2:-}"
            shift 2
            ;;
        --qml-uri)
            QML_URI="${2:-}"
            shift 2
            ;;
        --force)
            FORCE=1
            shift
            ;;
        *)
            if [[ -z "$ROOT" ]]; then
                ROOT="$1"
                shift
            else
                echo "unexpected argument: $1" >&2
                exit 64
            fi
            ;;
    esac
done

if [[ -z "$ROOT" ]]; then
    usage >&2
    exit 64
fi

ROOT="$(cd "$ROOT" && pwd)"
APP_NAME="${APP_NAME:-$(basename "$ROOT")}"
QML_URI="${QML_URI:-$APP_NAME}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../assets/repo_guardrails"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "template directory not found: $TEMPLATE_DIR" >&2
    exit 72
fi

install_template() {
    local src="$1"
    local dest_rel="$2"
    local executable="${3:-0}"
    local dest="${ROOT}/${dest_rel}"

    if [[ -e "$dest" && "$FORCE" -ne 1 ]]; then
        echo "skip existing ${dest_rel}"
        return
    fi

    mkdir -p "$(dirname "$dest")"
    sed \
        -e "s|__APP_NAME__|${APP_NAME}|g" \
        -e "s|__QML_URI__|${QML_URI}|g" \
        "$src" >"$dest"

    if [[ "$executable" -eq 1 ]]; then
        chmod +x "$dest"
    fi

    echo "installed ${dest_rel}"
}

install_template "${TEMPLATE_DIR}/AGENTS.md.template" "AGENTS.md"
install_template "${TEMPLATE_DIR}/scripts/uos_guard_build.sh.template" "scripts/uos_guard_build.sh" 1
install_template "${TEMPLATE_DIR}/scripts/new_uos_page.sh.template" "scripts/new_uos_page.sh" 1
install_template "${TEMPLATE_DIR}/scripts/uos_visual_audit_scenes.txt.template" "scripts/uos_visual_audit_scenes.txt"
install_template "${TEMPLATE_DIR}/scripts/uos_visual_audit_window_sizes.txt.template" "scripts/uos_visual_audit_window_sizes.txt"
install_template "${TEMPLATE_DIR}/cmake/uos-guardrails.cmake.template" "cmake/uos-guardrails.cmake"

cat <<EOF

Next steps
1. If the repo uses CMake, add:
   include(\${CMAKE_SOURCE_DIR}/cmake/uos-guardrails.cmake)
   uos_design_attach_guardrails(<app-target>)
2. Customize AGENTS.md with the repo's actual approved primitives and forbidden structures.
3. Replace the placeholder visual-audit scenes and window sizes with real shipped coverage.
4. Review scripts/new_uos_page.sh and adjust singleton/component names if the repo does not use AppState/Theme/PageHeading/GlassCard.
EOF
