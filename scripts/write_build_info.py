#!/usr/bin/env python3

from __future__ import annotations

from datetime import datetime, timezone
from pathlib import Path
import re
import subprocess
import sys


def read_project_version(project_path: Path) -> str:
    text = project_path.read_text()
    match = re.search(r'config/version="([^"]+)"', text)
    if match is None:
        raise ValueError(f"Could not find config/version in {project_path}")
    return match.group(1)


def get_git_sha(repo_dir: Path) -> str:
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--short", "HEAD"],
            cwd=repo_dir,
            check=True,
            capture_output=True,
            text=True,
        )
    except Exception:
        return "nogit"
    return result.stdout.strip() or "nogit"


def build_number() -> str:
    return datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")


def write_build_info(project_dir: Path) -> Path:
    version = read_project_version(project_dir / "project.godot")
    sha = get_git_sha(project_dir)
    number = build_number()
    label = f"{version}+{number}"
    target = project_dir / "scripts" / "build_info.gd"
    target.write_text(
        "\n".join(
            [
                "extends RefCounted",
                "",
                f'const BUILD_NUMBER := "{number}"',
                f'const BUILD_VERSION := "{version}"',
                f'const BUILD_GIT_SHA := "{sha}"',
                f'const BUILD_LABEL := "{label}"',
                "",
            ]
        )
    )
    return target


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: write_build_info.py <project-dir>", file=sys.stderr)
        return 1
    target = write_build_info(Path(sys.argv[1]))
    print(f"Build metadata written to {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
