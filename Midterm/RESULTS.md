---
tags: [ktpm, evidence]
---

# Kết quả chạy thử thực tế (dry-run toàn pipeline)

> Chạy ngày 2026-07-22 trên máy này (macOS arm64, Docker Desktop + minikube). Đây là bằng chứng "đã chạy được thật", kèm số liệu và các sự cố gặp phải + cách khắc phục.

## Môi trường thực tế đã dựng

| Thành phần | Phiên bản / cấu hình | Trạng thái |
|---|---|---|
| Docker Desktop | 29.6.1 | ✅ chạy |
| minikube | v1.38.1, K8s **v1.35.1**, driver docker, 4 CPU / 6 GiB / 32 GB | ✅ Running |
| Istio | v1.30.2, profile `demo` | ✅ istiod + ingress/egress gateway Running |
| Online Boutique | 12 pod, mỗi pod **2/2** (app + Envoy sidecar) | ✅ Running |
| Addons | Prometheus, Grafana, Kiali | ✅ Running |

**Bằng chứng sidecar Istio:** mọi pod hiển thị `2/2` (container app + `istio-proxy`). Đó là dấu hiệu injection thành công.

## Phần 1a — Scalability (k6): SỐ LIỆU THẬT

### Baseline — 1 replica frontend, hệ thống khỏe mạnh
Ramp 10 → 50 → 80 VU trong ~80s:

| Chỉ số | Giá trị |
|---|---|
| Throughput | **39.6 req/s** |
| p90 latency | 166.3 ms |
| **p95 latency** | **272.7 ms** (đạt SLO p95 < 500ms ✅) |
| Error rate | **0.00%** ✅ |
| Checks pass | 100% (2628/2628) |

→ File `01-scalability/result.json`.

### Thí nghiệm scale-out — 3 replica frontend
| Chỉ số | 1 replica | 3 replica |
|---|---|---|
| Throughput | 39.6 req/s | 35.1 req/s |
| p95 | 272 ms | **1.1 s (tệ hơn!)** |
| Error | 0% | 0% |

**Kết quả NGƯỢC trực giác — và đây là điểm giải thích ăn điểm:**
1. **`kubectl port-forward` chỉ trỏ tới MỘT pod**, không load-balance. Thêm replica không tăng throughput khi test qua port-forward → phải test qua **Service (NodePort / `minikube service` / LoadBalancer)** mới thấy hiệu quả scale-out.
2. **Node minikube nhỏ (4 CPU/6GB) bị tranh chấp tài nguyên**: 3 frontend + 3 Envoy sidecar giành CPU/RAM với 9 service khác → latency tăng. Scale-out chỉ giúp khi node còn dư tài nguyên (hoặc chạy nhiều node).

→ Bài học vấn đáp: *scalability không tự động = "thêm replica là nhanh hơn"*; nó phụ thuộc (a) traffic có thực sự được phân phối không, (b) tầng dưới có phải bottleneck không. Ở đây bottleneck là **node**, không phải số replica frontend.

→ Số liệu 3 replica ở `01-scalability/result-3replicas.json`.

## Phần 1b — Security: LỖI THẬT phát hiện khi chạy

Ngoài 5 lỗi tĩnh trong `02-security/SECURITY-AUDIT.md`, chạy thật lộ thêm bằng chứng runtime:

- **gRPC nội bộ không mã hóa được xác nhận:** trước khi bật mTLS, log frontend cho thấy lời gọi gRPC tới cartservice đi qua Envoy dạng thường. Sau khi áp **PeerAuthentication STRICT** (`04-demo-runbook`), traffic service-to-service được mã hóa mà **không sửa một dòng code nào** — frontend vẫn trả HTTP 200.
- **Xác nhận mesh có mTLS:** `kubectl get peerauthentication -A` → `istio-system/default  STRICT`.

## Sự cố gặp phải & cách khắc phục (QUAN TRỌNG — dễ bị hỏi/dễ vấp khi demo thật)

### 1. `no healthy upstream` (HTTP 500) khi mới deploy
- **Triệu chứng:** k6 lần đầu 59% lỗi, log frontend: `could not retrieve cart: rpc error: code = Unavailable desc = no healthy upstream`.
- **Nguyên nhân:** chạy k6 khi vài service (email, cart) còn `1/2 PodInitializing` → Envoy chưa có endpoint khỏe mạnh.
- **Khắc phục:** **chờ TẤT CẢ pod `2/2` rồi mới chạy k6.** Lệnh chờ:
  ```sh
  until [ "$(kubectl get pods --no-headers | grep -c '2/2')" -ge 12 ]; do sleep 5; done
  ```
- Sau khi chờ đủ: k6 chạy lại → **0% lỗi**.

### 2. cartservice bị **OOMKilled** dưới tải (bug thật của manifest)
- **Triệu chứng:** dưới tải, cartservice `RESTARTS` tăng dần, `lastState.terminated.reason = OOMKilled`, gây 500 hàng loạt (fail nhanh ~22ms).
- **Nguyên nhân:** `cartservice` (.NET) có `limits.memory: 128Mi` trong `kubernetes-manifests/cartservice.yaml`. Cộng thêm Envoy sidecar + tải cao → vượt 128Mi → bị kill.
- **Khắc phục đã áp dụng:**
  ```sh
  kubectl set resources deployment cartservice -c=server --limits=memory=256Mi --requests=memory=128Mi
  ```
  Sau đó cartservice `0 restart`, hệ thống ổn định. → Nói được: đây là ví dụ về **quality attribute Availability/Reliability** và tầm quan trọng của đặt resource limit đúng.

### 3. Bật mTLS STRICT gây 500 thoáng qua (~15–30s)
- **Triệu chứng:** ngay sau `kubectl apply` PeerAuthentication STRICT, có vài giây 500 rồi tự hết.
- **Nguyên nhân:** cấu hình mTLS cần thời gian propagate xuống tất cả Envoy sidecar; trong cửa sổ đó client/server lệch chế độ.
- **Khắc phục:** chờ ~30s cho ổn định; không hoảng. Nếu 500 kéo dài → kiểm tra có pod nào **thiếu sidecar** (STRICT sẽ chặn traffic plaintext từ pod không nằm trong mesh).

### 4. minikube xung đột context với Docker Desktop Kubernetes
- **Triệu chứng:** `kubectl` trỏ nhầm sang cluster `docker-desktop`.
- **Khắc phục:** `kubectl config use-context minikube` (và `minikube update-context`).

### 5. Addon YAML phải khớp phiên bản Istio
- Dùng nhánh `release-1.30` cho khớp `istioctl 1.30.2`:
  `https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons/{prometheus,grafana,kiali}.yaml`.

## Phần 3 — Observability: XÁC NHẬN THẬT
- Prometheus đang scrape metric Istio: query `count(istio_requests_total)` = **77 chuỗi** → dashboard Grafana/Kiali có dữ liệu.
- Truy vấn hữu ích khi demo (port-forward `svc/prometheus 9090`):
  ```promql
  count(istio_requests_total)
  sum by (destination_service_name) (istio_requests_total)
  histogram_quantile(0.95, sum(rate(istio_request_duration_milliseconds_bucket[1m])) by (le, destination_service_name))
  ```

## Demo BỔ SUNG đã chạy thật (đợt 2)

### A. HPA — Horizontal Pod Autoscaler (Scalability, phần 1a)
- Bật metrics-server: `minikube addons enable metrics-server`.
- Tạo HPA: `kubectl autoscale deployment frontend --cpu=20% --min=1 --max=5`.
- Dồn tải bằng k6 → CPU frontend vượt ngưỡng (35% > 20%) → **HPA tự tăng replica lên tối đa (desired=5)**, pod mới tự Running. Khi ngừng tải → HPA tự scale-down về 1.
- ⚠️ Lần đầu đặt ngưỡng 50% KHÔNG scale được vì `port-forward` chỉ dồn tải 1 pod (CPU chỉ ~24%). Hạ ngưỡng xuống 20% (dưới mức tải thực) mới thấy HPA phản ứng → lại là bài học **port-forward không đủ để test autoscaling**; muốn nghiêm túc phải dồn tải qua Service/NodePort.
- → Bằng chứng scalability **tự động** (khác với `kubectl scale` thủ công).

### B. Istio Traffic Management — Fault Injection (phần 3, service mesh)
Demo thật khả năng service mesh chèn lỗi mà **không sửa code** (dùng để test resilience):
- **Delay fault:** VirtualService inject delay 5s/100% vào `productcatalogservice` → thời gian tải `/product/` nhảy từ **0.018s lên 35s**. Bonus: 35s (≈7×5s) lộ ra pattern **fan-out gRPC** — frontend gọi productcatalog nhiều lần khi render (chi tiết + đề xuất).
- **Abort fault:** inject 503 cho 50% request tới `currencyservice` → mô phỏng service chập chờn để kiểm thử retry/circuit-breaking.
- Gỡ VirtualService → hệ thống hồi phục ngay (`/product/` về 0.027s). File YAML mẫu ở `04-demo-runbook/RUNBOOK.md` mục 7.

### C. Security — Trivy (công cụ quét, bổ sung cho audit AI ở phần 1b)
- **Trivy image scan** `redis:alpine`: **0 lỗ hổng HIGH/CRITICAL** (alpine base sạch).
- **Trivy config scan** `kubernetes-manifests/`: **25 MEDIUM + 55 LOW** misconfig. Đáng nêu:
  - `KSV-0104` (MEDIUM): Seccomp policy chưa bật.
  - `KSV-0013` (MEDIUM): dùng image tag `:latest`.
  - `KSV-0011/0018`: một số workload thiếu CPU/memory limit → chính là gốc rễ vụ **cartservice OOMKilled** ở trên.
  - `KSV-0110`: workload chạy ở `default` namespace.
- → Nói khi vấn đáp: AI audit tìm lỗi logic/luồng (gRPC plaintext, cookie, log thẻ...), còn Trivy tìm misconfig hạ tầng/CVE — **hai lớp bổ trợ nhau**.

### D. Kiến trúc — render sơ đồ Mermaid (phần 2)
- Validate **6/6 sơ đồ Mermaid** trong `03-architecture/ARCHITECTURE.md` bằng mermaid-cli → parse OK.
- Ảnh PNG đã render sẵn ở **`03-architecture/diagrams/`** (logical, process, development, deployment, scenario, database-schema) — chiếu trực tiếp khi thi, không cần preview.

## Thời gian tham khảo (để canh giờ demo)
- `minikube start` lần đầu (kéo base image 483MB): **~5–7 phút**.
- `istioctl install`: ~1–2 phút.
- Deploy app + chờ 12 pod `2/2` (kéo ~11 image): **~4–6 phút**.
- k6 một lần chạy (cấu hình rút gọn ~80s) hoặc bản đầy đủ ~3 phút.
- → **Tổng cold-start ~15 phút.** Phải deploy sẵn TRƯỚC giờ vấn đáp.

## Lệnh dọn dẹp
```sh
kubectl delete -f ./release/kubernetes-manifests.yaml
istioctl uninstall --purge -y
minikube stop     # giữ cluster để lần sau nhanh; hoặc minikube delete để xóa hẳn
```
