---
name: playwright-testing
description: Use when fixing UI bugs, adding new UI features, or verifying frontend behavior in web projects. Triggers when task involves form submission, navigation, click flows, or any UI regression risk.
---

# Playwright Testing

## DevTools vs Playwright — Decision Rule

```
Bug reported or feature added?
├── Need to FIND what's broken → DevTools (investigate)
└── Need to VERIFY fix works (now + future) → Playwright (regression)
```

**DevTools:** investigation only — network tab, console errors, DOM inspection. One-shot, ephemeral. Claude cannot run DevTools; user runs it and reports findings.

**Playwright:** verification — automated, reusable, runs headlessly via Bash. Claude writes + runs directly.

## Workflow

### 1. Bug Fix Flow
```
User reports UI bug
→ [DevTools phase] User inspects + reports: network errors, console logs, broken selector
→ Claude fixes code
→ [Playwright phase] Claude writes test → runs → confirms fix
→ Test stays in repo as regression guard
```

### 2. New Feature Flow
```
Feature implemented
→ Claude writes Playwright test for happy path
→ Runs: npx playwright test
→ Pass → done
```

### 3. Quick Smoke Check (no full test needed)
```
npx playwright test --grep "smoke"
```

## Test File Location

Place tests in `tests/` or `e2e/` at project root. Name: `[feature].spec.ts`.

## Minimal Test Template

```typescript
import { test, expect } from '@playwright/test';

test('form submits correctly', async ({ page }) => {
  await page.goto('http://localhost:3000');
  await page.fill('[name="email"]', 'test@example.com');
  await page.click('button[type="submit"]');
  await expect(page.locator('.success-message')).toBeVisible();
});
```

## Run Commands

```bash
npx playwright test                    # all tests
npx playwright test tests/login.spec.ts  # single file
npx playwright test --headed           # show browser (debug)
npx playwright test --reporter=line    # compact output
```

## Retry Loop on Failure

Khi test fail:
1. Đọc error message → xác định root cause
2. Fix code → chạy lại test ngay (không cần ScheduleWakeup — Playwright nhanh)
3. Nếu fail do timing/flaky → `ScheduleWakeup(60s)` rồi retry (tránh false negative)
4. Sau 3 lần fail liên tiếp → spawn subagent với `--headed` để xem browser (subagent nhận screenshot, trả text summary)
5. Nếu vẫn fail → escalate lên Claude direct fix với context từ subagent

**Không loop vô hạn:** max 3 retries. Sau đó report failure rõ ràng, không im lặng.

## Token-Efficient Output

Playwright returns text output — always use `--reporter=line` or `--reporter=dot` to minimize token usage. Avoid `--reporter=html` (generates files, not useful for Claude).

## When NOT to Use Playwright

- API-only projects (no browser UI)
- Simple CSS/styling changes (visual regression needs screenshots → expensive)
- One-time investigation (use DevTools)
- No dev server running (tests need live URL)

## Conflict Check — Current Workflow

Playwright integrates after Claude's code edit step. No conflict with existing hooks or Codex flow. In code-project.md: Playwright test = final verification step before marking task done.
