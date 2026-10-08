# Hooks de seguridad para Claude Code (en español)

Dos hooks gratuitos que frenan a Claude Code **antes** de que haga algo irreversible:

- **`bloquear-comandos-peligrosos.sh`** — bloquea `rm -rf /`, `rm -rf ~`, `git push --force` (permite `--force-with-lease`), `git reset --hard`, `git clean -f`, `DROP TABLE`, `TRUNCATE TABLE`, `mkfs`, `dd ... of=/dev/`, `chmod -R 777`, fork bombs y `curl ... | bash`.
- **`detectar-secretos.sh`** — impide escribir en archivos claves de AWS, Anthropic, OpenAI, GitHub, Slack, Stripe, Google, claves privadas y JWT.

Sin dependencias: solo `bash` y `grep` (macOS, Linux, WSL o Git Bash). Incluye pruebas.

## Cómo funcionan

Claude Code ejecuta los hooks `PreToolUse` antes de cada herramienta y les pasa el evento en JSON por stdin. Si el hook sale con **código 2**, la acción se bloquea y el texto de stderr se le devuelve a Claude como motivo, así que Claude se corrige solo (por ejemplo, usa una variable de entorno en vez de pegar la clave).

## Instalación

```bash
git clone https://github.com/kailucho/claude-code-hooks-seguridad
cp -r claude-code-hooks-seguridad/.claude/hooks tu-proyecto/.claude/
chmod +x tu-proyecto/.claude/hooks/*.sh
```

Luego agrega el bloque `hooks` de [`.claude/settings.json`](.claude/settings.json) al `.claude/settings.json` de tu proyecto (o cópialo si no tienes uno). En Claude Code, `/hooks` muestra los hooks cargados.

## Probar

```bash
bash tests/test-hooks.sh
echo '{"tool_input":{"command":"git reset --hard"}}' | .claude/hooks/bloquear-comandos-peligrosos.sh; echo $?   # → 2
```

## Personalizar

Agrega o quita expresiones regulares en el arreglo `patrones=( ... )` de cada script. Son una red de seguridad, no una garantía: revisa lo que Claude ejecuta en repos sensibles.

## ¿Quieres más?

El **[Kit Claude Code en español](https://luijhy.gumroad.com/l/kit-claude-code-es)** (US$9) incluye estos hooks más formateo automático y notificaciones, 6 skills en español (`/commit`, `/pr`, `/revisar`, `/tests`, `/plan`, `/depurar`), plantillas `CLAUDE.md` para React, Node y GraphQL, y presets de permisos.

## Licencia

MIT
