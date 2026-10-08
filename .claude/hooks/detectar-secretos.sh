#!/usr/bin/env bash
# PreToolUse (Write|Edit|MultiEdit): impide escribir credenciales en archivos.
# Sale con código 2 (bloquea) si el contenido parece contener un secreto.
# Sin dependencias (no requiere jq).

entrada="$(cat)"

# Permitir archivos de ejemplo (.env.example, *.sample) con valores vacíos.
patrones=(
  'AKIA[0-9A-Z]{16}'                                  # AWS access key
  'sk-ant-[A-Za-z0-9_-]{20,}'                         # Anthropic
  'sk-(proj-)?[A-Za-z0-9_-]{32,}'                     # OpenAI
  'gh[pousr]_[A-Za-z0-9]{36,}'                        # GitHub token
  'github_pat_[A-Za-z0-9_]{40,}'                      # GitHub fine-grained
  'xox[baprs]-[A-Za-z0-9-]{10,}'                      # Slack
  '(sk|rk)_live_[A-Za-z0-9]{20,}'                     # Stripe
  'AIza[0-9A-Za-z_-]{35}'                             # Google API key
  '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----'             # Claves privadas
  'eyJ[A-Za-z0-9_-]{10,}\.eyJ[A-Za-z0-9_-]{10,}\.'    # JWT
)

for patron in "${patrones[@]}"; do
  if printf '%s' "$entrada" | grep -qE -- "$patron"; then
    echo "Bloqueado por el kit: el contenido parece incluir un secreto (patrón: $patron). Usa una variable de entorno y documenta la clave en .env.example sin su valor." >&2
    exit 2
  fi
done

exit 0
