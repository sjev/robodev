#!/usr/bin/env sh
# Install robodev skills into the current project directory.
# Usage: curl -LsSf https://raw.githubusercontent.com/sjev/robodev/main/install.sh | sh

set -e

REPO_URL="https://github.com/sjev/robodev.git"
TARGET_DIR="$(pwd)"

# ── helpers ────────────────────────────────────────────────────────────────────

info()    { printf '  \033[34m•\033[0m %s\n' "$*"; }
success() { printf '  \033[32m✓\033[0m %s\n' "$*"; }
die()     { printf '\033[31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ── main ──────────────────────────────────────────────────────────────────────

main() {
    printf 'robodev installer\n'
    printf 'Target: %s\n' "$TARGET_DIR"

    command -v git >/dev/null 2>&1 || die "git is required but not found"

    # Clone to temp dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    info "Cloning robodev to $tmp_dir"
    git clone --quiet "$REPO_URL" "$tmp_dir"

    # Copy Claude skills
    printf '\nInstalling Claude Code skills\n'
    mkdir -p "$TARGET_DIR/.claude/skills"
    for skill_dir in "$tmp_dir/skills"/*/; do
        [ -f "${skill_dir}SKILL.md" ] || continue
        skill_name="$(basename "$skill_dir")"
        cp -r "$skill_dir" "$TARGET_DIR/.claude/skills/$skill_name"
        info "  $skill_name"
    done
    success "Claude Code skills copied to .claude/skills/"

    # Copy Claude agents
    printf '\nInstalling Claude Code agents\n'
    mkdir -p "$TARGET_DIR/.claude/agents"
    for agent_file in "$tmp_dir/agents"/*.md; do
        [ -f "$agent_file" ] || continue
        agent_name="$(basename "$agent_file")"
        cp "$agent_file" "$TARGET_DIR/.claude/agents/$agent_name"
        info "  $agent_name"
    done
    success "Claude Code agents copied to .claude/agents/"

    # Symlink Copilot skills -> copied Claude skills
    printf '\nInstalling GitHub Copilot skills\n'
    mkdir -p "$TARGET_DIR/.github/skills"
    for skill_dir in "$TARGET_DIR/.claude/skills"/*/; do
        [ -d "$skill_dir" ] || continue
        skill_name="$(basename "$skill_dir")"
        dest="$TARGET_DIR/.github/skills/$skill_name"
        rm -rf "$dest"
        ln -s "../../.claude/skills/$skill_name" "$dest"
        info "  $skill_name"
    done
    success "Copilot skills linked in .github/skills/"

    printf '\nDone.\n'
}

main "$@"
