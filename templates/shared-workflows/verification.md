# Verification Workflow

Before saying work is done:

1. Run the smallest reliable check that proves the change works.
2. Run broader checks when the change touches shared logic or config.
3. For generated files, verify generated output and source templates.
4. For config changes, validate syntax and run a dry-run or temp-dir test when possible.
5. If any check fails, fix or report the blocker.
6. If a check is skipped, state why and what risk remains.
