# /verify — Run All Tests

Chạy toàn bộ test suite và báo cáo kết quả.

## Steps

1. Compile/syntax check trước (adapt theo stack):
   - Python: `python -m py_compile <core files>`
   - Node/TS: `npm run build` hoặc `npx tsc --noEmit`
2. Chạy tests:
   - Python: `for f in test/check_*.py; do python "$f" && echo "PASS: $f" || echo "FAIL: $f"; done`
   - Node: `npm test`
3. Báo cáo: X pass, Y fail
4. Nếu có FAIL → show output, diagnose root cause
