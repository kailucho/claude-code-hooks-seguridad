#!/usr/bin/env bash
# PreToolUse (Bash): bloquea comandos destructivos antes de que se ejecuten.
# Claude Code envía el evento como JSON por stdin. Salir con código 2 bloquea
# la herramienta y el texto de stderr se le devuelve a Claude como motivo.
# Sin dependencias (no requiere jq).

entrada="$(cat)"

patrones=(
  'rm[[:space:]]+-[a-zA-Z]*r[a-zA-Z]*f?[a-zA-Z]*[[:space:]]+(/|~|\$HOME|\*)([[:space:]"]|$)'
  # git: busca el subcomando en cualquier posición del mismo comando (git -C dir push ...)
  # push forzado: --force (no --force-with-lease), -f combinado (-uf) o refspec con + (origin +main)
  'git[^;&|]*[[:space:]]push([[:space:]][^;&|]*)?[[:space:]](--force([^-]|$)|-[a-zA-Z]*f[a-zA-Z]*([[:space:]"]|$)|\+[^[:space:]"]+)'
  'git[^;&|]*[[:space:]]reset([[:space:]][^;&|]*)?[[:space:]]--hard'
  'git[^;&|]*[[:space:]]clean([[:space:]][^;&|]*)?[[:space:]]-[a-zA-Z]*f'
  'DROP[[:space:]]+(TABLE|DATABASE|SCHEMA)'
  'TRUNCATE[[:space:]]+TABLE'
  'mkfs\.'
  'dd[[:space:]]+if=.*of=/dev/'
  'chmod[[:space:]]+-R[[:space:]]+777'
  ':\(\)[[:space:]]*\{[[:space:]]*:\|:&[[:space:]]*\};:'
  '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh'
)

for patron in "${patrones[@]}"; do
  if printf '%s' "$entrada" | grep -qiE -- "$patron"; then
    echo "Bloqueado por el kit: el comando coincide con un patrón peligroso ($patron). Si de verdad es necesario, pide al usuario que lo ejecute manualmente." >&2
    exit 2
  fi
done

exit 0
