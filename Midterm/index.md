---
title: KTPM — Ôn thi Kiến trúc Phần mềm
hide:
  - toc
---

<div class="ktpm-hero" markdown="1">
<div class="ktpm-hero__grid"></div>
<p class="ktpm-hero__eyebrow">Software Architecture · Midterm</p>
<h1 class="ktpm-hero__title">Kiến trúc phần mềm, chạy được — không chỉ trên slide.</h1>
<p class="ktpm-hero__sub">Bộ ôn thi vấn đáp giữa kỳ: một hệ Online Boutique 11 microservice trên Kubernetes + Istio, đã dựng và đo thật. Scalability, security, 8 view kiến trúc, và service mesh — tất cả kèm số liệu.</p>
<div class="ktpm-status">
  <span class="ktpm-status__chip"><span class="ktpm-status__dot"></span>12/12 pods 2/2</span>
  <span class="ktpm-status__chip"><span class="ktpm-status__dot"></span>mTLS STRICT</span>
  <span class="ktpm-status__chip ktpm-status__chip--metric"><span class="ktpm-status__dot"></span>p95 272 ms</span>
  <span class="ktpm-status__chip ktpm-status__chip--metric"><span class="ktpm-status__dot"></span>0.00% err</span>
  <span class="ktpm-status__chip ktpm-status__chip--metric"><span class="ktpm-status__dot"></span>39.6 req/s</span>
</div>
</div>

Trang này là bản web của bộ tài liệu ôn thi. Cùng nội dung mở được trong Obsidian (vault `Midterm/`). Đề gốc: [software-architecture-midterm-exam](https://nhbien.github.io/software-architecture-midterm-exam/).

## Vào thẳng nội dung

<div class="ktpm-cards">
<a class="ktpm-card" href="01-scalability/SCALABILITY/"><span class="ktpm-card__tag">Câu 1a</span><span class="ktpm-card__title">Scalability</span><span class="ktpm-card__desc">k6 load test + HPA autoscaling, cách đọc p95 / throughput / error rate.</span></a>
<a class="ktpm-card" href="02-security/SECURITY-AUDIT/"><span class="ktpm-card__tag">Câu 1b</span><span class="ktpm-card__title">Security</span><span class="ktpm-card__desc">Audit AI (5 lỗi có file:line) + Trivy scan, nối sang mTLS của Istio.</span></a>
<a class="ktpm-card" href="03-architecture/ARCHITECTURE/"><span class="ktpm-card__tag">Câu 2</span><span class="ktpm-card__title">Kiến trúc · 8 view</span><span class="ktpm-card__desc">4+1 Views + Database Schema + Security View + Concurrency View.</span></a>
<a class="ktpm-card" href="04-demo-runbook/RUNBOOK/"><span class="ktpm-card__tag">Câu 3</span><span class="ktpm-card__title">Microservices + DevOps</span><span class="ktpm-card__desc">Docker · Kubernetes · Istio · Prometheus · Grafana, từng lệnh.</span></a>
<a class="ktpm-card" href="05-theory/CHEATSHEET/"><span class="ktpm-card__tag">Vấn đáp</span><span class="ktpm-card__title">Cheat Sheet lý thuyết</span><span class="ktpm-card__desc">QA, view vs UML model, styles, CAP, câu bẫy — trả lời "bất kỳ phần nào".</span></a>
<a class="ktpm-card" href="00-EXAM-DAY/"><span class="ktpm-card__tag">🎯 Ngày thi</span><span class="ktpm-card__title">Playbook tại chỗ</span><span class="ktpm-card__desc">Dựng môi trường, demo nhanh 3 phần, xử lý sự cố khi thầy đứng cạnh.</span></a>
</div>

## Vì sao một hệ cho cả 3 câu?

Online Boutique trả lời được **cả ba phần của đề** cùng lúc: nó *là* kiến trúc microservices (câu 3), có thể **đo scalability** bằng k6 và **audit security** trên chính mã nguồn (câu 1), và **tái hiện được bằng 8 view** (câu 2). Một hệ thống, mạch demo liền một hơi — xem [kết quả chạy thật + sự cố đã gặp](RESULTS.md).
