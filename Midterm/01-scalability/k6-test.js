// k6 load test cho Online Boutique frontend
// Chạy: k6 run -e BASE_URL=http://localhost:8080 k6-test.js
// (port-forward frontend trước: kubectl port-forward deployment/frontend 8080:8080)
import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

// 9 product ID thật trong productcatalogservice/products.json
const PRODUCTS = [
  'OLJCESPC7Z', '66VCHSJNUP', '1YMWWN1N4O', 'L9ECAV7KIM', '2ZYFJ3GM2N',
  '0PUK6V6EV0', 'LS4PSXUNUM', '9SIQT8TOJO', '6E92ZMYYFZ',
];

export const options = {
  // 3 giai đoạn: ramp-up -> giữ tải -> stress -> ramp-down
  stages: [
    { duration: '30s', target: 10 },  // khởi động: 10 VU
    { duration: '1m', target: 50 },   // tải bình thường: 50 VU
    { duration: '1m', target: 100 },  // stress: 100 VU
    { duration: '30s', target: 0 },   // hạ tải
  ],
  thresholds: {
    // SLO: 95% request < 500ms, tỉ lệ lỗi < 1%
    http_req_duration: ['p(95)<500'],
    http_req_failed: ['rate<0.01'],
  },
};

export default function () {
  // Mô phỏng 1 phiên mua hàng thực tế
  let res = http.get(`${BASE_URL}/`);
  check(res, { 'home 200': (r) => r.status === 200 });
  sleep(1);

  const id = PRODUCTS[Math.floor(Math.random() * PRODUCTS.length)];
  res = http.get(`${BASE_URL}/product/${id}`);
  check(res, { 'product 200': (r) => r.status === 200 });
  sleep(1);

  res = http.post(`${BASE_URL}/cart`, { product_id: id, quantity: '1' });
  check(res, { 'add-to-cart ok': (r) => r.status === 200 || r.status === 302 });
  sleep(1);

  res = http.get(`${BASE_URL}/cart`);
  check(res, { 'view cart 200': (r) => r.status === 200 });
  sleep(1);
}
