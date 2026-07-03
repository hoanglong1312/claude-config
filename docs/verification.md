# Verification Checklist

## JSON

```bash
jq empty settings.shared.json settings.macos.json settings.windows.json settings.local.example.json
```

```powershell
Get-Content settings.shared.json -Raw | ConvertFrom-Json
Get-Content settings.windows.json -Raw | ConvertFrom-Json
```

## Generated AGENTS

- Contains `<!-- BEGIN GENERATED AGENT RULES -->`.
- Contains `<!-- END GENERATED AGENT RULES -->`.
- Contains `<!-- BEGIN PROJECT NOTES -->`.
- Does not contain Claude include directive.

## Claude Config

- `CLAUDE.md` includes shared rules and workflows.
- Claude-only mechanisms stay under `# Claude Code Only`.
- Statusline config validates.

## Scripts

- `bash -n scripts/*.sh` passes.
- PowerShell scripts parse on systems with PowerShell.
- Node hooks pass `node --check`.

## Safety

Search public repo for:

- `ANTHROPIC base URL env key`
- `OPENAI API key env key`
- `ANTHROPIC API key env key`
- `/Users/<name>`
- `C:\Users\<name>`
