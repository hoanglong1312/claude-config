# CLAUDE.md — Code Project

## Phân Công Vai Trò AI

### Claude = Planning, Analysis, Review
- Brainstorming, writing-plans, code review, git operations
- KHÔNG tự viết implementation code khi có Codex

### Codex = Implementation
- Thực thi coding tasks từ plan
- Có Superpowers cài sẵn → tự follow TDD

## Quy Trình Execution

### Sau writing-plans xong
- Dispatch từng task sang Codex qua MCP: `mcp__codex__codex`
- KHÔNG dùng subagent-driven-development bằng Claude

### Fallback nếu Codex không phản hồi hoặc lỗi
- Dùng Claude subagent-driven-development thay thế
- Ghi chú lý do fallback

## Quy Tắc Code
- Viết test trước khi implement (TDD)
- Commit sau mỗi task hoàn thành
- Không thêm feature ngoài scope đã plan

## Thông Tin Project
- Tên: [tên project]
- Git repo: [link]
- Tech stack: [danh sách]
- Mục tiêu: [mô tả ngắn]
