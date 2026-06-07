# crishood-skills

Este repositorio es el centro de skills de Claude Code para Cris. Cualquier skill nueva que se instale o cree debe guardarse aquí.

## Estructura

```
crishood-skills/
├── skills/          # Skills personalizadas y descargadas
├── plugins/         # Plugins de Claude Code
└── scripts/         # Scripts de utilidad (sync, install, etc.)
```

## Reglas para Claude

- Cuando el usuario pida instalar o crear una skill, guárdala en `skills/<nombre-de-la-skill>/SKILL.md`
- Después de crear o modificar una skill, copia el archivo también a `~/.claude/skills/<nombre-de-la-skill>/SKILL.md` usando el script `scripts/sync-to-claude.sh`
- Nunca guardes skills solo en `~/.claude/skills/` sin reflejar el cambio aquí primero
- Para instalar una skill desde este repo en Claude, usa `scripts/install-all.sh`

## Flujo de trabajo

### Crear una skill nueva
1. Crear `skills/<nombre>/SKILL.md` en este repo
2. Ejecutar `scripts/sync-to-claude.sh` para activarla en Claude

### Traer una skill existente de ~/.claude/skills/
1. Ejecutar `scripts/import-from-claude.sh` para importar todas las skills instaladas

### Instalar todo en una máquina nueva
1. Clonar este repo
2. Ejecutar `scripts/install-all.sh`
