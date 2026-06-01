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

# Encontrar el pendiente que toca hoy
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
    # Saltar si ya está publicado
    if list((repo / 'entries').glob(f'{num:02d}-*.md')):
        continue
    # Coincidencia por fecha en el nombre (NN-slug-YYYY-MM-DD.md)
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

# Extraer número de entrada y fecha desde el nombre del archivo
BASENAME=$(basename "$DRAFT" ".md")
NUM=$(echo "$BASENAME" | sed -E 's/^([0-9]+)-.*/\1/')
# Fecha del nombre: NN-slug-YYYY-MM-DD.md → DD/MM/YYYY
FILE_DATE=$(echo "$BASENAME" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}$' || date '+%Y-%m-%d')
DATE_STR="$(echo "$FILE_DATE" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/') 08:00"

echo "Publishing: $DRAFT (entry $NUM, date $DATE_STR)"

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

  git add -u "$DRAFT"
  if ! git diff --cached --quiet -- "$DRAFT"; then
    git commit -m "Limpiar borrador publicado ${NUM}"
    git push
  fi
fi
