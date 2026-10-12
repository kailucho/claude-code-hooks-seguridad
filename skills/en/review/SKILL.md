---
name: review
description: Reviews the current diff (or a branch) for bugs, security issues and debt, and returns prioritized findings. Use when the user says "review", "code review" or "what do you think of these changes".
---

# Code review

1. Get the diff: `git diff` + `git diff --staged`, or `git diff <base>...HEAD` if the user names a branch.
2. Read the context you need from every touched file (not just the diff lines).
3. Look for, in this order:
   1. **Correctness**: edge cases, null/undefined, async without `await`, race conditions, off-by-one, error handling that swallows exceptions.
   2. **Security**: injection (SQL, shell, XSS), secrets in code, input validation, missing authorization in resolvers/endpoints, sensitive data in logs.
   3. **Data and API**: irreversible migrations, breaking contract changes (REST/GraphQL), N+1 in resolvers.
   4. **Performance**: unnecessary React renders, effects with wrong dependencies, queries in loops.
   5. **Maintainability**: duplication, confusing names, dead code, missing tests for new logic.
4. Return a table ordered by severity:

   | Sev. | File:line | Problem | Suggestion |
   |------|-----------|---------|------------|
   | 🔴 high / 🟡 medium / ⚪ minor | ... | ... | ... |

5. Only report what you can justify with a concrete scenario. If you find nothing serious, say so. Do not apply changes unless the user asks.
