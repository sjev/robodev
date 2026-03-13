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

# ── skill linking ─────────────────────────────────────────────────────────────

# Link all skill dirs into a destination directory.
link_skills() {
    dest_base="$1"
    mkdir -p "$dest_base"
    for skill_dir in "$ROBODEV_DIR/skills"/*/; do
        [ -f "${skill_dir}SKILL.md" ] || continue
        skill_name="$(basename "$skill_dir")"
        dest="$dest_base/$skill_name"
        rm -rf "$dest"
        ln -s "$skill_dir" "$dest"
        info "  $skill_name → $dest_base/$skill_name"
    done
}

install_claude() {
    printf '\nInstalling Claude Code skills\n'
    link_skills "$TARGET_DIR/.claude/skills"
    success "Claude Code skills linked in .claude/skills/"
}

install_copilot() {
    printf '\nInstalling GitHub Copilot skills\n'
    link_skills "$TARGET_DIR/.github/skills"
    success "Copilot skills linked in .github/skills/"
}

# ── scaffold ──────────────────────────────────────────────────────────────────

scaffold_docs() {
    printf '\nScaffolding project structure\n'

    mkdir -p "$TARGET_DIR/docs/features"
    info "docs/ and docs/features/ created"

    # instructions="$ROBODEV_DIR/skills/instructions.md"
    # claude_md="$TARGET_DIR/CLAUDE.md"

    # if [ -f "$instructions" ]; then
    #     if [ -f "$claude_md" ]; then
    #         printf '\n\n---\n# robodev workflow instructions\n\n' >> "$claude_md"
    #         cat "$instructions" >> "$claude_md"
    #         success "Appended instructions to CLAUDE.md"
    #     else
    #         cp "$instructions" "$claude_md"
    #         success "Created CLAUDE.md from instructions.md"
    #     fi
    # fi

    # Exclude skill symlinks from git tracking
    gitignore="$TARGET_DIR/.gitignore"
    for entry in '.claude/skills/' '.github/skills/'; do
        if [ -f "$gitignore" ] && grep -qF "$entry" "$gitignore"; then
            continue
        fi
        printf '%s\n' "$entry" >> "$gitignore"
    done
    success "Added skill dirs to .gitignore"
}

# ── main ──────────────────────────────────────────────────────────────────────

main() {
    printf 'robodev installer\n'
    printf 'Target: %s\n' "$TARGET_DIR"

    command -v git >/dev/null 2>&1 || die "git is required but not found"

    install_robodev
    install_claude
    install_copilot
    scaffold_docs

    printf '\nDone. Skills update automatically when robodev is updated.\n'
}

main "$@"
