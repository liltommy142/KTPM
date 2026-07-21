# Phần 1a — Demo Scalability bằng k6 trên Online Boutique

> ✅ **Đã chạy thật** trên máy này — số liệu và bài học đầy đủ ở `../RESULTS.md`.
> Tóm tắt: baseline 1 replica đạt **39.6 req/s, p95 272ms, 0% lỗi**. Thí nghiệm scale-out
> lên 3 replica lại cho p95 *tệ hơn* — đọc RESULTS.md để biết vì sao (port-forward không
> load-balance + node minikube bị tranh chấp tài nguyên). Đây là điểm giải thích ăn điểm.

## ⚠️ 2 điều kiện BẮT BUỘC trước khi chạy k6 (rút ra từ lần chạy thật)

1. **Chờ mọi pod `2/2`** — chạy sớm sẽ dính lỗi `no healthy upstream` (59% fail ở lần thử đầu).
   ```sh
   until [ "$(kubectl get pods --no-headers | grep -c '2/2')" -ge 12 ]; do sleep 5; done
   ```
2. **Nâng RAM cartservice** để tránh OOMKilled dưới tải:
   ```sh
   kubectl set resources deployment cartservice -c=server --limits=memory=256Mi --requests=memory=128Mi
   ```

## Cách chạy

```sh
# 1. Hệ thống đã deploy trên minikube (xem 04-demo-runbook/RUNBOOK.md)
kubectl port-forward deployment/frontend 8080:8080

# 2. Terminal khác:
cd Midterm/01-scalability
k6 run -e BASE_URL=http://localhost:8080 k6-test.js

# Xuất kết quả ra file để nộp/chiếu:
k6 run -e BASE_URL=http://localhost:8080 --summary-export=result.json k6-test.js
```

Script mô phỏng **phiên mua hàng thực**: trang chủ → xem sản phẩm (ID thật) → thêm giỏ → xem giỏ; tải tăng dần 10 → 50 → 100 VU (virtual users) trong ~3 phút.

## Cách GIẢI THÍCH kết quả (phần thầy chấm)

Ví dụ output k6 và ý nghĩa từng chỉ số:

| Chỉ số | Ý nghĩa | Cách diễn giải khi vấn đáp |
|---|---|---|
| `http_reqs` (rate) | Throughput — số request/giây hệ thống xử lý được | "Ở 50 VU hệ thống đạt X req/s; tăng lên 100 VU throughput tăng/chững lại → cho biết điểm bão hòa (saturation point)." |
| `http_req_duration avg / p(90) / p(95)` | Latency — thời gian phản hồi | "p95 quan trọng hơn avg vì avg che khuất tail latency. SLO đặt p95 < 500ms." |
| `http_req_failed` | Tỉ lệ lỗi | "Khi vượt capacity, lỗi tăng (timeout, 5xx) — hệ thống cần cơ chế scale hoặc backpressure." |
| `vus` / `vus_max` | Số user ảo đồng thời | Trục X của bài phân tích: latency/throughput thay đổi thế nào theo tải. |
| `checks` | % request đúng nội dung mong đợi | Phân biệt "trả lời nhanh nhưng sai" với "đúng". |

**Câu chuyện cần kể:** khi tải tăng, throughput tăng tuyến tính đến một ngưỡng rồi chững, còn p95 latency tăng vọt → đó là dấu hiệu **bottleneck**. Với Online Boutique chạy minikube, bottleneck thường là CPU limit của `frontend` (mỗi request `/` gọi fan-out ~5 service gRPC: currency, cart, productcatalog, ad, shipping) hoặc CPU của minikube VM.

## Demo scalability THẬT (điểm cộng lớn)

Scalability = khả năng tăng capacity khi thêm tài nguyên. Demo ngay tại chỗ:

```sh
# Đo baseline với 1 replica frontend, chạy k6, ghi lại p95 + req/s
kubectl scale deployment frontend --replicas=3
kubectl get pods -l app=frontend   # chờ 3 pod Running
# Chạy lại k6 cùng cấu hình → so sánh: p95 giảm, throughput tăng
```

Giải thích: đây là **horizontal scaling (scale out)** — kiến trúc microservices + stateless frontend (session chỉ là cookie, giỏ hàng nằm ở Redis) cho phép nhân bản service mà không cần sticky session. Đối lập với **vertical scaling (scale up)** = tăng CPU/RAM cho 1 instance. Có thể nhắc thêm HPA:

```sh
kubectl autoscale deployment frontend --cpu-percent=70 --min=1 --max=5
kubectl get hpa -w   # xem HPA tự tăng replica khi k6 dồn tải
```

## Ghi chú phụ

- Repo đã kèm sẵn **loadgenerator dùng Locust** (`src/loadgenerator/locustfile.py`) — nói được ý này: "hệ thống tự có load test nội bộ bằng Locust, em dùng k6 bên ngoài để đo độc lập".
- Nếu thầy hỏi JMeter: cùng mục đích, JMeter GUI + XML plan, k6 script JS + CLI, hợp CI/CD hơn.
- Quan sát song song bằng Grafana (phần 3): dashboard Istio cho thấy RPS, p50/p90/p99 per-service trong lúc k6 chạy → chỉ ra service nào chậm nhất.
