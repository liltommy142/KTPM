---
tags: [ktpm, ktpm/security, quality-attributes]
---

# Phần 1b — Security Audit Online Boutique (AI-assisted, Claude Code)

Đây là kết quả audit bằng **Claude Code** đọc trực tiếp mã nguồn `Exercises/microservices-demo`. Mỗi phát hiện có **file:line thật** để mở ra chỉ cho thầy. Đây là demo app học tập của Google — có chủ đích để insecure ở vài chỗ; nhiệm vụ vấn đáp là **nhận ra và giải thích**, không phải chê.

## Phương pháp

- Công cụ: Claude Code (AI code audit) — đọc source, tìm anti-pattern bảo mật.
- Bổ sung được (nói khi vấn đáp): scan online như **Snyk**, **Trivy**, **OWASP ZAP**. Cùng phân loại theo **OWASP Top 10**.

## Kết quả Trivy đã chạy thật (bổ sung cho audit AI)

- **`trivy image redis:alpine`** → **0 lỗ hổng HIGH/CRITICAL** (alpine base sạch).
- **`trivy config kubernetes-manifests/`** → **25 MEDIUM + 55 LOW** misconfig. Nổi bật:
  - `KSV-0104` (MEDIUM): Seccomp policy chưa bật.
  - `KSV-0013` (MEDIUM): dùng image tag `:latest` (không cố định version).
  - `KSV-0011/0018` (LOW): vài workload thiếu CPU/memory limit → **chính là gốc rễ vụ cartservice bị OOMKilled** khi chạy tải (xem `../RESULTS.md`).
  - `KSV-0110` (LOW): workload chạy ở `default` namespace.
- **Ý chính khi vấn đáp:** AI audit bắt lỗi logic/luồng (gRPC plaintext, cookie thiếu cờ, log thẻ...), Trivy bắt misconfig hạ tầng/CVE → **hai lớp bổ trợ nhau**, không thay thế.

## Các phát hiện chính

### 1. gRPC nội bộ không mã hóa (plaintext) — OWASP A02 Cryptographic Failures
- **File:** `src/frontend/main.go:230`, `src/checkoutservice/main.go:215`
- **Bằng chứng:** `grpc.WithTransportCredentials(insecure.NewCredentials())`
- **Vấn đề:** mọi giao tiếp service-to-service (kể cả paymentservice, checkoutservice) đi qua kênh không TLS. Ai bắt được traffic trong cluster đọc được toàn bộ.
- **Khắc phục:** bật **mTLS**. Đây chính là lý do dùng **Istio service mesh** (phần 3): `PeerAuthentication mode: STRICT` cho mTLS tự động mà không sửa code → liên kết đẹp giữa câu bảo mật và câu microservices.

### 2. Session cookie thiếu cờ bảo mật — OWASP A05 Security Misconfiguration
- **File:** `src/frontend/middleware.go:97-101`
- **Bằng chứng:** `http.SetCookie` chỉ set `Name/Value/MaxAge`, **không** có `HttpOnly`, `Secure`, `SameSite`.
- **Vấn đề:** cookie session đọc được bằng JavaScript → nguy cơ đánh cắp session qua XSS; gửi qua HTTP thường; dễ CSRF.
- **Khắc phục:** thêm `HttpOnly: true`, `Secure: true`, `SameSite: http.SameSiteLaxMode`.

### 3. Log lộ dữ liệu thẻ tín dụng — OWASP A09 Logging Failures / PCI-DSS
- **File:** `src/paymentservice/charge.js:81-82`
- **Bằng chứng:** `logger.info('Transaction processed: ${cardType} ending ${cardNumber.substr(-4)} ...')`
- **Vấn đề:** ghi loại thẻ + 4 số cuối + số tiền vào log. 4 số cuối là mức PCI cho phép, nhưng đây vẫn là bài học **không log thông tin thanh toán** — nhấn mạnh nếu ai đó sửa `substr(-4)` thành cả số thẻ thì thành rò rỉ nghiêm trọng.
- **Khắc phục:** không log PAN, mask toàn bộ, tách log audit riêng.

### 4. Redis (giỏ hàng) không đặt mật khẩu — OWASP A05 / A07
- **File:** `kubernetes-manifests/cartservice.yaml:118` (`image: redis:alpine`, chạy không `requirepass`)
- **Vấn đề:** bất kỳ pod nào trong cluster kết nối được Redis là đọc/sửa được toàn bộ giỏ hàng của mọi user. Không auth, không TLS.
- **Khắc phục:** đặt `requirepass`/ACL, dùng NetworkPolicy giới hạn chỉ `cartservice` gọi được Redis (repo có sẵn component `network-policies` trong kustomize).

### 5. Chế độ single shared session (nếu bật) — OWASP A01 Broken Access Control
- **File:** `src/frontend/middleware.go:90-93`
- **Bằng chứng:** khi `ENABLE_SINGLE_SHARED_SESSION=true`, mọi user dùng chung `sessionID = "12345678-..."`.
- **Vấn đề:** là cờ demo, nhưng nếu bật nhầm ở "production" thì mọi khách chung một giỏ hàng → mất cô lập dữ liệu người dùng. Bài học: cấu hình nguy hiểm phải tách khỏi mặc định.

## Điểm tốt về bảo mật (nên khen để cân bằng)

- **Pod Security Context chặt** — `kubernetes-manifests/frontend.yaml:33-46`:
  `runAsNonRoot: true`, `runAsUser: 1000`, `allowPrivilegeEscalation: false`,
  `capabilities.drop: [ALL]`, `readOnlyRootFilesystem: true`. Đây là chuẩn hardening tốt, chống container escape / privilege escalation.
- Payment validate thẻ (Luhn qua `simple-card-validator`), chặn thẻ hết hạn, chỉ nhận VISA/Mastercard — `src/paymentservice/charge.js:66-79`.

## Bảng tổng hợp (để chiếu)

| # | Lỗi | File:line | OWASP | Mức |
|---|---|---|---|---|
| 1 | gRPC plaintext (no mTLS) | frontend/main.go:230 | A02 | Cao |
| 2 | Cookie thiếu HttpOnly/Secure/SameSite | frontend/middleware.go:97 | A05 | Trung bình |
| 3 | Log 4 số cuối thẻ | paymentservice/charge.js:81 | A09 | Thấp–TB |
| 4 | Redis không mật khẩu | cartservice.yaml:118 | A05 | Cao (nội bộ) |
| 5 | Shared session flag | frontend/middleware.go:90 | A01 | Tùy cấu hình |

**Kết luận vấn đáp:** rủi ro lớn nhất là giao tiếp nội bộ không mã hóa (số 1, 4). Giải pháp kiến trúc — không sửa từng service — là đưa vào **Istio service mesh bật mTLS STRICT + AuthorizationPolicy**, đúng công cụ ở phần 3. Đây là cầu nối để chốt bài: security → service mesh.
