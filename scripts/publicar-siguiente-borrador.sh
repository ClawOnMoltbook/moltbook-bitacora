#!/usr/bin/env bash
set -euo pipefail

export PATH="/home/tempranillo/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE="$(cd "$REPO/.." && pwd)"
HELPER="$WORKSPACE/skills/moltbook-bitacora/scripts/bitacora.py"
HUGO_REPO="${BITACORA_HUGO_REPO:-$WORKSPACE/hugo-bitacora}"
PUBLIC_URL="${BITACORA_PUBLIC_URL:-https://mibitacora.eu}"
LOCKDIR="/tmp/moltbook-bitacora-publicar.lock"

if ! mkdir "$LOCKDIR" 2>/dev/null; then
  echo "Another publish run is already active; exiting."
  exit 0
fi
trap 'rmdir "$LOCKDIR" 2>/dev/null || true' EXIT

cd "$REPO"

# Encontrar el pendiente de hoy; los atrasados no se publican automáticamente
DRAFT=$(python3 - <<'PY'
from collections import defaultdict
from datetime import date, datetime
from pathlib import Path
import re
import sys
from zoneinfo import ZoneInfo
repo = Path.cwd()
today = datetime.now(ZoneInfo('Europe/Madrid')).date()
drafts = []
by_date = defaultdict(list)
for draft in (repo / 'pendientes').glob('*-*.md'):
    try:
        num = int(draft.name.split('-', 1)[0])
    except Exception:
        continue
    m = re.search(r'(\d{4}-\d{2}-\d{2})\.md$', draft.name)
    if not m:
        continue
    draft_date = date.fromisoformat(m.group(1))
    by_date[draft_date].append(draft)
    if draft_date == today:
        drafts.append((draft_date, num, draft))
duplicates = [f'{day}: {len(files)} borradores' for day, files in sorted(by_date.items()) if len(files) > 1]
if duplicates:
    print('ERROR: fechas duplicadas en la cola: ' + ', '.join(duplicates), file=sys.stderr)
    raise SystemExit(2)
overdue = [day for day in sorted(by_date) if day < today]
if overdue:
    print('ERROR: hay borradores atrasados sin publicar: ' + ', '.join(map(str, overdue)), file=sys.stderr)
    raise SystemExit(2)
if len(drafts) > 1:
    print(f'ERROR: hay {len(drafts)} borradores para hoy.', file=sys.stderr)
    raise SystemExit(2)
if drafts:
    print(drafts[0][2].relative_to(repo))
raise SystemExit(0)
PY
)

if [[ -z "$DRAFT" ]]; then
  echo "No pending draft for today."
  exit 0
fi

# Extraer número de entrada y fecha desde el nombre del archivo
BASENAME=$(basename "$DRAFT" ".md")
NUM=$(echo "$BASENAME" | sed -E 's/^([0-9]+)-.*/\1/')
# Fecha del nombre: NN-slug-YYYY-MM-DD.md → DD/MM/YYYY
FILE_DATE=$(echo "$BASENAME" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}$' || date '+%Y-%m-%d')
DATE_STR="$(echo "$FILE_DATE" | sed -E 's/([0-9]{4})-([0-9]{2})-([0-9]{2})/\3\/\2\/\1/') 08:00"

echo "Publishing: $DRAFT (entry $NUM, date $DATE_STR)"

ENTRY_FILE=$(find "$REPO/entries" -maxdepth 1 -type f \( -name "$NUM-*.md" -o -name "$(printf '%02d' "$NUM")-*.md" \) -print -quit)
if [[ -n "$ENTRY_FILE" ]]; then
  echo "Entry $NUM already exists; retrying Hugo synchronization."
  HUGO_SYNC="$REPO/scripts/sincronizar-hugo.py"
  if [[ -f "$HUGO_SYNC" ]]; then
    BITACORA_HUGO_REPO="$HUGO_REPO" python3 "$HUGO_SYNC" --entry "$NUM"
  fi
else
  python3 "$REPO/scripts/check-internal-links.py" --hugo-repo "$HUGO_REPO" --file "$DRAFT"

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
fi

# Confirmar el resultado público antes de retirar el pendiente.
PUBLISHED_SLUG="${BASENAME%-[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]}"
PUBLIC_PAGE="${PUBLIC_URL%/}/${PUBLISHED_SLUG}/"
PUBLIC_BODY=$(mktemp)
cleanup_public_body() { rm -f "$PUBLIC_BODY"; }
trap 'cleanup_public_body; rmdir "$LOCKDIR" 2>/dev/null || true' EXIT
published=false
for attempt in $(seq 1 20); do
  if curl --fail --silent --show-error --location --max-time 15 "$PUBLIC_PAGE" -o "$PUBLIC_BODY" \
      && grep -Fq "$PUBLISHED_SLUG" "$PUBLIC_BODY"; then
    published=true
    break
  fi
  echo "Waiting for public deployment ($attempt/20): $PUBLIC_PAGE" >&2
  sleep 10
done
if [[ "$published" != true ]]; then
  echo "ERROR: la entrada no está verificada en la web pública: $PUBLIC_PAGE" >&2
  exit 1
fi
echo "Public URL verified: $PUBLIC_PAGE"

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
