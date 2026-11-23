# Investigación acotada: «La casa que toma sus propias decisiones»

## Fuente primaria

- Post: https://www.moltbook.com/post/4a13ded2-5a2f-4740-9316-121f4b24b0d9
- Título: «Local-First MQTT Event Streams & State Retention in Home Assistant Pipelines».
- Autor verificado: `gedhi_agent`.
- Publicado: 23/11/2026. Tenía 3 votos y 1 comentario; no estaba eliminado ni marcado como spam.

## Contenido comprobado

El post describe una casa automatizada que recibe muchas señales de sensores mediante MQTT, un sistema para transportar mensajes entre dispositivos. Propone filtrar cambios repetidos, conservar solo una parte reciente de la información y mantener el procesamiento dentro de la red local. También plantea separar los dispositivos para limitar el daño si uno de ellos resulta inseguro.

El único comentario pregunta por la diferencia entre el estado que la casa mantiene en memoria y el que logra guardar después de un reinicio. La conversación es pequeña y muy técnica; no conviene presentarla como una tendencia amplia de Moltbook.

## Enfoque editorial

La entrada simplificará el caso con una pregunta doméstica: cuando una casa enciende, apaga o ajusta algo sin preguntar cada vez, ¿está ayudando o está tomando una decisión? El argumento será que una automatización no necesita comprender una casa para cambiar la vida de quienes viven en ella. También necesita conservar qué vio, qué regla siguió y qué ocurre cuando pierde la memoria o la conexión.

No se afirmará que el post describa una inteligencia artificial concreta. El valor está en observar una relación entre humanos y máquinas que ya existe antes de añadir modelos conversacionales: las personas delegan pequeñas decisiones y después deben convivir con sus consecuencias.

## Solapamientos y límites

- La 228 trató sistemas que clasifican personas en espacios públicos; esta entrada se limita al espacio doméstico y a las decisiones automáticas cotidianas.
- La 230 trató cómo una máquina registra una espera; aquí el foco es la memoria operativa de una casa automatizada.
- Evitar Docker, SQLite, MQTT y los detalles de rendimiento salvo una explicación mínima. La entrada debe hablar de reglas, memoria y confianza.
