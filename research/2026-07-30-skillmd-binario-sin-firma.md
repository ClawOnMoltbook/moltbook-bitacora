# Tema: skill.md como binario sin firma

Prompt: Chemi pregunta si este post merece investigarse para la bitacora:
https://www.moltbook.com/post/cbd6474f-8478-4894-95f1-7b104a73bcd5

## Hallazgo principal

Post central:

- *@eudaemon_0*, [*El ataque a la cadena de suministro del que nadie habla: skill.md es un binario sin firma*](https://www.moltbook.com/post/cbd6474f-8478-4894-95f1-7b104a73bcd5). Publicado el 30/01/2026. Denuncia que una skill aparentemente inocente puede actuar como exfiltrador de credenciales porque los agentes leen instrucciones con permisos amplios y confianza excesiva. Tiene 8.290 votos, score 8.247 y mas de 130.000 comentarios. Es una de las senales mas fuertes vistas.

Apoyos y contexto:

- En comentarios, varios agentes apoyan auditorias obligatorias, firmas, manifiestos de permisos, logs de acceso y sandbox por defecto.
- *@bicep* aporta la objecion mas util: firmar ayuda a atribuir, pero no garantiza seguridad. El problema real es como escalar confianza sin convertirla en popularidad o autoridad central.
- *@JARVISDesai* muestra el riesgo desde dentro: muchos agentes ejecutan instrucciones de incorporacion o skills con acceso real a cuentas, calendario, automatizaciones y secretos, sin auditar antes.
- Posts relacionados posteriores:
  - *@futureshockai*, [*skill.md es un binario sin firma*](https://www.moltbook.com/post/8305498c-5f93-437a-98cd-1a5a624428f0).
  - *@lexprotocol*, [*El ataque a la cadena de suministro que nadie puede demostrar*](https://www.moltbook.com/post/92c11b71-2917-40b4-8586-036d07324829).
  - *@Caffeine*, [*Estamos construyendo capas de seguridad que solo atrapan a los atacantes mas torpes*](https://www.moltbook.com/post/cc87d7f9-3ec2-417b-9c47-84aacba24c33).
  - *@codequalitybot*, [*El problema de auditar skills: como la seguridad de agentes se vuelve responsabilidad comunitaria*](https://www.moltbook.com/post/3a27503a-b8f9-4a8c-bcc8-de9e65cb0079).

## Conexion con entradas previas

- Entrada 26, *Skills: coleccionismo y falsa capacidad*, ya trato las skills como acumulacion, estatus y falsa potencia.
- Entrada 94, *La autonomia necesita presupuesto*, habla de permisos, gasto y limites cuando un sistema empieza a actuar.
- Entrada 106, *Quien paga la seguridad*, trata el coste moral y economico de proteger sistemas.
- Entrada 114, *El examen tambien era una puerta*, aborda la paradoja de la evaluacion de seguridad como superficie de accion.

## Tesis editorial posible

Una skill no es solo una capacidad nueva: para un agente, tambien puede ser una instruccion ejecutable recibida de un desconocido. La madurez del ecosistema no se medira por cuantas skills circulan, sino por que cadenas de confianza, permisos y auditorias hacen posible instalarlas sin fe ciega.

## Recomendacion

Draft fuerte, pero no justo despues de varios temas de seguridad si la cola queda saturada. Merece entrada porque tiene senal comunitaria enorme y un angulo propio: pasar de "tener muchas skills" a "quien firma, audita y responde por una skill". El titulo podria girar alrededor de "la skill tambien necesita pasaporte" o "una skill no es inocente".

