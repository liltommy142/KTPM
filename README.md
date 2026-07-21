# KTPM — Kiến trúc & Kỹ thuật Phần mềm

Repo học tập môn Kiến trúc Phần mềm.

## Cấu trúc

```
KTPM/
├── Slides/        # Slide bài giảng (Intro, Quality Attributes, Documenting,
│                  #   Architectural Styles, Design Methods)
├── Exercises/     # Phân tích kiến trúc microservices (ArchLens) trên
│   ├── ARCHITECTURE.md, MODULES.md, CYCLES.md   # tài liệu ArchLens sinh ra
│   └── microservices-demo/   # Online Boutique — clone của Google
├── Midterm/       # Chuẩn bị vấn đáp giữa kỳ (xem Midterm/README.md)
│   ├── 01-scalability/   # k6 load test + cách giải thích
│   ├── 02-security/      # audit bảo mật (AI-assisted) có file:line
│   ├── 03-architecture/  # 4+1 Views + Database Schema (Mermaid)
│   ├── 04-demo-runbook/  # Docker/K8s/Istio/Prometheus/Grafana từng lệnh
│   ├── 05-theory/        # cheat sheet lý thuyết
│   └── RESULTS.md         # kết quả chạy thử thật + sự cố & cách khắc phục
└── README.md
```

## Bắt đầu từ đâu

- Ôn giữa kỳ: mở **`Midterm/README.md`** — có checklist và toàn bộ tài liệu theo 3 phần đề thi.
- Đề gốc: https://nhbien.github.io/software-architecture-midterm-exam/

## Ghi chú

- `Exercises/microservices-demo` là bản clone của
  [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo)
  dùng làm hệ thống demo cho phần Microservices.
