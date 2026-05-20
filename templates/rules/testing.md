# Testing & Quality Gate Rules

## Quality Gate — Bắt Buộc Trước Khi Bàn Giao User

Sau mỗi lần Codex xong feature / fix, Claude main chạy đủ 2 bước:

### Bước 1: Static Audit (Codex tự làm)
Gọi Codex rà soát output của nó:
- Import có tồn tại không
- Props có match với data trả về không
- Form inputs có controlled (useState + onChange) không
- Không có console.error / warning bất thường

### Bước 2: E2E Test
Chạy test suite của project (xem project CLAUDE.md để biết lệnh cụ thể).

**Chỉ khi pass cả 2 → báo user test.**

> User chỉ test những gì không tự động được: visual/UX judgment, auth thật, edge case cảm tính.
