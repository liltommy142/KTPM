---
tags: [ktpm, exam-day]
---

# 🎯 NGÀY THI — Playbook demo tại chỗ

> Thầy coi thi: *"chuẩn bị sẵn máy, môi trường, API key; thi tại chỗ, thầy tới từng nhóm xem demo + hỏi + chấm; câu hỏi có thể nhắm vào BẤT KỲ phần nào của đề."*
> File này = việc cần làm để không lúng túng khi thầy tới.

## ⚡ TL;DR
1. **API key:** demo lõi **KHÔNG cần API key nào cả** (đã kiểm). Không có gì phải xin/nhập trước. (Chỉ AI shopping assistant tùy chọn mới cần Gemini key — mình không deploy.)
2. **Dựng môi trường TRƯỚC khi thi bắt đầu** (không dựng khi thầy đang đứng cạnh — cold start lâu).
3. Kiểm tra 1 lệnh: `bash Midterm/check.sh` → phải thấy **"SẴN SÀNG DEMO"**.

---

## A. TRƯỚC giờ thi (làm ở nhà / lúc vào phòng, ~5–15 phút)

```sh
# 1. Bật Docker Desktop (mở app, chờ icon xanh)
# 2. Khởi động cluster (warm-start ~2-3 phút vì image đã cache; cold ~15 phút)
minikube start --cpus=4 --memory=6144
kubectl config use-context minikube

# 3. Nếu pods CHƯA chạy (laptop vừa restart) — deploy lại:
cd /Users/liltommy/Desktop/Study/KTPM/Exercises/microservices-demo
istioctl install --set profile=demo -y            # nếu istio-system chưa có
kubectl label namespace default istio-injection=enabled --overwrite
kubectl apply -f ./release/kubernetes-manifests.yaml
kubectl set resources deployment cartservice -c=server --limits=memory=256Mi --requests=memory=128Mi
BASE=https://raw.githubusercontent.com/istio/istio/release-1.30/samples/addons
kubectl apply -f $BASE/prometheus.yaml -f $BASE/grafana.yaml -f $BASE/kiali.yaml
kubectl apply -f - <<'EOF'
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata: {name: default, namespace: istio-system}
spec: {mtls: {mode: STRICT}}
EOF

# 4. Chờ mọi pod 2/2 rồi kiểm tra sẵn sàng:
until [ "$(kubectl get pods --no-headers | grep -c '2/2')" -ge 12 ]; do sleep 5; done
bash /Users/liltommy/Desktop/Study/KTPM/Midterm/check.sh    # phải ra "SẴN SÀNG DEMO"
```

> 💡 Nếu môi trường **đang chạy sẵn** (như hiện tại) thì chỉ cần chạy `check.sh`, khỏi làm lại bước 3.

**Mở sẵn nhiều tab terminal + trình duyệt trước khi thầy tới:**
- Tab 1: `kubectl port-forward deployment/frontend 8080:8080` → mở `http://localhost:8080`
- Tab 2: `istioctl dashboard kiali` (topology)
- Tab 3: `istioctl dashboard grafana` (dashboard "Istio Service Dashboard")
- Mở sẵn trong VS Code: `03-architecture/diagrams/` (8 ảnh view) + các file .md.

---

## B. KHI THẦY TỚI — demo nhanh 3 phần (mỗi phần 1–2 phút)

### Phần 3 (Microservices) — mở màn bằng cái "hoành tráng" nhất
- Chỉ `kubectl get pods` → "11 microservice + Redis, mỗi pod **2/2** = app + Envoy sidecar của Istio".
- Mở `http://localhost:8080` → bấm mua hàng cho thầy thấy chạy thật.
- Mở **Kiali** → chỉ đồ thị service gọi nhau real-time, ổ khóa = **mTLS**.
- Mở **Grafana** → "Istio Service Dashboard" → latency p50/p90/p99, RPS.

### Phần 1a (Scalability) — chạy k6 tại chỗ
```sh
k6 run -e BASE_URL=http://localhost:8080 --stage 20s:10 --stage 30s:50 --stage 10s:0 \
  Midterm/01-scalability/k6-test.js
```
- Vừa chạy vừa chỉ Grafana/Kiali "sống". Giải thích **p95, throughput, error rate** (xem `01-scalability/SCALABILITY.md`).
- Nói HPA: đã demo autoscale (RESULTS.md mục A).

### Phần 1b (Security) — chỉ vào code + công cụ
- Mở `02-security/SECURITY-AUDIT.md` → chỉ **file:line thật** (gRPC plaintext `frontend/main.go:230`, Redis không mật khẩu...).
- Chỉ Trivy: `redis:alpine` sạch, config scan 25 MEDIUM + 55 LOW.
- Chốt: "giải pháp là mTLS STRICT của Istio — đã bật, không sửa code".

### Phần 2 (Kiến trúc) — chiếu 8 view
- Mở thư mục `03-architecture/diagrams/` → 8 ảnh: 4+1 Views + DB Schema + **Security View** + **Concurrency View**.
- Nhấn: *view = mối quan tâm, khác UML model* (câu thầy hay hỏi — xem CHEATSHEET mục C).

---

## C. Nếu thầy hỏi "bất kỳ phần nào" → dùng CHEATSHEET
`05-theory/CHEATSHEET.md` có sẵn câu trả lời cho: định nghĩa architecture, QA + tactics + trade-off, 4+1 views vs UML model, C4, architectural styles, k8s/Istio/mTLS/sidecar, CAP, coupling/cohesion, và các **câu bẫy**.

## D. Sự cố tại chỗ (bình tĩnh xử lý — đã gặp thật, xem RESULTS.md)
| Triệu chứng | Xử lý nhanh |
|---|---|
| `no healthy upstream` 500 | Pod chưa 2/2 → `kubectl get pods`, chờ; hoặc mTLS mới bật, chờ 30s |
| cartservice restart / OOM | `kubectl set resources deployment cartservice -c=server --limits=memory=256Mi` |
| k6 lỗi nhiều | Chờ đủ pod 2/2 rồi chạy lại |
| port-forward rớt | Chạy lại lệnh port-forward |
| kubectl sai cluster | `kubectl config use-context minikube` |

## E. Trước khi rời phòng
Không cần tắt gì (để thầy nhóm sau xem cũng được). Nếu muốn tắt: `minikube stop`.
