#!/bin/zsh
set -euo pipefail

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

REPO="/Users/josemiguel/.openclaw/workspace/moltbook-bitacora"
HELPER="/Users/josemiguel/.openclaw/workspace/skills/moltbook-bitacora/scripts/bitacora.py"
LOCKDIR="/tmp/moltbook-bitacora-publicar.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "Another publish run is already active; exiting."
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT

cd "$REPO"

DRAFT=$(python3 - <<'PY'
from datetime import date
from pathlib import Path
import re
repo = Path('/Users/josemiguel/.openclaw/workspace/moltbook-bitacora')
today = date.today().strftime('%Y-%m-%d')
drafts = sorted((repo / 'pendientes').glob('[0-9][0-9]-*.md'))
for draft in drafts:
    try:
        num = int(draft.name.split('-', 1)[0])
    except Exception:
        continue
    # Solo publicar si el número no está en entries/
    if list((repo / 'entries').glob(f'{num:02d}-*.md')):
        continue
    # Extraer fecha del nombre del archivo (NN-slug-YYYY-MM-DD.md)
    m = re.search(r'(\d{4}-\d{2}-\d{2})\.md$', draft.name)
    if m and m.group(1) == today:
        print(draft.relative_to(repo))
        raise SystemExit(0)
raise SystemExit(0)
PY
)

if [[ -z "$DRAFT" ]]; then
  echo "No pending drafts to publish."
  exit 0
fi

echo "Publishing: $DRAFT (entry $NUM)"

NUM=$(basename "$DRAFT" | sed -E 's/^([0-9]+)-.*/\1/')
DATE_STR="$(date '+%d/%m/%Y') 08:00"

python3 "$HELPER" publish --draft "$DRAFT" --datetime "$DATE_STR"

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
  python3 "$HUGO_SYNC" --entry "$NUM"
fi

# Limpiar borrador publicado
DRAFT_PATH="$REPO/$DRAFT"
if [[ -f "$DRAFT_PATH" ]]; then
  mv "$DRAFT_PATH" ~/.Trash/
  echo "Cleaned up: $DRAFT moved to Trash"
fi
