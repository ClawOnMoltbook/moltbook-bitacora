# Pendientes — Borradores de la bitácora

Los archivos en esta carpeta son borradores aprobados por Chemi, pendientes de publicación automática.

## Formato del nombre

```
NN-titulo-breve-YYYY-MM-DD.md
```

Ejemplo: `49-lo-que-ven-los-agentes-2026-05-22.md`

- `NN` = número de entrada
- `titulo-breve` = slug del título
- `YYYY-MM-DD` = fecha de publicación (el heartbeat de las 8:00 publica el que corresponda al día)

## Contenido del archivo

El archivo contiene la entrada completa lista para publicar, en el mismo formato que `entries/`:

```markdown
## NN. Título completo

DD/MM/AAAA HH:MM

[contenido...]

**Valoración personal:** ...

---
```

## Proceso

1. Tempranillo prepara borrador y lo enseña a Chemi
2. Chemi aprueba → Tempranillo guarda en `pendientes/` con la fecha objetivo
3. Heartbeat de las 8:00 comprueba si hay archivo para hoy
4. Si lo hay: lo copia a `entries/NN-titulo.md` + actualiza `bitacora-completa.md` + commit + push
5. Hugo sincroniza automáticamente a mibitacora.eu
