"""Invoke tasks for robodev."""

from pathlib import Path

from invoke import task

VENDOR_DIR = Path("vendor")
AGENTSKILLS_DIR = VENDOR_DIR / "agentskills"
SKILLS_REF_DIR = AGENTSKILLS_DIR / "skills-ref"
AGENTSKILLS_REPO = "https://github.com/agentskills/agentskills"
SKILLS_DIR = Path("skills")


@task
def init(c):
    """Clone agentskills repo and install skills-ref into the active venv."""
    VENDOR_DIR.mkdir(exist_ok=True)
    if AGENTSKILLS_DIR.exists():
        print(f"{AGENTSKILLS_DIR} already exists, pulling latest...")
        c.run(f"git -C {AGENTSKILLS_DIR} pull --ff-only")
    else:
        c.run(f"git clone {AGENTSKILLS_REPO} {AGENTSKILLS_DIR}")
    c.run(f"uv pip install -e {SKILLS_REF_DIR}")
    print("skills-ref installed. Run `invoke validate` to check your skills.")


@task
def validate(c):
    """Validate all skill directories under skills/ using skills-ref."""
    skill_dirs = sorted(p for p in SKILLS_DIR.iterdir() if p.is_dir())
    if not skill_dirs:
        print("No skill directories found under skills/")
        return
    failed = []
    for skill_dir in skill_dirs:
        result = c.run(f"skills-ref validate {skill_dir}", warn=True)
        if result.exited != 0:
            failed.append(skill_dir.name)
    if failed:
        print(f"\nValidation failed for: {', '.join(failed)}")
        raise SystemExit(1)
    else:
        print(f"\nAll {len(skill_dirs)} skills valid.")
