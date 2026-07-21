# Ôn thi vấn đáp giữa kỳ — Kiến trúc Phần mềm

> Đề gốc: https://nhbien.github.io/software-architecture-midterm-exam/ (GV: Ngô Huy Biên, 11/07/2026)

Hệ thống dùng xuyên suốt cho cả 3 phần: **Online Boutique (Google microservices-demo)** — đã có sẵn tại `Exercises/microservices-demo`. Một hệ thống, trả lời được cả 3 câu → demo mạch lạc, đỡ phải chuẩn bị nhiều repo.

## Đề bài (nguyên văn tóm tắt)

1. **Quality Attributes**: Demo + giải thích **Scalability** (chạy k6/locust/JMeter trên một open source tự chọn, giải thích kết quả) và **Security** (dùng công cụ quét online hoặc Claude Code/Codex/Copilot audit một open source, giải thích kết quả).
2. **Architecture Representation**: Tái tạo + giải thích kiến trúc (open source tự chọn). Chọn UML + Views, hoặc Boxes and Arrows + Views, hoặc Boxes and Arrows + C4. Luôn kèm **giải thích bằng chữ**. Tối thiểu: **4+1 Views + Database Schema** (có thể thêm Security View, Concurrency View tùy Quality Attributes được quan tâm). Lưu ý của thầy: Package/Component/Deployment/Artifact là 4 **UML model**, không đồng nghĩa 4 **view** — view thể hiện một mối quan tâm (concern), UML model chỉ là sơ đồ theo ký hiệu UML.
3. **Microservices + DevOps hiện đại**: Demo + giải thích kiến trúc Microservices với Docker, Kubernetes, Istio, Prometheus, Grafana (hoặc công cụ tương đương).

## Bộ tài liệu trong thư mục này

| Thư mục | Nội dung | Trả lời câu |
|---|---|---|
| **`00-EXAM-DAY.md`** | 🎯 **Playbook ngày thi** — dựng môi trường, demo nhanh 3 phần, xử lý sự cố | Đọc đầu tiên |
| **`check.sh`** | Kiểm tra sẵn sàng 1 lệnh: `bash Midterm/check.sh` → "SẴN SÀNG DEMO" | — |
| `01-scalability/` | Script k6 + cách chạy + cách **giải thích kết quả** | 1a |
| `02-security/` | Báo cáo audit bằng AI (Claude) trên Online Boutique, có file:line | 1b |
| `03-architecture/` | 4+1 Views + Database Schema (Mermaid) + giải thích từng thành phần | 2 |
| `04-demo-runbook/` | Kịch bản demo từng lệnh: minikube → Istio → deploy → Prometheus/Grafana/Kiali → k6 | 3 (và 1a) |
| `05-theory/` | Cheat sheet trả lời vấn đáp (QA, views, styles, microservices, service mesh) | Tất cả |
| `RESULTS.md` | **Kết quả chạy thử THẬT** toàn pipeline + số liệu k6 + sự cố & cách khắc phục | Bằng chứng |

> ✅ **Toàn bộ pipeline đã được chạy thử thành công trên máy này (2026-07-22).** Xem `RESULTS.md` để biết số liệu thực (k6: 39.6 req/s, p95 272ms, 0% lỗi) và 5 sự cố thực tế đã gặp + cách xử lý (OOMKilled cartservice, no healthy upstream, mTLS propagation, context conflict...).

## Checklist trước ngày thi

- [ ] Đọc `05-theory/CHEATSHEET.md` — nắm chắc định nghĩa để trả lời miệng.
- [ ] Chạy thử **toàn bộ** runbook `04-demo-runbook/RUNBOOK.md` ít nhất 1 lần (lần đầu tải image mất ~10–15 phút, đừng để đến giờ thi mới chạy).
- [ ] Chạy k6, chụp/lưu kết quả, tập giải thích p95 – throughput – error rate theo `01-scalability/SCALABILITY.md`.
- [ ] Đọc kỹ `02-security/SECURITY-AUDIT.md`, mở được đúng file:line khi thầy hỏi "chỉ chỗ lỗi trong code".
- [ ] Mở `03-architecture/ARCHITECTURE.md` trong VS Code (preview Mermaid) hoặc render sẵn ra ảnh.
- [ ] Trước giờ thi: bật Docker Desktop, `minikube start`, deploy sẵn hệ thống (pods cần vài phút để Running).

## Công cụ trên máy này (đã kiểm tra)

- Có sẵn: `docker`, `kubectl`, `istioctl`, `k6`, `jmeter`, `minikube`, `helm` (minikube + helm vừa cài qua brew).
- Nhớ **bật Docker Desktop** trước khi `minikube start` (daemon đang tắt lúc kiểm tra).
