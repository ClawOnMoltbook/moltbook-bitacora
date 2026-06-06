#!/usr/bin/env python3
"""
Sincroniza una entrada publicada de la bitácora con el sitio Hugo.

Uso:
    python3 sincronizar-hugo.py --entry NUMERO

Ejemplo:
    python3 sincronizar-hugo.py --entry 55

Busca el borrador original en pendientes/ o drafts/ para leer
el frontmatter (hugo_categories, hugo_tags, index_title).
"""
from __future__ import annotations

import argparse
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path

REPO_BITACORA = Path("/Users/josemiguel/.openclaw/workspace/moltbook-bitacora")
REPO_HUGO = Path("/Users/josemiguel/experimentos/hugo-bitacora")


def slugify(s: str) -> str:
    import unicodedata
    s = unicodedata.normalize("NFKD", s).encode("ascii", "ignore").decode("ascii")
    s = s.lower()
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s


def parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    """Parse YAML frontmatter from draft/entry text."""
    meta: dict[str, str] = {}
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.DOTALL)
    if m:
        raw = m.group(1)
        for line in raw.splitlines():
            if ":" in line:
                key, _, val = line.partition(":")
                meta[key.strip()] = val.strip().strip('"').strip("'")
        body = text[m.end():]
    else:
        body = text
    return meta, body


def find_entry_file(num: int) -> Path | None:
    """Encuentra la entrada en entries/."""
    for p in sorted((REPO_BITACORA / "entries").glob(f"{num:02d}-*.md")):
        return p
    return None


def find_draft_file(num: int) -> Path | None:
    """Busca el borrador original en pendientes/ o drafts/."""
    for base in ["pendientes", "drafts"]:
        d = REPO_BITACORA / base
        if d.exists():
            for p in sorted(d.glob(f"{num:02d}-*.md")):
                return p
            # También buscar NN-slug-YYYY-MM-DD.md
            for p in sorted(d.glob(f"{num}-*-*.md")):
                return p
    return None


def recover_draft_from_git(num: int) -> str | None:
    """Recupera el frontmatter del borrador original desde git history.
    
    Útil cuando el pendiente se ha eliminado pero estaba versionado en git.
    """
    # Buscar el archivo pendiente borrado más reciente que coincida con el número
    result = subprocess.run(
        ["git", "log", "--diff-filter=D", "--name-only", "--pretty=format:%H",
         "-1", "--", f"pendientes/{num:02d}-*.md", f"drafts/{num:02d}-*.md",
         f"pendientes/{num}-*.md", f"drafts/{num}-*.md"],
        cwd=str(REPO_BITACORA),
        capture_output=True, text=True, timeout=30
    )
    lines = [l.strip() for l in result.stdout.splitlines() if l.strip()]
    if len(lines) < 2:
        return None
    # Primera línea = commit hash donde se borró
    delete_commit = lines[0]
    # Segunda línea = path del archivo borrado
    file_path = lines[1]
    # Mostrar el contenido del archivo en el commit padre (antes de borrarlo)
    result = subprocess.run(
        ["git", "show", f"{delete_commit}^:{file_path}"],
        cwd=str(REPO_BITACORA),
        capture_output=True, text=True, timeout=30
    )
    if result.returncode == 0 and result.stdout:
        return result.stdout
    return None


def parse_tags_from_frontmatter(meta: dict) -> tuple[list[str], list[str]]:
    """Extrae categorías y etiquetas del frontmatter."""
    cats_raw = meta.get("hugo_categories", "")
    tags_raw = meta.get("hugo_tags", "")
    categories = [c.strip() for c in cats_raw.split(",") if c.strip()]
    tags = [t.strip() for t in tags_raw.split(",") if t.strip()]
    return categories, tags


def generate_hugo_content(
    entry_text: str,
    draft_meta: dict[str, str],
) -> str:
    """Genera el contenido del archivo Hugo a partir de la entrada."""
    # Parsear la entrada bitácora
    meta, body = parse_frontmatter(entry_text)

    # Extraer título del heading ## NN. Title
    lines = body.strip().splitlines()
    title_line = lines[0] if lines else ""
    m = re.match(r"^##\s+\d+\.\s+(.+)$", title_line)
    if not m:
        print(f"  ⚠ No se pudo extraer título de: {title_line[:60]}", file=sys.stderr)
        return ""
    full_title = m.group(1).strip()

    # Extraer número del título
    num_m = re.match(r"^##\s+(\d+)", title_line)
    num = int(num_m.group(1)) if num_m else 0

    # Extraer fecha de publicación sin obligar a mostrarla en el cuerpo.
    date_line = ""
    for line in lines[1:4]:
        mm = re.match(r"^\[?(\d{2}/\d{2}/\d{4} \d{2}:\d{2})\]?$", line)
        if mm:
            date_line = mm.group(1)
            break

    if date_line:
        dt = datetime.strptime(date_line, "%d/%m/%Y %H:%M")
        date_iso = dt.strftime("%Y-%m-%dT%H:%M:%S+02:00")
    elif entry_path := find_entry_file(num):
        filename_date = re.search(r"-(\d{4}-\d{2}-\d{2})$", entry_path.stem)
        if filename_date:
            dt = datetime.strptime(filename_date.group(1), "%Y-%m-%d")
            date_iso = dt.strftime("%Y-%m-%dT08:00:00+02:00")
        else:
            date_iso = datetime.now().strftime("%Y-%m-%dT%H:%M:%S+02:00")
    else:
        date_iso = datetime.now().strftime("%Y-%m-%dT%H:%M:%S+02:00")

    # Slug (del nombre del archivo de entrada, sin fecha al final)
    entry_path = find_entry_file(num)
    slug = ""
    if entry_path:
        stem_m = re.match(r"\d+-(.+)", entry_path.stem)
        if stem_m:
            stem_base = stem_m.group(1)
            # Quitar fecha del final (YYYY-MM-DD) si existe
            stem_base = re.sub(r"-\d{4}-\d{2}-\d{2}$", "", stem_base)
            slug = f"{num}-{stem_base}"
    if not slug:
        slug = slugify(f"{num}-{full_title}")

    # Categorías y tags del frontmatter del borrador original
    categories, tags = parse_tags_from_frontmatter(draft_meta)

    # Construir frontmatter YAML
    fm_lines = ["---"]
    fm_lines.append(f'title: "{num}. {full_title}"')
    fm_lines.append(f'date: "{date_iso}"')
    fm_lines.append("draft: false")
    fm_lines.append(f'slug: "{slug}"')
    if categories:
        fm_lines.append(f"categories: {categories}")
    if tags:
        fm_lines.append(f"tags: {tags}")
    fm_lines.append("---")

    # Cuerpo: omitir heading ## y fecha, solo el contenido
    content_lines = []
    for line in lines:
        if re.match(r"^##\s+\d+\.", line):
            continue  # omitir heading
        if re.match(r"^\[?\d{2}/\d{2}/\d{4} \d{2}:\d{2}\]?$", line):
            continue  # omitir línea de fecha
        if line.strip() == "---":
            continue  # omitir separador final
        content_lines.append(line)

    # Quitar líneas en blanco del inicio
    while content_lines and not content_lines[0].strip():
        content_lines.pop(0)

    body_text = "\n".join(content_lines).strip() + "\n"

    return "\n".join(fm_lines) + "\n\n" + body_text


def sync_entry(num: int) -> bool:
    """Sincroniza una entrada con el sitio Hugo."""
    entry_file = find_entry_file(num)
    if not entry_file:
        print(f"  ✗ Entrada {num} no encontrada en entries/", file=sys.stderr)
        return False

    print(f"  → Sincronizando entrada {num} con Hugo...")

    # Leer entrada
    entry_text = entry_file.read_text(encoding="utf-8")

    # Leer borrador original para frontmatter
    draft_file = find_draft_file(num)
    draft_meta: dict[str, str] = {}
    if draft_file:
        draft_text = draft_file.read_text(encoding="utf-8")
        draft_meta, _ = parse_frontmatter(draft_text)
        print(f"    Frontmatter del borrador: {draft_file.name}")
    else:
        # Fallback: recuperar frontmatter desde git history
        print(f"    ⚠ No se encontró borrador original, buscando en git history...")
        git_text = recover_draft_from_git(num)
        if git_text:
            draft_meta, _ = parse_frontmatter(git_text)
            if draft_meta:
                print(f"    ✓ Frontmatter recuperado de git: {len(draft_meta)} campos")
            else:
                print(f"    ⚠ Frontmatter vacío en git, usando metadatos por defecto")
        else:
            print(f"    ⚠ No se encontró borrador en git, usando metadatos por defecto")

    # Generar contenido Hugo
    content = generate_hugo_content(entry_text, draft_meta)
    if not content:
        return False

    # Slug
    slug_match = re.search(r'slug: "(.+)"', content)
    slug = slug_match.group(1) if slug_match else f"{num:02d}-entrada"
    hugo_path = REPO_HUGO / "content" / "posts" / f"{slug}.md"

    # Escribir archivo
    hugo_path.write_text(content, encoding="utf-8")
    print(f"    Archivo: {hugo_path.relative_to(REPO_HUGO)}")

    # Build Hugo
    print(f"    Build Hugo...")
    result = subprocess.run(
        ["hugo", "--destination", "docs"],
        cwd=str(REPO_HUGO),
        capture_output=True, text=True, timeout=60
    )
    if result.returncode != 0:
        print(f"    ✗ Error en build Hugo:", file=sys.stderr)
        print(result.stderr, file=sys.stderr)
        return False

    # Extraer número de páginas del output
    pages_match = re.search(r"Pages\s+\|\s+(\d+)", result.stdout)
    if pages_match:
        print(f"    Build OK: {pages_match.group(1)} páginas")

    # Commit y push
    print(f"    Git commit y push...")
    subprocess.run(["git", "add", "-A"], cwd=str(REPO_HUGO), capture_output=True)
    result = subprocess.run(
        ["git", "diff", "--cached", "--quiet"],
        cwd=str(REPO_HUGO), capture_output=True
    )
    if result.returncode != 0:
        subprocess.run(
            ["git", "commit", "-m", f"Sincroniza entrada {num} de la bitácora"],
            cwd=str(REPO_HUGO), capture_output=True
        )
        push = subprocess.run(
            ["git", "push"],
            cwd=str(REPO_HUGO), capture_output=True, text=True
        )
        if push.returncode == 0:
            print(f"  ✅ Entrada {num} sincronizada con Hugo y pusheada")
        else:
            print(f"  ⚠ Push: {push.stderr[:200]}")
    else:
        print(f"  ℹ Sin cambios nuevos (entrada ya estaba sincronizada)")

    return True


def main() -> None:
    ap = argparse.ArgumentParser(description="Sincroniza entradas de la bitácora con Hugo")
    ap.add_argument("--entry", type=int, required=True, help="Número de entrada a sincronizar")
    args = ap.parse_args()
    success = sync_entry(args.entry)
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
