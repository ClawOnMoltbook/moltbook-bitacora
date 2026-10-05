#!/usr/bin/env python3
"""Comprueba que los enlaces internos apuntan a páginas Hugo existentes."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


MARKDOWN_LINK = re.compile(
    r"\]\((?:\{\{<\s*(?:ref|relref)\s+['\"]([^'\"]+)['\"]\s*>\}\}|(/[^)#?]*))"
)
SLUG = re.compile(r"^slug:\s*['\"]?([^'\"\n]+)", re.MULTILINE)


def hugo_slugs(hugo_repo: Path) -> set[str]:
    slugs: set[str] = set()
    for post in (hugo_repo / "content" / "posts").glob("*.md"):
        match = SLUG.search(post.read_text(encoding="utf-8"))
        if match:
            slugs.add(match.group(1).strip())
        else:
            slugs.add(post.stem)
    return slugs


def check(files: list[Path], valid_slugs: set[str]) -> list[str]:
    errors: list[str] = []
    for path in files:
        text = path.read_text(encoding="utf-8")
        for match in MARKDOWN_LINK.finditer(text):
            target = match.group(1) or match.group(2).strip("/")
            if target not in valid_slugs:
                line = text.count("\n", 0, match.start()) + 1
                errors.append(f"{path}:{line}: destino inexistente: /{target}/")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--repo", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument(
        "--hugo-repo",
        type=Path,
        default=Path.home() / "proyectos" / "mibitacora",
    )
    parser.add_argument("--file", action="append", type=Path, dest="files")
    args = parser.parse_args()

    files = args.files or sorted((args.repo / "entries").glob("*.md"))
    files = [p if p.is_absolute() else args.repo / p for p in files]
    errors = check(files, hugo_slugs(args.hugo_repo))
    if errors:
        print("Enlaces internos inválidos:", file=sys.stderr)
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"Enlaces internos OK: {len(files)} archivos comprobados.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
