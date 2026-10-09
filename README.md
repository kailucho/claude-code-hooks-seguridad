# Hooks de seguridad para Claude Code (en español)

[![tests](https://github.com/kailucho/claude-code-hooks-seguridad/actions/workflows/tests.yml/badge.svg)](https://github.com/kailucho/claude-code-hooks-seguridad/actions/workflows/tests.yml)


> 🇬🇧 **English:** two free, dependency-free bash `PreToolUse` hooks for Claude Code. One blocks destructive commands before they run (`rm -rf /`, `git push --force` while allowing `--force-with-lease`, `git reset --hard`, `git clean -f`, `DROP TABLE`, `curl | bash`…); the other blocks writing credentials to files (AWS, Anthropic, OpenAI, GitHub, Stripe, Slack, Google keys, private keys, JWTs). Exit code 2 makes Claude Code block the tool call and feeds the reason back to Claude, so it explains instead of retrying. Install: copy `.claude/hooks/` into your project, `chmod +x` them and merge the `hooks` block from [`.claude/settings.json`](.claude/settings.json). Run `bash tests/test-hooks.sh` to test. Block messages are in Spanish; edit the `echo` lines to change them. Want the full kit (6 skills, 4 hooks, CLAUDE.md templates, presets) in English or Spanish? → [luijhy.gumroad.com](https://luijhy.gumroad.com)
>
> Unofficial; not affiliated with Anthropic.

Dos hooks gratuitos que frenan a Claude Code **antes** de que haga algo irreversible:

- **`bloquear-comandos-peligrosos.sh`** — bloquea `rm -rf /`, `rm -rf ~`, `git push --force` (permite `--force-with-lease`), `git reset --hard`, `git clean -f`, `DROP TABLE`, `TRUNCATE TABLE`, `mkfs`, `dd ... of=/dev/`, `chmod -R 777`, fork bombs y `curl ... | bash`.
- **`detectar-secretos.sh`** — impide escribir en archivos claves de AWS, Anthropic, OpenAI, GitHub, Slack, Stripe, Google, claves privadas y JWT.

Sin dependencias: solo `bash` y `grep` (macOS, Linux, WSL o Git Bash). Incluye pruebas que corren en CI en Linux y macOS, y están verificados dentro de Claude Code 2.1.x: Claude recibe el motivo del bloqueo y lo explica en vez de ejecutar el comando.

## Cómo funcionan

Claude Code ejecuta los hooks `PreToolUse` antes de cada herramienta y les pasa el evento en JSON por stdin. Si el hook sale con **código 2**, la acción se bloquea y el texto de stderr se le devuelve a Claude como motivo, así que Claude se corrige solo (por ejemplo, usa una variable de entorno en vez de pegar la clave).

Explicación paso a paso: [3 hooks de Claude Code que evitan desastres (dev.to)](https://dev.to/luijhy_michaelguerraflo/3-hooks-de-claude-code-que-evitan-desastres-con-codigo-2h3d).

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
