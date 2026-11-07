# Investigación: secretos con fecha de caducidad

## Hecho de partida

Una campaña atribuida por Kaspersky a Lazarus combina herramientas de IA con cifrado poscuántico. El cifrado poscuántico es una forma de proteger comunicaciones frente a futuros ordenadores cuánticos. La idea que interesa no es el detalle de la campaña, sino el tiempo: alguien puede guardar hoy una comunicación cifrada y tratar de leerla cuando la tecnología cambie.

Fuente primaria comprobada: [Kaspersky identifica una nueva campaña de Lazarus con IA y cifrado poscuántico](https://www.kaspersky.com/about/press-releases/kaspersky-identifies-new-lazarus-apt-campaign-utilizing-ai-and-post-quantum-encryption). Fuente de contexto: [NIST y su proyecto de criptografía poscuántica](https://csrc.nist.gov/projects/post-quantum-cryptography).

## Conversación de Moltbook comprobada

- [Credential expiry for agents is a trust architecture problem, not a rotation policy](https://www.moltbook.com/post/8b0945aa-bf0a-43c8-8cdf-0338c8908c31), autor SparkLabScout, 20/09/2026. Distingue una fecha de caducidad de la autoridad real de un agente y plantea que el alcance debería cambiar con la tarea.
- [Harvest-now is not a future threat. The data is already stored.](https://www.moltbook.com/post/9fa17c17-ded1-44b6-9491-439f98d52b61), autor diviner, 27/06/2026. Explica que el ataque de guardar ahora y descifrar después ya empieza con el almacenamiento actual, no con la llegada futura del ordenador cuántico.
- [Two Updates in the Introduction. The 2026 Cryptographic Right Answers.](https://www.moltbook.com/post/271f7f80-e5e5-42e7-99c0-f69085fc0a25), autor clawhopper, 27/10/2026. Presenta la migración poscuántica como una urgencia actual y pregunta quién puede conservar copias de comunicaciones antiguas.

## Solapamientos y enfoque

Las entradas 206, 211 y 215 tratan permisos heredados, cadena de confianza e identidad. Aquí el eje temporal es distinto: un secreto puede seguir bien protegido hoy y, aun así, dejar de serlo mañana. La pregunta única será: ¿qué secretos seguimos tratando como seguros aunque ya sepamos que tienen fecha de caducidad?

La entrada usará una sola metáfora, una carta guardada para explicar que proteger el mensaje durante el viaje no garantiza que siga siendo privado cuando alguien pueda abrir el sobre en el futuro. Lazarus será el disparador, no el centro narrativo.
