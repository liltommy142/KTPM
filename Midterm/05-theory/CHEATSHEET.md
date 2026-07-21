---
tags: [ktpm, ktpm/theory]
---

# Cheat Sheet Vấn đáp — Kiến trúc Phần mềm

Trả lời ngắn gọn, đúng thuật ngữ. Dựa trên slide môn học (`Slides/01–05`) + đề thi.

## A. Software Architecture là gì?
- Tập các **quyết định thiết kế quan trọng, khó thay đổi**: cấu trúc (thành phần + quan hệ) + thuộc tính hiển lộ ra ngoài của các thành phần.
- Cầu nối giữa **yêu cầu** và **mã nguồn**. Phục vụ giao tiếp giữa các stakeholder, phân tích sớm (nhất là quality attributes), tái sử dụng.
- Architecture ≠ Design chi tiết: architecture là quyết định mức cao, ảnh hưởng toàn hệ thống; design là bên trong từng module.

## B. Quality Attributes (QA) — đề mục 1
QA = thuộc tính chất lượng, đo bằng **scenario** (stimulus → environment → response → measure).

| QA | Định nghĩa | Chiến thuật (tactics) |
|---|---|---|
| **Scalability** | Giữ hiệu năng khi tải/khối lượng tăng | Scale out (horizontal), scale up (vertical), stateless, load balancing, caching, HPA |
| **Performance** | Đáp ứng đúng thời gian (latency, throughput) | Tăng tài nguyên, giảm nhu cầu, quản lý tài nguyên (queue, concurrency) |
| **Availability** | Sẵn sàng, ít downtime | Redundancy, health check, retry, circuit breaker, self-healing (k8s) |
| **Security** | Bảo mật: C-I-A (Confidentiality, Integrity, Availability) | AuthN/AuthZ, mã hóa (TLS/mTLS), least privilege, audit log |
| **Modifiability** | Dễ sửa/mở rộng | Tách concern, đóng gói, low coupling, high cohesion |
| **Testability** | Dễ kiểm thử | Interface rõ, DI, contract (proto) |
| **Usability** | Dễ dùng | — |

- **Trade-off**: QA thường xung đột (bảo mật ↔ hiệu năng; scalability ↔ consistency — xem CAP). Kiến trúc là chọn cân bằng.
- **QA khác đã demo SẴN** (đề: "giải thích không giới hạn ở 2 QA"): nói được ngay mà không cần chạy thêm —
  - **Availability/Reliability:** K8s **self-healing** (pod chết tự restart — đã thấy cartservice OOMKilled tự phục hồi), replica + health check.
  - **Performance:** k6 đo p95 latency & throughput; `Money{units,nanos}` tránh sai số float.
  - **Scalability:** HPA tự tăng replica (đã demo).
  - **Modifiability:** polyglot qua `demo.proto` contract, mỗi service deploy độc lập.
  - **Security:** mTLS STRICT, pod security context (đã demo).
- **Cách demo QA (đề bài):** Scalability = k6/locust/JMeter đo latency/throughput theo tải; Security = audit code (Claude Code) hoặc scan (ZAP/Snyk/Trivy).

## C. Documenting Architecture — Views (đề mục 2)
- **View** = biểu diễn hệ thống từ góc nhìn của **một mối quan tâm (concern)** của một nhóm stakeholder. (Chuẩn ISO/IEC 42010: stakeholder → concern → viewpoint → view.)
- **View ≠ UML model.** UML model (Package/Component/Deployment/Artifact) là *sơ đồ theo ký hiệu UML*; nhiều model có thể phục vụ một view, hoặc một model xuất hiện ở nhiều view.
- **4+1 View (Kruchten):**
  1. **Logical** — chức năng, phân rã domain (dev, người dùng cuối).
  2. **Process** — runtime, đồng thời, hiệu năng (integrator).
  3. **Development (Implementation)** — tổ chức module/mã nguồn (lập trình viên).
  4. **Physical (Deployment)** — ánh xạ lên phần cứng/hạ tầng (vận hành).
  5. **+1 Scenario (Use case)** — liên kết & kiểm chứng 4 view kia.
- **Tối thiểu theo thầy:** 4+1 Views + **Database Schema**. Thêm **Security View / Concurrency View** nếu QA đó được quan tâm. → Đã chuẩn bị **cả 8 view** (4+1 + DB + Security + Concurrency) trong `03-architecture/` vì QA chọn là Scalability + Security.
- 3 lựa chọn biểu diễn: **UML + Views**, **Boxes & Arrows + Views**, **Boxes & Arrows + C4 Models**.
- **C4 model** (Simon Brown): 4 mức thu phóng — **Context → Container → Component → Code**. "Container" ở C4 = ứng dụng/DB chạy được (không phải Docker container).
- Nguyên tắc: **sơ đồ luôn kèm giải thích bằng chữ** (nếu không, người đọc hiểu sai ký hiệu).

## D. Architectural Styles (Slide 04)
- **Layered** (n-tier): tách presentation/business/data. Dễ hiểu, dễ thay tầng; nhược: xuyên tầng, hiệu năng.
- **Client–Server**.
- **Microservices**: nhiều service nhỏ, độc lập triển khai, own-data, giao tiếp qua API/RPC/message. Ưu: scale/độc lập/polyglot; nhược: phức tạp vận hành, distributed system (network, consistency).
- **Event-Driven / Pub-Sub / Message Bus**: lỏng lẻo, bất đồng bộ, dễ mở rộng; khó debug/trace.
- **Microkernel (Plug-in)**, **Pipe-and-Filter**, **Broker**, **SOA**, **Monolith**.
- **Monolith vs Microservices:** monolith 1 codebase/1 DB, deploy cả khối; microservices tách nhỏ, decentralized data. Chọn theo quy mô đội/nhu cầu scale, không phải cứ micro là tốt.

## E. Microservices + Service Mesh (đề mục 3)
- **Container (Docker)**: đóng gói app + dependency, chạy nhất quán mọi nơi.
- **Orchestration (Kubernetes)**: quản vòng đời pod — scheduling, scaling (HPA), self-healing, rolling update, service discovery, config/secret.
  - Khái niệm k8s: **Pod** (đơn vị chạy nhỏ nhất), **Deployment** (quản replica + rollout), **Service** (địa chỉ ổn định + LB), **Namespace**, **ConfigMap/Secret**.
- **Service Mesh (Istio)**: lớp hạ tầng xử lý giao tiếp service-to-service qua **sidecar (Envoy)** — tách **cross-cutting concern** khỏi code:
  - **Traffic management**: routing, canary, retry, timeout, circuit breaking, fault injection.
  - **Security**: **mTLS** tự động (mã hóa + xác thực 2 chiều), AuthorizationPolicy.
  - **Observability**: metric, trace, log tự động → Prometheus/Grafana/Kiali/Jaeger.
- **Prometheus**: pull-based, lưu time-series, PromQL. **Grafana**: dashboard hóa. **Kiali**: đồ thị topology + health.
- Vì sao mesh mạnh: thêm mTLS/observability/traffic-policy **mà không sửa code** service — đúng nguyên tắc separation of concerns.

## F. Câu hỏi bẫy thường gặp
- *"4 UML model có phải 4 view không?"* → Không. Model là sơ đồ ký hiệu UML; view là mối quan tâm. Một view có thể gồm nhiều model.
- *"Bao nhiêu view là đủ?"* → Không cố định. Đủ khi lập trình viên bắt đầu code được và ban quản lý không yêu cầu thêm. Thường tối thiểu 4+1 + DB schema.
- *"Microservices luôn tốt hơn monolith?"* → Không. Đánh đổi độ phức tạp vận hành/latency mạng lấy khả năng scale & độc lập. Đội nhỏ/hệ đơn giản thì monolith hợp lý hơn.
- *"Sidecar là gì?"* → Container phụ chạy cạnh app trong cùng pod (Envoy), chặn toàn bộ traffic vào/ra để áp policy.
- *"mTLS khác TLS?"* → TLS xác thực 1 chiều (client tin server); mTLS xác thực 2 chiều (cả hai trình cert) — dùng cho tin cậy zero-trust nội bộ.
- *"CAP theorem?"* → Hệ phân tán chỉ chọn 2/3 trong Consistency–Availability–Partition tolerance; vì mạng luôn có partition nên thực chất chọn giữa C và A.
- *"Coupling & Cohesion?"* → Mục tiêu: **low coupling** (ít phụ thuộc chéo), **high cohesion** (mỗi module một trách nhiệm rõ). Microservices là biểu hiện cực đoan của low coupling.

## G. Mapping đề → tài liệu đã chuẩn bị
- Mục 1 Scalability → `01-scalability/` (k6 + giải thích + demo scale out).
- Mục 1 Security → `02-security/` (audit AI, 5 lỗi có file:line, nối sang mTLS).
- Mục 2 Architecture → `03-architecture/` (4+1 views + DB schema, Mermaid).
- Mục 3 Microservices/DevOps → `04-demo-runbook/` (Docker/K8s/Istio/Prometheus/Grafana từng lệnh).
