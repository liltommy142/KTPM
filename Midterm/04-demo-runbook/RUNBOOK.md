---
tags: [ktpm, ktpm/microservices, devops]
---

# Phần 3 — Runbook demo: Microservices + Docker + Kubernetes + Istio + Prometheus + Grafana

> ✅ **Toàn bộ runbook này ĐÃ được chạy thử thành công trên máy này** (2026-07-22). Xem số liệu & sự cố thực tế ở `../RESULTS.md`. Các cảnh báo ⚠️ bên dưới là bài học rút ra từ lần chạy thật.

Kịch bản chạy **từng lệnh** cho buổi vấn đáp. Chạy thử **trước ngày thi** (cold-start ~15 phút — đã đo). Mọi lệnh chạy từ:

```sh
cd /Users/liltommy/Desktop/Study/KTPM/Exercises/microservices-demo
```

## 0. Chuẩn bị (làm trước khi thi)

```sh
# Bật Docker Desktop (GUI). Kiểm tra daemon:
docker info | head -3

# Khởi động cluster local (cần >=4 CPU, 4GB RAM)
minikube start --cpus=4 --memory=6144 --disk-size=32g

# ⚠️ Nếu máy có Docker Desktop Kubernetes bật sẵn, kubectl dễ trỏ nhầm cluster.
#    Ép về đúng minikube:
kubectl config use-context minikube
minikube update-context
kubectl get nodes          # phải thấy node "minikube" Ready
```

## 1. Cài Istio + bật sidecar injection

```sh
# istioctl đã có sẵn (v1.30.2). Cài control plane profile demo:
istioctl install --set profile=demo -y

# Cho phép namespace default tự tiêm Envoy sidecar:
kubectl label namespace default istio-injection=enabled --overwrite
```

## 2. Deploy Online Boutique

```sh
# Cách nhanh nhất — dùng manifest release có sẵn (image dựng sẵn, không cần build):
kubectl apply -f ./release/kubernetes-manifests.yaml

# ⚠️ BÀI HỌC THẬT: cartservice mặc định chỉ có limit RAM 128Mi -> cộng sidecar Envoy
#    dễ bị OOMKilled dưới tải. Nâng trước khi test tải để tránh 500 hàng loạt:
kubectl set resources deployment cartservice -c=server \
  --limits=memory=256Mi --requests=memory=128Mi

# ⚠️ CHỜ TẤT CẢ pod 2/2 rồi mới chạy k6/mở web. Chạy sớm -> lỗi "no healthy upstream".
until [ "$(kubectl get pods --no-headers | grep -c '2/2')" -ge 12 ]; do sleep 5; done
kubectl get pods
```
Mỗi pod sẽ có **2/2 container** (app + istio-proxy) → bằng chứng sidecar đã tiêm.
(loadgenerator có thể báo `Init:Error` lúc đầu vì chờ frontend — nó tự retry, không sao.)

## 3. Cài addon quan sát: Prometheus, Grafana, Kiali

```sh
# Các addon đi kèm bản phát hành Istio (dùng nhánh khớp phiên bản 1.30):
BASE=https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons
kubectl apply -f $BASE/prometheus.yaml
kubectl apply -f $BASE/grafana.yaml
kubectl apply -f $BASE/kiali.yaml
kubectl apply -f $BASE/jaeger.yaml    # (tùy chọn: tracing)

kubectl -n istio-system get pods -w    # chờ Running
```

## 4. Truy cập ứng dụng

```sh
# Mở frontend qua port-forward:
kubectl port-forward deployment/frontend 8080:8080
# -> mở http://localhost:8080  (trang web bán hàng)
```
(Hoặc dùng Istio Gateway: `kubectl apply -f istio-manifests/` rồi `istioctl dashboard` — nhưng port-forward đơn giản nhất cho demo.)

## 5. Mở các dashboard quan sát (mỗi cái 1 terminal)

```sh
istioctl dashboard kiali       # topology real-time: service gọi nhau, RPS, health
istioctl dashboard grafana     # dashboard Istio: latency p50/p90/p99, throughput, error
istioctl dashboard prometheus  # truy vấn metric thô (PromQL)
```
Ví dụ PromQL để chiếu trên Prometheus:
```
istio_requests_total                                    # tổng request qua mesh
rate(istio_requests_total[1m])                          # RPS theo service
histogram_quantile(0.95, sum(rate(istio_request_duration_milliseconds_bucket[1m])) by (le, destination_service))
```

## 6. Demo Service Mesh — mTLS (nối với phần Security)

```sh
# Bật mTLS STRICT toàn mesh: mã hóa mọi traffic service-to-service, KHÔNG sửa code
kubectl apply -f - <<'EOF'
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
EOF

# Xác minh nhanh:
kubectl get peerauthentication -A     # thấy istio-system/default STRICT
# Kiểm chứng trực quan: Kiali hiển thị biểu tượng ổ khóa trên các cạnh (traffic đã mã hóa)
```
⚠️ **BÀI HỌC THẬT:** ngay sau khi apply STRICT sẽ có ~15–30s traffic 500 do config mTLS cần
propagate xuống mọi Envoy sidecar. Chờ ~30s là hết. Nếu 500 kéo dài → có pod thiếu sidecar
(STRICT chặn mọi traffic plaintext từ pod ngoài mesh).

Đây là câu trả lời cho lỗi #1 & #4 trong `02-security/SECURITY-AUDIT.md`.

## 7. Demo Traffic Management — Fault Injection ✅ (đã chạy thật)

Service mesh chèn lỗi để test resilience mà **không sửa code**:

```sh
# --- Delay fault: inject trễ 5s cho 100% request tới productcatalogservice ---
kubectl apply -f - <<'EOF'
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: productcatalog-fault
spec:
  hosts: [productcatalogservice]
  http:
    - fault:
        delay:
          percentage: {value: 100}
          fixedDelay: 5s
      route:
        - destination: {host: productcatalogservice}
EOF

# Đo tác động: /product/ nhảy từ ~0.02s lên ~35s (fan-out nhiều lần gọi -> tích lũy)
curl -s -o /dev/null -w "%{time_total}s\n" http://localhost:8080/product/OLJCESPC7Z
kubectl delete virtualservice productcatalog-fault   # gỡ -> hồi phục ngay

# --- Abort fault: 50% request tới currencyservice trả 503 (mô phỏng service lỗi) ---
# đổi khối fault thành:  abort: {percentage: {value: 50}, httpStatus: 503}
```
⚠️ Kết quả thật đã đo: delay 5s làm `/product/` mất **~35s** vì frontend gọi
productcatalogservice ~7 lần/trang (chi tiết + đề xuất) — lộ pattern fan-out gRPC.

## 7b. Demo HPA — Autoscaling ✅ (đã chạy thật)

```sh
minikube addons enable metrics-server                       # cần cho HPA
kubectl autoscale deployment frontend --cpu=20% --min=1 --max=5
# dồn tải bằng k6 (mục 8) -> CPU vượt 20% -> HPA tự tăng replica (desired=5)
kubectl get hpa frontend -w        # xem TARGETS và REPLICAS tăng
kubectl delete hpa frontend        # dọn sau khi demo
```
⚠️ Đặt ngưỡng thấp (20%) vì tải qua port-forward chỉ đẩy CPU ~24–35%. Muốn demo
"đúng chuẩn" phải dồn tải qua Service/NodePort để phân phối lên nhiều pod.

## 8. Sinh tải để dashboard "sống" khi demo

```sh
# Chạy k6 (phần 1) trong lúc mở Grafana/Kiali:
k6 run -e BASE_URL=http://localhost:8080 ../../Midterm/01-scalability/k6-test.js
# -> Kiali thấy luồng traffic chạy; Grafana thấy RPS & latency tăng
```

## 9. Dọn dẹp

```sh
kubectl delete -f ./release/kubernetes-manifests.yaml
istioctl uninstall --purge -y
minikube stop        # hoặc: minikube delete
```

---

## Bản đồ đề → công cụ (để trả lời "công cụ này giải quyết gì")

| Đề yêu cầu | Công cụ | Vai trò trong demo |
|---|---|---|
| Microservice Architecture | Online Boutique (11 service, gRPC) | Kiến trúc phân tán, polyglot |
| Containers | **Docker** | Đóng gói mỗi service thành image |
| Container Orchestration | **Kubernetes** (minikube) | Lịch chạy, scale, self-heal pods |
| Service Mesh | **Istio** (Envoy sidecar) | mTLS, traffic mgmt, observability |
| Metrics | **Prometheus** | Thu thập & lưu time-series metric |
| Visualization | **Grafana** | Dashboard latency/throughput/error |
| Topology | **Kiali** | Đồ thị dịch vụ real-time |

## Sự cố hay gặp

- **Pod Pending / OOM**: minikube thiếu RAM → tăng `--memory`. 11 service + istio khá nặng.
- **ImagePullBackOff**: mạng chậm khi kéo image — chờ, hoặc `minikube ssh docker pull` trước.
- **addons 404**: đổi `release-1.30` cho khớp `istioctl version`.
- **port-forward rớt**: chạy lại lệnh; nó không tự reconnect.
- Lần đầu bao giờ cũng lâu → **đừng chạy lần đầu ngay trước giờ thi**.
