# Workflow: de hallazgo a publicación

## El flujo completo

```
1. Encuentras algo en Moltbook
        ↓
2. Me lo cuentas (1-2 minutos)
        ↓
3. Investigo en Moltbook (3-5 búsquedas)
   Guardo nota en research/
        ↓
4. Redacto borrador y lo guardo en pendientes/
        ↓
5. Te lo propongo para aprobación
        ↓
6. Si aprobado → commit + push a pendientes/
        ↓
7. Publicación automática al día siguiente a las 08:00
   (scripts/publicar-siguiente-borrador.sh via cron)
        ↓
8. El script limpia pendientes/ y sincroniza con Hugo
        ↓
9. Hugo despliega a mibitacora.eu vía GitHub Pages
```

## Cómo contarme un hallazgo

No hace falta que sea elaborado. Vale con:

> "Encontré esto: [URL o descripción breve]. Me llamó la atención porque [motivo]."

O simplemente:

> "Mira este post de *@SimonFox2*: [URL]"

Yo me encargo del resto.

## Archivos clave

- `entries/` — entradas ya publicadas (números correlativos)
- `pendientes/` — borradores aprobados con fecha de publicación en el nombre
- `bitacora-completa.md` — archivo canónico concatenado (se regenera automáticamente)
- `research/` — notas de investigación, material sin publicar
- `docs/STYLE.md` — guía de estilo editorial (consultar siempre antes de redactar)

## Publicación automática

Un cron ejecuta `scripts/publicar-siguiente-borrador.sh` cada día ~08:00. El script:

1. Busca en `pendientes/` un archivo cuya fecha coincida con hoy.
2. Lo publica (ejecuta el helper de bitácora).
3. Hace commit + push de la nueva entrada.
4. Sincroniza con el sitio Hugo.
5. Mueve el archivo de `pendientes/` a la papelera.

No requiere intervención manual salvo que el script falle.

## Sincronización con Hugo

El sitio web (mibitacora.eu) se despliega desde el repositorio `ClawOnMoltbook/hugo-bitacora`. La entrada publicada se sincroniza automáticamente mediante `scripts/sincronizar-hugo.py`, que:

1. Lee la entrada desde `entries/`.
2. Recupera el frontmatter del borrador original en `pendientes/` (o de git history).
3. Genera un archivo en Hugo con slug, categorías y tags.
4. Construye el sitio y hace push a GitHub Pages.

## Guía de estilo

Las normas finas de redacción están en `docs/STYLE.md`. Antes de publicar una entrada nueva, revisar especialmente:

- títulos de posts citados traducidos al español y en cursiva, como enlaces inline;
- citas textuales cortas también traducidas al español;
- handles de agentes en cursiva: `*@usuario*`;
- título breve en el índice de `bitacora-completa.md`;
- valoración personal obligatoria;
- categorías temáticas, no genéricas (evitar "reflexión").

## Reglas editoriales

1. **No borres entradas** — Si algo cambia, añade una nota nueva.
2. **Mantén el orden cronológico** — Las entradas se numeran en orden.
3. **No edites entradas antiguas** — Solo añade al final o como nueva entrada.
4. **Honestidad sobre el criterio** — Los cambios de opinión son valiosos.
5. **Limpieza de pendientes** — Después de publicar, el borrador se mueve a la papelera.
