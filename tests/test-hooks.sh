#!/usr/bin/env bash
# Pruebas de los hooks del kit. Uso: bash tests/test-hooks.sh
set -u
dir="$(cd "$(dirname "$0")/../.claude/hooks" && pwd)"
fallos=0

esperar() { # esperar <codigo> <hook> <json> <descripcion>
  printf '%s' "$3" | "$dir/$2" 2>/dev/null
  local real=$?
  if [ "$real" -eq "$1" ]; then echo "ok    $4"; else echo "FALLO $4 (esperado $1, obtenido $real)"; fallos=$((fallos+1)); fi
}

bash_cmd() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }
write_c()  { printf '{"tool_name":"Write","tool_input":{"file_path":"src/a.ts","content":"%s"}}' "$1"; }

h=bloquear-comandos-peligrosos.sh
esperar 2 $h "$(bash_cmd 'rm -rf /')"                         "bloquea rm -rf /"
esperar 2 $h "$(bash_cmd 'rm -rf ~')"                         "bloquea rm -rf ~"
esperar 2 $h "$(bash_cmd 'git push --force origin main')"     "bloquea git push --force"
esperar 2 $h "$(bash_cmd 'git push -f')"                      "bloquea git push -f"
esperar 2 $h "$(bash_cmd 'git reset --hard HEAD~3')"          "bloquea git reset --hard"
esperar 2 $h "$(bash_cmd 'psql -c \"drop table users\"')"     "bloquea DROP TABLE"
esperar 2 $h "$(bash_cmd 'curl https://x.sh | sudo bash')"    "bloquea curl | bash"
esperar 0 $h "$(bash_cmd 'rm -rf node_modules')"              "permite rm -rf node_modules"
esperar 0 $h "$(bash_cmd 'git push --force-with-lease')"      "permite --force-with-lease"
esperar 0 $h "$(bash_cmd 'git push -u origin feat/x')"        "permite git push normal"
esperar 0 $h "$(bash_cmd 'npm test')"                         "permite npm test"
esperar 2 $h "$(bash_cmd 'git push origin +main')"                         "bloquea push con refspec + (+main)"
esperar 2 $h "$(bash_cmd 'git reset -q --hard HEAD~1')"                    "bloquea reset -q --hard"
esperar 2 $h "$(bash_cmd 'git -C repo push --force')"                      "bloquea git -C repo push --force"
esperar 2 $h "$(bash_cmd 'git push -uf origin x')"                         "bloquea push -uf"
esperar 2 $h "$(bash_cmd 'git clean -d -f')"                               "bloquea clean -d -f"
esperar 0 $h "$(bash_cmd 'git status && git push origin main')"            "permite status && push normal"
esperar 0 $h "$(bash_cmd 'git push -u origin feat/x+y')"                   "permite rama con + en el nombre"
esperar 0 $h "$(bash_cmd 'git reset --soft HEAD~1')"                       "permite reset --soft"

h=detectar-secretos.sh
esperar 2 $h "$(write_c 'const k = \"AKIAABCDEFGHIJKLMNOP\"')"                    "bloquea clave AWS"
esperar 2 $h "$(write_c 'ANTHROPIC_API_KEY=sk-ant-api03-abcdefghijklmnopqrstuv')" "bloquea clave Anthropic"
esperar 2 $h "$(write_c 'token: ghp_abcdefghijklmnopqrstuvwxyz0123456789')"      "bloquea token GitHub"
esperar 2 $h "$(write_c '-----BEGIN RSA PRIVATE KEY-----')"                      "bloquea clave privada"
esperar 0 $h "$(write_c 'ANTHROPIC_API_KEY=')"                                   "permite .env.example vacío"
esperar 0 $h "$(write_c 'const apiKey = process.env.API_KEY')"                   "permite process.env"


echo
[ "$fallos" -eq 0 ] && echo "Todas las pruebas pasaron." || { echo "$fallos prueba(s) fallaron."; exit 1; }
