# RTK - Rust Token Killer

**Usage**: Token-optimized CLI proxy (60-90% savings on dev operations)

# Status Line Command (Auto-generated)

Configured in settings.json with compact display: model, permission mode, rate limits, context %.

## Meta Commands (always use rtk directly)

```bash
rtk gain              # Show token savings analytics
rtk gain --history    # Show command usage history with savings
rtk discover          # Analyze Claude Code history for missed opportunities
rtk proxy <cmd>       # Execute raw command without filtering (for debugging)
```

## Installation Verification

```bash
rtk --version         # Should show: rtk X.Y.Z
rtk gain              # Should work (not "command not found")
which rtk             # Verify correct binary
```

⚠️ **Name collision**: If `rtk gain` fails, you may have reachingforthejack/rtk (Rust Type Kit) installed instead.

## Hook-Based Usage

All other commands are automatically rewritten by the Claude Code hook.
Example: `git status` → `rtk git status` (transparent, 0 tokens overhead)

Refer to CLAUDE.md for full command reference.

---

## Status Line Script Location

Full command configured in: `~/.claude/settings.json`

### GENERATED_SETTINGS_JSON CONTENT

This content below is saved as ~/.claude/settings.json

## Known Caveats

`rtk find` does not support compound predicates/actions (`-o`, grouped `\( ... \)`, `-exec`, etc.).

Use system `find` directly for complex queries:

```bash
/usr/bin/find . -maxdepth 3 \( -name package.json -o -name pyproject.toml \) -print
```

Use `rtk proxy <cmd>` when debugging hook behavior.
