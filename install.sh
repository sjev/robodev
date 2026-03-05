#!/usr/bin/env sh
# Install robodev skills into the current project directory.
# Usage: curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
#        bash install.sh [--claude] [--copilot] [--no-scaffold] [--dir <path>]

set -e

REPO_URL="https://github.com/sjev/robodev.git"
ROBODEV_DIR="${ROBODEV_DIR:-$HOME/.local/share/robodev}"
TARGET_DIR="$(pwd)"
DO_CLAUDE=1
DO_COPILOT=1
DO_SCAFFOLD=1

# ── helpers ────────────────────────────────────────────────────────────────────

info()    { printf '  \033[34m•\033[0m %s\n' "$*"; }
success() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
warn()    { printf '  \033[33m!\033[0m %s\n' "$*"; }
die()     { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
    cat <<EOF
robodev installer — copy AI workflow skills into the current project

Usage:
  curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh
  bash install.sh [OPTIONS]

Options:
  --claude        Install Claude Code skills only (.claude/skills/)
  --copilot       Install GitHub Copilot prompts only (.github/prompts/)
  --no-scaffold   Skip docs/ and CLAUDE.md scaffolding
  --dir <path>    robodev cache directory (default: ~/.local/share/robodev)
  -h, --help      Show this help

By default installs for both tools and scaffolds docs/.
EOF
}

# ── arg parsing ────────────────────────────────────────────────────────────────

parse_args() {
    EXPLICIT_TOOL=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --claude)      EXPLICIT_TOOL=1; DO_COPILOT=0 ;;
            --copilot)     EXPLICIT_TOOL=1; DO_CLAUDE=0 ;;
            --no-scaffold) DO_SCAFFOLD=0 ;;
            --dir)         shift; ROBODEV_DIR="$1" ;;
            -h|--help)     usage; exit 0 ;;
            *) die "unknown option: $1" ;;
        esac
        shift
    done
    # if user picked one tool explicitly, re-enable that tool
    if [ "$EXPLICIT_TOOL" = "1" ]; then
        # the flags above already set the right combination
        :
    fi
}

# ── robodev clone/update ───────────────────────────────────────────────────────

install_robodev() {
    if [ -d "$ROBODEV_DIR/.git" ]; then
        info "Updating robodev at $ROBODEV_DIR"
        git -C "$ROBODEV_DIR" pull --quiet
        success "robodev updated"
    else
        info "Cloning robodev to $ROBODEV_DIR"
        git clone --quiet "$REPO_URL" "$ROBODEV_DIR"
        success "robodev cloned"
    fi
}

# ── skill iteration helper ────────────────────────────────────────────────────

each_skill() {
    # calls $1 with each skill directory name
    callback="$1"
    for skill_dir in "$ROBODEV_DIR/skills"/*/; do
        [ -f "${skill_dir}SKILL.md" ] || continue
        skill_name="$(basename "$skill_dir")"
        "$callback" "$skill_name" "$skill_dir"
    done
}

# ── claude code ───────────────────────────────────────────────────────────────

_install_claude_skill() {
    skill_name="$1"
    skill_dir="$2"
    dest="$TARGET_DIR/.claude/skills/$skill_name"
    rm -rf "$dest"
    cp -r "$skill_dir" "$dest"
    info "  $skill_name → .claude/skills/$skill_name/"
}

install_claude() {
    printf '\nInstalling Claude Code skills\n'
    mkdir -p "$TARGET_DIR/.claude/skills"
    each_skill _install_claude_skill
    success "Claude Code skills installed in .claude/skills/"
}

# ── github copilot ────────────────────────────────────────────────────────────

_install_copilot_skill() {
    skill_name="$1"
    skill_dir="$2"
    dest="$TARGET_DIR/.github/prompts/${skill_name}.prompt.md"
    cp "${skill_dir}SKILL.md" "$dest"
    info "  $skill_name → .github/prompts/${skill_name}.prompt.md"
}

install_copilot() {
    printf '\nInstalling GitHub Copilot prompts\n'
    mkdir -p "$TARGET_DIR/.github/prompts"
    each_skill _install_copilot_skill
    success "Copilot prompts installed in .github/prompts/"
}

# ── scaffold ──────────────────────────────────────────────────────────────────

scaffold_docs() {
    printf '\nScaffolding project structure\n'
    mkdir -p "$TARGET_DIR/docs/features"
    info "docs/ and docs/features/ created"

    instructions="$ROBODEV_DIR/skills/instructions.md"
    claude_md="$TARGET_DIR/CLAUDE.md"

    if [ ! -f "$instructions" ]; then
        warn "skills/instructions.md not found — skipping CLAUDE.md scaffold"
        return
    fi

    if [ -f "$claude_md" ]; then
        printf '\n\n---\n# robodev workflow instructions\n\n' >> "$claude_md"
        cat "$instructions" >> "$claude_md"
        success "Appended instructions to CLAUDE.md"
    else
        cp "$instructions" "$claude_md"
        success "Created CLAUDE.md from instructions.md"
    fi
}

# ── main ──────────────────────────────────────────────────────────────────────

main() {
    parse_args "$@"

    printf 'robodev installer\n'
    printf 'Target: %s\n' "$TARGET_DIR"

    command -v git >/dev/null 2>&1 || die "git is required but not found"

    install_robodev

    [ "$DO_CLAUDE" = "1" ]    && install_claude
    [ "$DO_COPILOT" = "1" ]   && install_copilot
    [ "$DO_SCAFFOLD" = "1" ]  && scaffold_docs

    printf '\nDone. Re-run this script to update.\n'
}

main "$@"
