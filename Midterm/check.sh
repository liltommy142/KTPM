#!/usr/bin/env bash
# Kiểm tra sẵn sàng demo trong 1 lệnh:  bash Midterm/check.sh
# In ra trạng thái từng thành phần; cuối cùng nói READY hay chưa.
set +e
green="\033[32m"; red="\033[31m"; yellow="\033[33m"; rst="\033[0m"
ok(){ echo -e "  ${green}✓${rst} $1"; }
bad(){ echo -e "  ${red}✗${rst} $1"; FAIL=1; }
warn(){ echo -e "  ${yellow}!${rst} $1"; }

FAIL=0
echo "== 1. Docker =="
docker info >/dev/null 2>&1 && ok "Docker daemon chạy" || bad "Docker CHƯA chạy → mở Docker Desktop"

echo "== 2. minikube =="
if minikube status 2>/dev/null | grep -q "host: Running"; then ok "minikube Running"; else bad "minikube chưa chạy → minikube start"; fi
kubectl config current-context 2>/dev/null | grep -q minikube && ok "kubectl trỏ minikube" || warn "kubectl KHÔNG trỏ minikube → kubectl config use-context minikube"

echo "== 3. Pods Online Boutique =="
READY=$(kubectl get pods --no-headers 2>/dev/null | grep -c '2/2')
TOTAL=$(kubectl get pods --no-headers 2>/dev/null | wc -l | tr -d ' ')
[ "$READY" -ge 12 ] 2>/dev/null && ok "$READY/$TOTAL pod 2/2 Running" || bad "chỉ $READY pod 2/2 (cần >=12) → chờ hoặc deploy lại"

echo "== 4. Istio + mTLS + observability =="
kubectl get ns istio-system >/dev/null 2>&1 && ok "istio-system tồn tại" || bad "chưa cài Istio"
kubectl get peerauthentication -A --no-headers 2>/dev/null | grep -q STRICT && ok "mTLS STRICT bật" || warn "mTLS chưa STRICT (tùy chọn)"
for d in prometheus grafana kiali; do
  kubectl -n istio-system get pods --no-headers 2>/dev/null | grep -q "$d.*Running" && ok "$d Running" || warn "$d chưa Running"
done

echo "== 5. App phục vụ được? =="
pkill -f "port-forward deployment/frontend" 2>/dev/null; sleep 1
kubectl port-forward deployment/frontend 8080:8080 >/tmp/pf-check.log 2>&1 &
sleep 4
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null)
[ "$CODE" = "200" ] && ok "frontend trả HTTP 200" || bad "frontend trả '$CODE' (không 200)"
pkill -f "port-forward deployment/frontend" 2>/dev/null

echo ""
if [ "$FAIL" = "0" ]; then
  echo -e "${green}==> SẴN SÀNG DEMO.${rst} Mở web: kubectl port-forward deployment/frontend 8080:8080"
else
  echo -e "${red}==> CHƯA sẵn sàng — xem các dòng ✗ ở trên.${rst} Cách dựng nhanh: Midterm/00-EXAM-DAY.md"
fi
