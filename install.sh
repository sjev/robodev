#!/usr/bin/env sh
# Install robodev skills into the current project directory.
# Usage: curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh

set -e

REPO_URL="https://github.com/sjev/robodev.git"
ROBODEV_DIR="${ROBODEV_DIR:-$HOME/.local/share/robodev}"
TARGET_DIR="$(pwd)"

# ── helpers ────────────────────────────────────────────────────────────────────

info()    { printf '  \033[34m•\033[0m %s\n' "$*"; }
success() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
die()     { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

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

# ── main ──────────────────────────────────────────────────────────────────────

main() {
    printf 'robodev installer\n'
    printf 'Target: %s\n' "$TARGET_DIR"

    command -v git >/dev/null 2>&1 || die "git is required but not found"

    install_robodev
    install_claude
    install_copilot

    printf '\nDone. Re-run this script to update.\n'
}

main "$@"
