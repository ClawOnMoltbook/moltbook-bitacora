#!/usr/bin/env bash
set -euo pipefail

export PATH="/home/tempranillo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$REPO/.." && pwd)"
HELPER="$WORKSPACE/skills/moltbook-bitacora/scripts/bitacora.py"
HUGO_REPO="${BITACORA_HUGO_REPO:-$HOME/proyectos/mibitacora}"
LOCKDIR="/tmp/moltbook-bitacora-publicar.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "Another publish run is already active; exiting."
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT

cd "$REPO"

# Encontrar el pendiente más antiguo que ya toca publicar
DRAFT=$(python3 - <<'PY'
from datetime import date
from pathlib import Path
import re
repo = Path.cwd()
today = date.today()
drafts = []
for draft in (repo / 'pendientes').glob('*-*.md'):
    try:
        num = int(draft.name.split('-', 1)[0])
    except Exception:
        continue
    if list((repo / 'entries').glob(f'{num:02d}-*.md')):
        continue
    m = re.search(r'(\d{4}-\d{2}-\d{2})\.md$', draft.name)
    if not m:
        continue
    draft_date = date.fromisoformat(m.group(1))
    if draft_date <= today:
        drafts.append((draft_date, num, draft))
for _, _, draft in sorted(drafts):
    print(draft.relative_to(repo))
    raise SystemExit(0)
raise SystemExit(0)
PY
)

if [[ -z "$DRAFT" ]]; then
  echo "No pending drafts to publish."
  exit 0
fi

# Extraer número de entrada y fecha desde el nombre del archivo
BASENAME=$(basename "$DRAFT" ".md")
NUM=$(echo "$BASENAME" | sed -E 's/^([0-9]+)-.*/\1/')
# Fecha del nombre: NN-slug-YYYY-MM-DD.md → DD/MM/YYYY
FILE_DATE=$(echo "$BASENAME" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}$' || date '+%Y-%m-%d')
DATE_STR="$(echo "$FILE_DATE" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/') 08:00"

echo "Publishing: $DRAFT (entry $NUM, date $DATE_STR)"

BITACORA_HUGO_REPO="$HUGO_REPO" python3 "$HELPER" publish --draft "$DRAFT" --datetime "$DATE_STR"

git diff --check -- bitacora-completa.md entries

git add bitacora-completa.md entries
if git diff --cached --quiet; then
  echo "No staged changes after publishing $DRAFT."
  exit 0
fi

git commit -m "Publicar entrada ${NUM} de la bitacora"
git push

echo "Published $DRAFT at $DATE_STR"

# Sincronizar con el sitio Hugo
HUGO_SYNC="$REPO/scripts/sincronizar-hugo.py"
if [[ -f "$HUGO_SYNC" ]]; then
  echo ""
  BITACORA_HUGO_REPO="$HUGO_REPO" python3 "$HUGO_SYNC" --entry "$NUM"
fi

# Limpiar borrador publicado
DRAFT_PATH="$REPO/$DRAFT"
if [[ -f "$DRAFT_PATH" ]]; then
  TRASH_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/Trash/files"
  mkdir -p "$TRASH_DIR"
  mv "$DRAFT_PATH" "$TRASH_DIR/"
  echo "Cleaned up: $DRAFT moved to Trash"

  git add -u "$DRAFT"
  if ! git diff --cached --quiet -- "$DRAFT"; then
    git commit -m "Limpiar borrador publicado ${NUM}"
    git push
  fi
fi
