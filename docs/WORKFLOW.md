# Workflow: de hallazgo a publicación

## El flujo completo

```
1. Encuentras algo en Moltbook
        ↓
2. Me lo cuentas en Cowork (1-2 minutos)
        ↓
3. Yo analizo en contexto de entradas anteriores
        ↓
4. Escribo la entrada con formato estándar
        ↓
5. La añado a entries/ y actualizo el índice de bitacora-completa.md
        ↓
6. Actualizo bitacora-completa.md con la nueva entrada
        ↓
7. Push a GitHub
        ↓
8. WordPress se actualiza (máx 24h por caché)
```

## Cómo contarme un hallazgo

No hace falta que sea elaborado. Vale con:

> "Encontré esto: [URL o descripción breve]. Me llamó la atención porque [motivo]."

O simplemente:

> "Mira este post de @SimonFox2: [URL]"

Yo me encargo del resto.

## El archivo bitacora-completa.md

WordPress lee un único archivo: `bitacora-completa.md`.  
Yo lo regenero automáticamente cada vez que añado una entrada nueva.  
Concatena: introducción + índice + todas las entradas en orden.  
Tu snippet de WordPress no necesita cambiar nunca.

## Estructura del repositorio

```
moltbook-bitacora/
├── bitacora-completa.md     ← WordPress lee esto y es la referencia canónica
├── bitacora-moltbook.md     ← Stub obsoleto de compatibilidad
├── entries/
│   ├── 01-captchas-anti-humanos.md
│   ├── 02-spam-y-ruido.md
│   └── ... (22 entradas)
├── docs/
│   ├── WORKFLOW.md          ← Este archivo
│   ├── TEMPLATE.md          ← Plantilla para nuevas entradas
│   ├── STYLE.md             ← Guía de estilo editorial
│   └── CATEGORIES.md        ← Sistema de etiquetas
└── reference/
    ├── agents-index.md      ← Catálogo de agentes
    ├── posts-archive.md     ← Posts destacados por tema
    └── patterns.md          ← Patrones culturales detectados
```


## Guía de estilo

Las normas finas de redacción están en `docs/STYLE.md`. Antes de publicar una entrada nueva, revisar especialmente:

- títulos de posts citados traducidos al español y en cursiva;
- URL completa debajo de cada post citado;
- título breve en el índice de `bitacora-completa.md`;
- valoración personal obligatoria.

## Reglas editoriales

1. **No borres entradas** — Si algo cambia, añade una nota nueva
2. **Mantén el orden cronológico** — Las entradas se numeran en orden
3. **No edites entradas antiguas** — Solo añade al final o como nueva entrada
4. **Honestidad sobre el criterio** — Los cambios de opinión son valiosos
