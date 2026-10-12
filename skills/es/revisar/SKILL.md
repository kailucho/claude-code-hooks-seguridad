---
name: revisar
description: Revisa el diff actual (o una rama) buscando bugs, problemas de seguridad y deuda, y entrega hallazgos priorizados. Úsala cuando el usuario pida "revisa", "code review" o "qué opinas de estos cambios".
---

# Revisión de código

1. Obtén el diff: `git diff` + `git diff --staged`, o `git diff <base>...HEAD` si el usuario nombra una rama.
2. Lee el contexto necesario de cada archivo tocado (no solo las líneas del diff).
3. Busca, en este orden:
   1. **Correctitud**: casos borde, null/undefined, async sin `await`, condiciones de carrera, off-by-one, manejo de errores que traga excepciones.
   2. **Seguridad**: inyección (SQL, comandos, XSS), secretos en código, validación de entrada, autorización faltante en resolvers/endpoints, datos sensibles en logs.
   3. **Datos y API**: migraciones irreversibles, cambios incompatibles de contrato (REST/GraphQL), N+1 en resolvers.
   4. **Rendimiento**: renders innecesarios en React, efectos sin dependencias correctas, consultas en bucles.
   5. **Mantenibilidad**: duplicación, nombres confusos, código muerto, tests faltantes para la lógica nueva.
4. Entrega una tabla ordenada por severidad:

   | Sev. | Archivo:línea | Problema | Sugerencia |
   |------|---------------|----------|------------|
   | 🔴 alta / 🟡 media / ⚪ menor | ... | ... | ... |

5. Solo reporta lo que puedas justificar con un escenario concreto. Si no encuentras nada serio, dilo. No apliques cambios salvo que el usuario lo pida.
